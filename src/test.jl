# Wrap objects so we don't get confused iterating
# inside the objects themselves during tests.
struct TestObjectWrapper{O}
    objects::O
end

Base.iterate(tow::TestObjectWrapper, args...) = iterate(tow.objects, args...)
Base.length(tow::TestObjectWrapper, args...) = length(tow.objects)
Base.getindex(tow::TestObjectWrapper, i::Int) = getindex(tow.objects, i)

function check_coherent_types(O::Type, obj)
    T = typeof(obj)
    if obj isa Arguments
        F = first_field_type(T)
    else
        F = T
    end
    if !(F <: O)
        throw(ArgumentError("""Each tested object must either be an instance of `$O` or an instance of `Arguments` whose first field type is `$O`. You provided a `$T` instead. """))
    end
end

function check_coherent_types(O::Type, tow::TestObjectWrapper)
    for obj in tow
        check_coherent_types(O::Type, obj)
    end
end

"""
    test(::Type{<:Interface}, obj)

Test if an interface is implemented correctly for an object,
returning `true` or `false`.

If no interface type is passed, Interfaces.jl will find all the
interfaces available and test them.
"""
function test(T::Type{<:Interface{Keys}}, O::Type, test_objects; kw...) where Keys
    # Allow passing the keys in the abstract type
    # But get them out and put them in the `keys` keyword
    T1 = _get_type(T).name.wrapper
    objs = TestObjectWrapper(test_objects)
    # And run the tests on the parameterless type
    return _test(T1, O, objs; keys=Keys, kw...)
end
function test(T::Type{<:Interface}, O::Type, test_objects; kw...)
    objs = TestObjectWrapper(test_objects)
    return _test(T, O, objs; kw...)
end
# Convenience method for users to test a single object
test(T::Type{<:Interface}, obj; kw...) = test(T, typeof(obj), (obj,); kw...)

function _test(T::Type{<:Interface}, O::Type, objs::TestObjectWrapper;
    show=true, keys=nothing
)
    check_coherent_types(O, objs)
    if show
        print("Testing ")
        printstyled(_get_type(T).name.name; color=:blue)
        print(" is implemented for ")
        printstyled(O, "\n"; color=:blue)
    end
    if isnothing(keys)
        optional = NamedTuple{optional_keys(T, O)}(components(T).optional)
        mandatory_results = _test(components(T).mandatory, objs)
        optional_results = _test(optional, objs)
        if show
            _showresults(mandatory_results, "Mandatory components")
            _showresults(optional_results, "Optional components")
        end
        return all(_bool(mandatory_results)) && all(_bool(optional_results))
    else
        allcomponents = merge(components(T)...)
        optional = NamedTuple{_as_tuple(keys)}(allcomponents)
        results = _test(optional, objs)
        show && _showresults(results, "Specified components")
        return all(_bool(results))
    end
end

function _test(tests::NamedTuple{K}, objs::TestObjectWrapper) where K
    map(keys(tests), values(tests)) do k, v
        _test(k, v, objs)
    end |> NamedTuple{K}
end
function _test(name::Symbol, condition::Tuple, objs, i=nothing)
    map(condition, ntuple(identity, length(condition))) do c, i
        _test(name, c, objs, i)
    end
end
function _test(name::Symbol, condition::Tuple, objs::TestObjectWrapper, i=nothing)
    map(condition, ntuple(identity, length(condition))) do c, i
        _test(name, c, objs, i)
    end
end
function _test(name::Symbol, condition, objs::TestObjectWrapper, i=nothing)
    map(o -> _test(name, condition, o, i), objs.objects)
end
function _test(name::Symbol, condition, obj, i=nothing)
    try
        res = condition isa Pair ? condition[2](obj) : condition(obj)
        # Allow returning a function or tuple of functions that are tested again
        if res isa Union{Pair,Tuple,Base.Callable}
            return _test(name, res, obj, i)
        else
            return condition isa Pair ? condition[1] => res : res
        end
    catch e
        num = isnothing(i) ? "" : ", condition $i"
        desc = condition isa Pair ? string(" \"", condition[1], "\"") : ""
        @warn "interface test :$name$num$desc failed for test object $obj"
        rethrow(e)
    end
end

function _showresults(results::NamedTuple, title::String)
    printstyled(title; color=:light_black)
    println()
    foreach(keys(results), results) do k, res
        print("$k : ")
        _showresult(k, res)
        println()
    end
end

_showresult(key, res) = show(res)
function _showresult(key, pair::Pair)
    desc, res = pair
    print(desc, ": ")
    printstyled(res; color=(res ? :green : :red))
end
_showresult(key, res::Bool) = printstyled(res; color=(res ? :green : :red))
function _showresult(key, res::NTuple{<:Any,Bool})
    _showresult(key, first(res))
    map(r -> (print(", "); _showresult(key, r)), Base.tail(res))
end
function _showresult(key, res::NTuple{<:Any})
    _showresult(key, first(res))
    spacer = join([' ' for i in 1:length(string(key)) + 3])
    map(r -> (print(",\n$spacer"); _showresult(key, r)), Base.tail(res))
end

_bool(xs::Union{Tuple,NamedTuple,AbstractArray}) = all(map(_bool, xs))
_bool(x::Pair) = x[2]
_bool(x::Bool) = x
_bool(x) = convert(Bool, x)

_as_tuple(x) = (x,)
_as_tuple(xs::Tuple) = xs

_get_type(obj) = _get_type(typeof(obj))
_get_type(T::Type) = T
_get_type(T::UnionAll) = _get_type(T.body)

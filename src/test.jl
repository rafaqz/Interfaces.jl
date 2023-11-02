struct InterfaceError <: Exception 
    t::Type
    name::Symbol
    num::Union{Nothing,Int}
    desc::String
    obj::Any
    e::Exception
end

function Base.showerror(io::IO, ie::InterfaceError)
    printstyled("InterfaceError: "; color=:red)
    numstring = isnothing(ie.num) ? "" : " $(ie.num)"
    println("test for $(ie.t) :$(ie.name)$(numstring)$(ie.desc) threw a $(typeof(ie.e)) \n For test object $(ie.obj):\n")
    Base.showerror(io, ie.e)
end

# Wrap objects so we don't get confused iterating
# inside the objects themselves during tests.
struct TestObjectWrapper{O}
    objects::O
end

Base.iterate(tow::TestObjectWrapper, args...) = iterate(tow.objects, args...)
Base.length(tow::TestObjectWrapper, args...) = length(tow.objects)
Base.getindex(tow::TestObjectWrapper, i::Int) = getindex(tow.objects, i)

function check_coherent_types(O::Type, obj)
    if obj isa Arguments
        coherent_types = any(T -> T <: O, fieldtypes(typeof(nt(obj))))
    else
        coherent_types = obj isa O
    end
    if !coherent_types
        throw(ArgumentError("""Each tested object must either be an instance of `$O` or an instance of `Arguments` whose field types include at least one subtype of `$O`. You provided a `$(typeof(obj))` instead. """))
    end
end
function check_coherent_types(O::Type, tow::TestObjectWrapper)
    for obj in tow
        check_coherent_types(O::Type, obj)
    end
end

"""
    test(m::Module)
    test(::Type{<:Interface}, m::Module)
    test(::Type{<:Interface}, obj::Type)

Test if an interface is implemented correctly for an object,
returning `true` or `false`.

If no interface type is passed, Interfaces.jl will find all the
interfaces available and test them.
"""
function test(T::Type{<:Interface}, mod::Module; kw...) 
    methodlist = methods(implements, Tuple{T,<:Any})
    _test_module(mod, methodlist; kw...)
end
function test(mod::Module; kw...) 
    methodlist = methods(implements, Tuple{<:Any,<:Any})
    _test_module(mod, methodlist; kw...)
end


function _test_module(mod, methodlist; kw...)
    all(methodlist) do m
        m.module == mod || return true
        b = m.sig isa UnionAll ? m.sig.body : m.sig
        # We make this signature in the @interface macro
        # so we know it is this consistent

        t = b.parameters[2].var.ub
        if t isa UnionAll
            T = t.body.name.wrapper
        else
            T = t.name.wrapper
        end
        O = b.parameters[3].var.ub
        @show T O typeof(T) typeof(O)

        return test(T, O; kw...)
    end
end

function test(T::Type{<:Interface{Keys}}, O::Type, test_objects=test_objects(T, O); kw...) where Keys
    # Allow passing the keys in the abstract type
    # But get them out and put them in the `keys` keyword
    T1 = _get_type(T).name.wrapper
    objs = TestObjectWrapper(test_objects)
    # And run the tests on the parameterless type
    return _test(T1, O, objs; keys=Keys, kw...)
end
function test(T::Type{<:Interface}, O::Type, test_objects=test_objects(T, O); kw...)
    objs = TestObjectWrapper(test_objects)
    return _test(T, O, objs; kw...)
end
# Convenience method for users to test a single object
test(T::Type{<:Interface}, obj; kw...) = test(T, typeof(obj), (obj,); kw...)

function _test(T::Type{<:Interface}, O::Type, objs::TestObjectWrapper;
    show=true, keys=nothing
)

    O <: requiredtype(T) || throw(ArgumentError("$O is not a subtype of $(requiredtype(T))"))  
    check_coherent_types(O, objs)
    if show
        print("\nTesting ")
        printstyled(_get_type(T).name.name; color=:blue)
        print(" is implemented for ")
        printstyled(O, "\n"; color=:blue)
    end
    if isnothing(keys)
        optional = NamedTuple{optional_keys(T, O)}(components(T).optional)
        mandatory_results = _test(T, components(T).mandatory, objs)
        optional_results = _test(T, optional, objs)
        if show
            _showresults(stdout, mandatory_results, "Mandatory components")
            if !isempty(optional_results)
                _showresults(stdout, optional_results, "Optional components")
            end
        end
        return all(_bool(mandatory_results)) && all(_bool(optional_results))
    else
        allcomponents = merge(components(T)...)
        optional = NamedTuple{_as_tuple(keys)}(allcomponents)
        results = _test(T, optional, objs)
        show && _showresults(stdout, results, "Specified components")
        return all(_bool(results))
    end
end

function _test(T, tests::NamedTuple{K}, objs::TestObjectWrapper) where K
    map(keys(tests), values(tests)) do k, v
        _test(T, k, v, objs)
    end |> NamedTuple{K}
end
function _test(T, name::Symbol, condition::Tuple, objs, i=nothing)
    map(condition, ntuple(identity, length(condition))) do c, i
        _test(T, name, c, objs, i)
    end
end
function _test(T, name::Symbol, condition::Tuple, objs::TestObjectWrapper, i=nothing)
    map(condition, ntuple(identity, length(condition))) do c, i
        _test(T, name, c, objs, i)
    end
end
function _test(T, name::Symbol, condition, objs::TestObjectWrapper, i=nothing)
    map(o -> _test(T, name, condition, o, i), objs.objects)
end
function _test(T, name::Symbol, condition, obj, i=nothing)
    obj_copy = deepcopy(obj)
    res = try
        f = condition isa Pair ? condition[2] : condition
        # GC.enable(false)
        f(obj_copy)
        # GC.enable(true)
        # Allow returning a function or tuple of functions that are tested again
    catch e
        desc = condition isa Pair ? string(" \"", condition[1], "\"") : ""
        rethrow(InterfaceError(T, name, i, desc, obj, e))
    end

    if res isa Union{Pair,Tuple,Base.Callable}
        return _test(T, name, res, obj, i)
    else
        return condition isa Pair ? condition[1] => res : res
    end
end

function _showresults(io::IO, results::NamedTuple, title::String)
    printstyled(title; color=:light_black)
    println()
    foreach(keys(results), results) do k, res
        printstyled("$k"; color=:magenta)
        print(": ")
        _showresult(io, k, res)
        println()
    end
end

_showresult(io, key, res) = show(res)
function _showresult(io, key, pair::Pair)
    desc, res = pair
    print(desc, " ")
    _showresult(io, key, res)
end
_showresult(io, key, res::Bool) = printstyled(io, res; color=(res ? :green : :red))
function _showresult(io, key, res::AbstractArray)
    print(io, "[") 
    _showresult(io, key, first(res))
    for r in res[2:end]
        print(io, ", ") 
        _showresult(io, key, r) 
    end
    print(io, "]") 
end
function _showresult(io, key, res::AbstractArray{<:Pair})
    _showresult(io, key, first(first(res)) => last.(res))
end
function _showresult(io, key, res::NTuple{<:Any,Bool})
    print(io, "(") 
    _showresult(io, key, first(res))
    map(r -> (print(io, ", "); _showresult(io, key, r)), Base.tail(res))
    print(io, ")") 
end
function _showresult(io, key, res::NTuple{<:Any})
    print(io, "(") 
    _showresult(io, key, first(res))
    spacer = join([' ' for i in 1:length(string(key)) + 3])
    map(r -> (print(io, ",\n$spacer"); _showresult(io, key, r)), Base.tail(res))
    print(io, ")") 
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


"""
    test(::Type{<:Interface}, obj)

Test if an interface is implemented correctly for an object,
returning `true` or `false`.

If no interface type is passed, Interfaces.jl will find all the
interfaces available and test them.
"""
function test(T::Type{<:Interface{Keys}}, O::Type; kw...) where Keys 
    T1 = _get_type(T).name.wrapper
    obj = test_object(T1, O)
    return test(T1, obj; keys=Keys, _O=O, kw...)
end
function test(T::Type{<:Interface}, O::Type; kw...)
    obj = test_object(T, O)
    return test(T, obj; _O=O, kw...)
end
function test(T::Type{<:Interface}, obj; show=true, keys=nothing, _O=typeof(obj))
    if show 
        print("Testing ")
        printstyled(_get_type(T).name.name; color=:blue)
        print(" is implemented for ")
        printstyled(_O, "\n"; color=:blue)
    end
    if isnothing(keys)
        optional = NamedTuple{optional_keys(T, obj)}(components(T).optional)
        mandatory_results = _test(components(T).mandatory, obj) 
        optional_results = _test(optional, obj)
        if show 
            _showresults(mandatory_results, "Mandatory components")
            _showresults(optional_results, "Optional components")
        end
        println()
        return all(_bool(mandatory_results)) && all(_bool(optional_results))
    else
        allcomponents = merge(components(T)...)
        optional = NamedTuple{_as_tuple(keys)}(allcomponents)
        results = _test(optional, obj)
        show && _showresults(results, "Specified components")
        println()
        return all(_bool(results))
    end
end

_test(tests::NamedTuple, obj) = map(t -> _test(t, obj), tests)
_test(condition::Tuple, obj) = map(c -> _test(c, obj), condition)
_test(condition, obj) = condition(obj)

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
_bool(x::Bool) = x
_bool(x) = convert(Bool, x)

_as_tuple(x) = (x,)
_as_tuple(xs::Tuple) = xs

_get_type(obj) = _get_type(typeof(obj))
_get_type(T::Type) = T
_get_type(T::UnionAll) = _get_type(T.body)

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
    test(; kw...)
    test(mod::Module; kw...)
    test(::Type; kw...)
    test(::Type{<:Interface}; kw...)
    test(::Type{<:Interface}, mod::Module; kw...)
    test(::Type{<:Interface}, type::Type, [test_objects]; kw...)

Test if an interface is implemented correctly, returning `true` or `false`.

There are a number of ways to select implementations to test:

- With no arguments, test all defined `Interface`s currenty imported.
- If a `Module` is passed, all `Interface` implementations defined in it will be tested. 
    This is probably the best option to put in package tests.
- If only an `Interface` is passed, all implementations of it are tested.
- If only a `Type` is passed, all interfaces it implements are tested.
- If both a `Module` and an `Interface` are passed, test the intersection.
    of implementations of the `Interface` for the `Module`.
- If an `Interface` and `Type` are passed, the implementation for that type will be tested.

If no interface type is passed, Interfaces.jl will find all the
interfaces available and test them.
"""
function test end
test(; kw...) = _test_module_implements(Any, nothing; kw...)
test(T::Type{<:Interface}, mod::Module; kw...) =
    _test_module_implements(Type{_check_no_options(T)}, mod; kw...)
test(mod::Module; kw...) = _test_module_implements(Any, mod; kw...)
test(T::Type{<:Interface}; kw...) =
    _test_module_implements(Type{_check_no_options(T)}, nothing; kw...)

_check_no_options(T::Type) = T
_check_no_options(::Type{<:Interface{Keys}}) where Keys =
    throw(ArgumentError("Interface options not accepted for more than one implementation"))
# Here we test all the `implements` methods in `methodlist` that were defined in `mod`.
# Basically we are using the `implements` method table as the global state of all
# available implementations.
function _test_module_implements(T, mod; show=true, kw...)
    # (T == Any || T isa UnionAll) || throw(ArgumentError("Interface options not accepted for more than one implementation"))
    # Get all methods for `implements(T, x)`
    methodlist = methods(Interfaces.implements, Tuple{T,Any})
    # Check that all found methods are either unrequired, or pass their tests
    results = map(methodlist) do m
        (isnothing(mod) && m.module != Interfaces) || m.module == mod || return nothing, true
        # We define this signature in the @interface macro so we know it is this consistent.
        # There may be some methods to help with these things?
        
        # Handle either Type or UnionAll for the method signature parameters
        b = m.sig isa UnionAll ? m.sig.body : m.sig

        # Skip the fallback methods
        b.parameters[2] == Type{<:Interface} && return nothing, true

        # Skip the Type versions of implements and keep the UnionAll
        t = b.parameters[2].var.ub
        t isa UnionAll || return nothing, true

        if t.body isa UnionAll
            interface = t.body.body.name.wrapper
        else
            interface = t.body.name.wrapper
        end
        implementation = b.parameters[3].var.ub
        implementation == Any && return nothing, true

        (interface, implementation), test(interface, implementation; show, kw...)
    end
    if show
        println(stdout)
        println(stdout, "Implementation summary:")
        hasprinted = false
        for (x, res) in results
            isnothing(x) && continue
            interface, implementation = x
            hasprinted = true
            print_imlements(interface, implementation, res)
        end
        hasprinted || println("\nNo implementations were found for $T and $mod")
    end
    return all(last, results)
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
# Test types for all the interfaces they implement
function test(::Type{T}; show=true, kw...) where T
    # Get every interface declaration
    methodlist = methods(Interfaces.components)
    results = map(methodlist) do m
        t = m.sig.parameters[2].var.ub
        t isa UnionAll || return true
        interface = t.body.body.name.wrapper
        # If T implements it, test that
        if implements(interface, T)
            interface, test(interface, T; show, kw...)
        else
            nothing, true
        end
    end
    if show
        println(stdout)
        println(stdout, "Interface summary for $T:")
        for (interface, res) in results
            isnothing(interface) && continue
            print_imlements(interface, T, res)
        end
    end
    return all(last, results)
end

function print_imlements(interface, T, res)
    printstyled(stdout, "  ", T; color=:yellow)
    print(stdout, " correctly implements ")
    printstyled(stdout, interface, ": "; color=:blue) 
    printstyled(stdout, res; color=_boolcolor(res))
    println(stdout)
end

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
            _showresults(stdout, mandatory_results, "\nMandatory components")
            if !isempty(optional_results)
                _showresults(stdout, optional_results, "\nOptional components")
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
        f(obj_copy)
    catch e
        desc = condition isa Pair ? string(" \"", condition[1], "\"") : ""
        rethrow(InterfaceError(T, name, i, desc, obj, e))
    end

    # Allow returning a function or tuple of functions that are tested again
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
_showresult(io, key, res::Bool) = printstyled(io, res; color=_boolcolor(res))
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

_boolcolor(res) = res ? :green : :red

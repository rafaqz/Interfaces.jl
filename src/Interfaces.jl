module Interfaces

export Interface, @implements, @interface, implements

"""
    Interface{Components}

Abstract supertype for all interfaces.

Components is an `NTuple` of `Symbol`.
"""
abstract type Interface{Components} end


"""
    optional_keys(T::Type{<:Interface}, obj::Type)

Get the keys for the optional components of an [`Interface`](@ref),
as a tuple os `Symbol`.
"""
optional_keys(T::Type{<:Interface}, obj) = optional_keys(T, typeof(obj)) 
optional_keys(T::Type{<:Interface}, obj::Type) = ()

"""
    implements(::Type{<:Interface}, obj)
    implements(::Type{<:Interface{Options}}, obj)

Returns whether an object implements an interface, as a `Bool`.

`obj` can be an be an object or a `Type`.

Options can be a `Symbol` or a `Tuple` of `Symbol` passed to the type
parameter of the `Interface`, to check if optional interfaces are
implemented by the `obj`.

Without specifying `Options`, the return value specifies that at least 
all the mandatory components of the interace are implemented.
"""
implements(::Type{<:Interface}, obj) = false

"""
    components(::Type{<:Interface})

Returns the components of interface tests, as a `NamedTuple` of `NamedTuple`.
"""
function components end

"""
    implementing_module(T::Type{<:Interface}, O::Type)

Return the module that implements the interface type `T`` for the object type `O`.
"""
function implementing_module end

"""
@interface

Define an interface.

```julia
@interface MyInterface begin
    mandatory = (
        length = x -> length(x) = prod(size(x)),
        ndims = x -> ndims(x) = length(size(x)),
    ),
    optional = (;)
end
```
"""
macro interface(interface, components::Expr)
    quote
        # Define the interface type (should it be concrete?)
        abstract type $interface{Components} <: Interfaces.Interface{Components} end
        # Define the interface methods
        Interfaces.components(::Type{<:$interface}) = $components
    end |> esc
end

"""
    @implements(interface, objtype, obj)

Declare that an interface implements an interface, or
multipleinterfaces.

Also pass an object or tuple of objects to test it with.

The macro can only be used once per module for any one type.
To define multiple interfaces a type implements, combine them
in square brackets.

# Example

Here we implement the IterationInterface for Base julia, indicating with
`(:indexing, :reverse)` that our object can be indexed and works with `Iterators.reverse`:

```julia
using BaseInterfaces
@implements BaseInterfaces.IterationInterface{(:indexing,:reverse)} MyObject MyObject([1, 2, 3])
```
"""
macro implements(interface, objtype, obj)
    if interface isa Expr && interface.head == :curly
        interfacetype = interface.args[1]    
        optional_keys = interface.args[2]
    else
        interfacetype = interface
        optional_keys = ()
    end
    quote
        # Define a trait stating that `objtype` implements `interface`
        Interfaces.implements(::Type{<:$interfacetype}, ::Type{<:$objtype}) = true
        Interfaces.implements(T::Type{<:$interfacetype{Options}}, O::Type{<:$objtype}) where Options = 
            Interfaces._all_in(Options, Interfaces.optional_keys(T, O))
        Interfaces.optional_keys(::Type{<:$interfacetype}, ::Type{<:$objtype}) = $optional_keys
        Interfaces.implementing_module(::Type{<:$interfacetype}, ::Type{<:$objtype}) = @__MODULE__

        # Define the Module.__implements__ methods, for lookups both ways
        __implements__(x::$objtype) = __implements__(typeof(x))
        __implements__(::Type{<:$objtype}) = $interfacetype

        # Define Module.__interface_test_object__ method
        __interface_test_object__(::Type{<:$interfacetype}, ::Type{<:$objtype}) = $obj

        # Run tests during precompilation
        Interfaces.test($interface, $objtype)
    end |> esc
end

"""
    document(::Type{<:Interface}, ::Type)

Insert interface documentation into docs for objects That implement them.

# Example

```julia
\$(Interfaces.document(SomeInterface, SomeType))
```
"""
function document(T::Type{<:Interface}, O)
    implements(T, O) || error("Error in @document macro: Interface T is not implemented for objects of type O")
    "$O implements $T with optional components $(join(optional_keys(T, O), ", ", " and "))."
end

"""
    test(::Type{<:Interface}, obj)

Test if an interface is implemented correctly for an object,
returning `true` or `false`.

If no interface type is passed, Interfaces.jl will find all the
interfaces available and test them.
"""
function test(T::Type{<:Interface{Keys}}, O::Type; kw...) where Keys 
    T1 = _get_type(T).name.wrapper
    mod = implementing_module(T1, O)
    obj = mod.__interface_test_object__(T1, O)
    return test(T1, obj; keys=Keys, _O=O)
end
function test(T::Type{<:Interface}, O::Type; kw...)
    mod = implementing_module(T, O)
    obj = mod.__interface_test_object__(T, O)
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
        return all(_bool(mandatory_results)) && all(_bool(optional_results))
    else
        @show components(T)
        allcomponents = merge(components(T)...)
        optional = NamedTuple{_as_tuple(keys)}(allcomponents)
        results = _test(optional, obj)
        _showresults(results, "Specified components")
        return all(_bool(results))
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

_test(tests::NamedTuple, obj) = map(t -> _test(t, obj), tests)
_test(condition::Tuple, obj) = map(c -> _test(c, obj), condition)
_test(condition, obj) = condition(obj)

_bool(xs::Union{Tuple,NamedTuple,AbstractArray}) = all(map(_bool, xs))
_bool(x::Bool) = x
_bool(x) = convert(Bool, x)

_all_in(items::Tuple, collection) = all(map(in(collection), items))
_all_in(item::Symbol, collection) = in(item, collection)

_as_tuple(x) = (x,)
_as_tuple(xs::Tuple) = xs

_get_module(obj) = _get_type(obj).name.module

_get_type(obj) = _get_type(typeof(obj))
_get_type(T::Type) = T
_get_type(T::UnionAll) = _get_type(T.body)

end


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
function implements end
implements(::Type{<:Interface}, obj) = false

"""
    @implements(interface, objtype)
    @implements(dev, interface, objtype)

Declare that an interface implements an interface, or multipleinterfaces.

The macro can only be used once per module for any one type. To define
multiple interfaces a type implements, combine them in square brackets.

Passing the keyword `dev` as the first argument lets us show test output during development.
Do not use `dev` in production code, or output will appear during package precompilation.

# Example

Here we implement the IterationInterface for Base julia, indicating with
`(:indexing, :reverse)` that our object can be indexed and works with `Iterators.reverse`:

```julia
using BaseInterfaces
@implements BaseInterfaces.IterationInterface{(:indexing,:reverse)} MyObject
```
"""
macro implements(interface, objtype)
    _implements_inner(interface, objtype)
end
macro implements(dev::Symbol, interface, objtype)
    dev == :dev || error("3 arg version of `@implements must start with `dev`, and should only be used in testing")
    _implements_inner(interface, objtype; show=true)
end
function _implements_inner(interface, objtype; show=false)
    if interface isa Expr && interface.head == :curly
        interfacetype = interface.args[1]    
        optional_keys = interface.args[2]
    else
        interfacetype = interface
        optional_keys = ()
    end
    quote
        # Define a `implements` trait stating that `objtype` implements `interface`
        Interfaces.implements(::Type{<:$interfacetype}, ::Type{<:$objtype}) = true
        Interfaces.implements(T::Type{<:$interfacetype{Options}}, O::Type{<:$objtype}) where Options = 
            Interfaces._all_in(Options, Interfaces.optional_keys(T, O))
        # Define which optional components the object implements
        Interfaces.optional_keys(::Type{<:$interfacetype}, ::Type{<:$objtype}) = $optional_keys
        nothing
    end |> esc
end

_all_in(items::Tuple, collection) = all(map(in(collection), items))
_all_in(item::Symbol, collection) = in(item, collection)

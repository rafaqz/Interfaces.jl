
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
    test_object(::Type{<:Interface}, ::Type)

Return the test object for an `Interface` and type.
"""
function test_object end

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
        # Define a `implements` trait stating that `objtype` implements `interface`
        Interfaces.implements(::Type{<:$interfacetype}, ::Type{<:$objtype}) = true
        Interfaces.implements(T::Type{<:$interfacetype{Options}}, O::Type{<:$objtype}) where Options = 
            Interfaces._all_in(Options, Interfaces.optional_keys(T, O))
        # Define which optional components the object implements
        Interfaces.optional_keys(::Type{<:$interfacetype}, ::Type{<:$objtype}) = $optional_keys
        # Define the object to be used in interface tests
        Interfaces.test_object(::Type{<:$interfacetype}, ::Type{<:$objtype}) = $obj
        # Run tests during precompilation
        Interfaces.test($interface, $objtype; show=false)
    end |> esc
end

_all_in(items::Tuple, collection) = all(map(in(collection), items))
_all_in(item::Symbol, collection) = in(item, collection)

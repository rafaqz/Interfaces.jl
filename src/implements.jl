
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
implements(T::Type{<:Interface}, obj) = implements(T, typeof(obj))
implements(T::Type{<:Interface}, obj::Type) = inherits(T, obj)

function inherits end
inherits(::Type{<:Interface}, obj) = false

"""
    @implements(interface, objtype, test_objects)

Declare that an interface implements an interface, or multipleinterfaces.

The macro can only be used once per module for any one type. To define
multiple interfaces a type implements, combine them in square brackets.

# Example

Here we implement the IterationInterface for Base julia, indicating with
`(:indexing, :reverse)` that our object can be indexed and works with `Iterators.reverse`:

```julia
using BaseInterfaces, Interfaces
@implements BaseInterfaces.IterationInterface{(:indexing,:reverse)} MyObject [MyObject(1:10), MyObject(10:-1:1)]
```
"""
macro implements(interface, objtype, test_objects)
    _implements_inner(interface, objtype, test_objects)
end

inherited_type(::Type{<:Interface{<:Any,Inherits}}) where Inherits = Inherits
inherited_basetype(::Type{T}) where T = basetypeof(inherited_type(T))

inherited_optional_keys(::Type{<:Interface{Optional}}) where Optional = Optional 
Base.@assume_effects :foldable function inherited_optional_keys(::Type{T}) where T<:Union
    map(propertynames(T)) do  pn
        inherited_optional_keys(getproperty(T, pn))
    end
end
inherited_optional_keys(::Type) = ()

function inherited_interfaces(::Type{T}) where T <: Union
    map(propertynames(T)) do  pn
        t = getproperty(T, pn)
        inherited_optional_keys(t)
    end
end

function _implements_inner(interface, objtype, test_objects; show=false)
    if interface isa Expr && interface.head == :curly
        interfacetype = interface.args[1]    
        optional_keys = interface.args[2]
        # Allow a single Symbol instead of a Tuple
        if optional_keys isa QuoteNode
            optional_keys = (optional_keys.value,)
        end
    else
        interfacetype = interface
        optional_keys = ()
    end
    quote
        # Chreck that the type matches
        let objtype = $objtype, interface=$interface
            objtype <: Interfaces.requiredtype(interface) || throw(ArgumentError("$objtype is not a subtype of $(Interfaces.requiredtype(interface))"))  
        end
        # Define a `implements` trait stating that `objtype` implements `interface`
        $Interfaces.implements(::Type{<:$interfacetype}, ::Type{<:$objtype}) = true
        # Define implements with user-specified `Options` to check
        $Interfaces.implements(T::Type{<:$interfacetype{Options}}, O::Type{<:$objtype}) where Options = 
            $Interfaces._all_in(Options, $Interfaces.optional_keys(T, O))
        # Define a method using `inherited_basetype` to generate the type that 
        # will dispatch when another Interface inherits this Interface.
        function $Interfaces.inherits(::Type{T}, ::Type{<:$objtype}) where {T<:$Interfaces.inherited_basetype($interfacetype)}
            implementation_keys = $Interfaces.inherited_optional_keys($Interfaces.inherited_type($interfacetype))
            user_keys = $Interfaces._as_tuple($Interfaces._user_optional_keys(T))
            return all(map(in(implementation_keys), user_keys))
        end
        # Define which optional components the object implements
        $Interfaces.optional_keys(::Type{<:$interfacetype}, ::Type{<:$objtype}) = $optional_keys
        $Interfaces.test_objects(::Type{<:$interfacetype}, ::Type{<:$objtype}) = $test_objects
        nothing
    end |> esc
end

_user_optional_keys(::Type{<:Interface{Options}}) where Options = Options
_user_optional_keys(::Type{<:Interface}) = ()

_all_in(items::Tuple, collection) = all(map(in(collection), items))
_all_in(item::Symbol, collection) = in(item, collection)

_as_tuple(xs::Tuple) = xs
_as_tuple(x) = (x,)

struct Implemented{T<:Interface} end
struct NotImplemented{T<:Interface} end

Base.@assume_effects :foldable function basetypeof(::Type{T}) where T
    if T isa Union
        types = map(propertynames(T)) do pn
            t = getproperty(T, pn)
            getfield(parentmodule(t), nameof(t))
        end
        Union{types...}
    else
        getfield(parentmodule(T), nameof(T))
    end
end

"""
    implemented_trait(T::Type{<:Interface}, obj)
    implemented_trait(T::Type{<:Interface{Option}}, obj)

Provides a single type for using interface implementation
as a trait.

Returns `Implemented{T}()` or `NotImplemented{T}()`.
"""
function implemented_trait(::Type{T}, obj) where T<:Interface
    if implements(T, obj)
        Implemented{T}()
    else
        NotImplemented{T}()
    end
end

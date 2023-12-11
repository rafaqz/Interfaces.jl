
"""
    Interface{Components}

Abstract supertype for all Interfaces.jl interfaces.

Components is an `Tuple` of `Symbol`.
"""
abstract type Interface{Components,Inherits} end

"""
    optional_keys(T::Type{<:Interface}, O::Type)

Get the keys for the optional components of an [`Interface`](@ref),
as a tuple os `Symbol`.
"""
function optional_keys end
optional_keys(T::Type{<:Interface}, obj) = optional_keys(T, typeof(obj)) 
optional_keys(T::Type{<:Interface}, obj::Type) = ()
optional_keys(T::Type{<:Interface}) = keys(components(T).optional)

mandatory_keys(T::Type{<:Interface}, args...) = keys(components(T).mandatory)

"""
    test_objects(T::Type{<:Interface}, O::Type)

Get the test object(s) for type `O` and interface `T`.
"""
function test_objects end

"""
    description(::Type{<:Interface})

Returns a `String` description of an interface.
"""
function description end

"""
    components(::Type{<:Interface})

Returns the components of the interface, as a `NamedTuple` of `NamedTuple`.
"""
function components end

"""
    requiredtype(::Type{<:Interface})

Returns the supertype required for all interface implementations.
"""
function requiredtype end

"""
@interface(interfacename, components, [description])

Define an interface that can apply to types `<: Any`.

```julia
components = (
    mandatory = (
        length = x -> length(x) = prod(size(x)),
        ndims = x -> ndims(x) = length(size(x)),
    ),
    optional = (;)
)
description = "A description of the interface"

@interface MyInterface Any components description
```
"""
macro interface(interface_expr, type, components, description)
    _error(interface_expr) = throw(ArgumentError("$interface_expr not recognised as an interface type."))

    interface_expr = if interface_expr isa Symbol
        interface_type = interface_expr
        :(abstract type $interface_type{Components,Inherited} <: $Interfaces.Interface{Components,()} end)
    else
        interface_expr.head == :<: || _error(interface_expr)
        interface_type = interface_expr.args[1]
        inherits_expr = interface_expr.args[2]
        if inherits_expr isa Expr && inherits_expr.head == :curly
            inherits_type = inherits_expr.args[1]
            inherits_keys = inherits_expr.args[2]
            :(abstract type $interface_type{Components,Inherited} <: $inherits_type{Components,$inherits_keys} end)
        elseif inherits_expr isa Symbol
            inherits_type = inherits_expr
            :(abstract type $interface_type{Components,Inherited} <: $inherits_type{Components,()} end)
        else
            _error(interface_expr)
        end
    end

    quote
        @assert $type isa Type
        @assert $components isa NamedTuple{(:mandatory,:optional)}
        @assert $description isa String
        # Define the interface type (should it be concrete?)
        $interface_expr
        # Define the interface component methods
        $Interfaces.requiredtype(::Type{<:$interface_type}) = $type
        $Interfaces.components(::Type{<:$interface_type}) = $components
        $Interfaces.description(::Type{<:$interface_type}) = $description
        # Generate a docstring for the interface
        let description=$description,
            interface_sym=$(QuoteNode(interface_type)),
            m_keys=$Interfaces.mandatory_keys($interface_type),
            o_keys=$Interfaces.optional_keys($interface_type)
            @doc """
                $("   ") $interface_sym

            An Interfaces.jl `Interface` with mandatory components `$m_keys` and optional components `$o_keys`.

            $description
            """ $interface_type
        end
    end |> esc
end

_namedtuple_expr_err() = error("components must be defined in-line in the macro with both `mandatory` and `optional` fields, not passed as a variable. E.g. (; mandatory=(; x=x_predicate), optional=(; y=y_predicate))")

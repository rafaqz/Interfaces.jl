
"""
    Interface{Components}

Abstract supertype for all Interfaces.jl interfaces.

Components is an `Tuple` of `Symbol`.
"""
abstract type Interface{Components} end

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
macro interface(interface::Symbol, type, components, description)
    quote
        @assert $type isa Type
        @assert $components isa NamedTuple{(:mandatory,:optional)}
        @assert $description isa String
        # Define the interface type (should it be concrete?)
        abstract type $interface{Components} <: $Interfaces.Interface{Components} end
        # Define the interface component methods
        $Interfaces.requiredtype(::Type{<:$interface}) = $type
        $Interfaces.components(::Type{<:$interface}) = $components
        $Interfaces.description(::Type{<:$interface}) = $description
        # Generate a docstring for the interface
        let description=$description,
            interfacesym=$(QuoteNode(interface)),
            header=$Interfaces._help_header($interface),
            extended_help=$Interfaces._extended_help($interface)
            @doc """
                $("   ") $interfacesym

            $header

            $description

            $extended_help
            """ $interface 
        end
    end |> esc
end

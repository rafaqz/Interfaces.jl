
"""
    Interface{Components}

Abstract supertype for all Interfaces.jl interfaces.

Components is an `Tuple` of `Symbol`.
"""
abstract type Interface{Components} end

"""
    optional_keys(T::Type{<:Interface}, obj::Type)

Get the keys for the optional components of an [`Interface`](@ref),
as a tuple os `Symbol`.
"""
function optional_keys end
optional_keys(T::Type{<:Interface}, obj) = optional_keys(T, typeof(obj)) 
optional_keys(T::Type{<:Interface}, obj::Type) = ()
optional_keys(T::Type{<:Interface}) = keys(components(T).optional)

mandatory_keys(T::Type{<:Interface}, args...) = keys(components(T).mandatory)

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
@interface(interfacename, components, [description])

Define an interface.

```julia
components = (
    mandatory = (
        length = x -> length(x) = prod(size(x)),
        ndims = x -> ndims(x) = length(size(x)),
    ),
    optional = (;)
)
description = "A description of the interface"

@interface MyInterface components description
```
"""
macro interface(interface::Symbol, components, description)
    quote
        # Define the interface type (should it be concrete?)
        abstract type $interface{Components} <: $Interfaces.Interface{Components} end
        # Define the interface component methods
        @assert $components isa NamedTuple{(:mandatory,:optional)}
        $Interfaces.components(::Type{<:$interface}) = $components
        @assert $description isa String
        $Interfaces.description(::Type{<:$interface}) = $description
        # Generate a docstring for the interface
        let description=$description,
            interfacesym=$(QuoteNode(interface)),
            m_keys=$Interfaces.mandatory_keys($interface),
            o_keys=$Interfaces.optional_keys($interface)
            @doc """
                $("   ") $interfacesym

            An Interfaces.jl `Interface` with mandatory components `$m_keys` and optional components `$o_keys`.

            $description
            """ $interface 
        end
    end |> esc
end

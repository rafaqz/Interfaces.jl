
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
@interface MyInterface (
    mandatory = (
        length = x -> length(x) = prod(size(x)),
        ndims = x -> ndims(x) = length(size(x)),
    ),
    optional = (;)
) "A description of the interface"
```
"""
macro interface(interface, components::Expr, description::String="")
    if interface isa Symbol
        # Define the interface type (should it be concrete?)
        typedef = :(abstract type $interface{Components} <: Interfaces.Interface{Components} end)
        componentfunc = :(Interfaces.components(::Type{<:$interface}) = $components)
        T = interface
    else
        interface.head == :<: || throw(ArgumentError("Interface must be a single type or a subptyped `<:` type"))
        T = interface.args[1]
        if interface.args[2] isa Symbol 
            # No optional components become mandatory
            ST = interface.args[2]
            combined_components = quote
                (;
                    mandatory = (parent_components.mandatory..., child_components.mandatory...),
                    optional = (parent_components.optional..., child_components.optional...),
                )
            end
        else 
            # Some optinonal components for the parent are mandatory for the child
            interface.args[2].head == :curly || throw(ArgumentError("Supertype must be a plain type, or with options as the first type parameter: `SupertypeInterface{(:optional1, :optional2)}`"))
            ST, mandatory_parent_options = interface.args[2].args
            combined_components = quote
                mandatory_parent_options = $mandatory_parent_options
                optional_parent_options = reduce(keys(parent_components.optional); init=()) do acc, key
                    key in mandatory_parent_options ? acc : (acc..., key)
                end
                (
                    mandatory = (; 
                        parent_components.mandatory..., 
                        parent_components.optional[mandatory_parent_options]...,
                        child_components.mandatory...,
                    ),
                    optional = (; 
                        parent_components.optional[optional_parent_options]...,
                        child_components.optional...,
                    )
                )
            end
        end
        typedef = :(abstract type $T{Components} <: $ST{Components} end)
        componentfunc = quote
            function Interfaces.components(::Type{<:$T})
                child_components = $components
                parent_components = Interfaces.components($ST)
                return $combined_components
            end
        end
    end
    quote
        $typedef
        $componentfunc
        Interfaces.description(::Type{<:$T}) = $description
        # Generate a docstring for the interface
        let description=$description,
            interfacesym=$(QuoteNode(T)),
            m_keys=Interfaces.mandatory_keys($T),
            o_keys=Interfaces.optional_keys($T)
            @doc """
                $("   ") $interfacesym

            An Interfaces.jl `Interface` with mandatory components `$m_keys` and optional components `$o_keys`.

            $description
            """ $T
        end
    end |> esc
end

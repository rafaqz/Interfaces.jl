module InterfacesCore

export Interface, requiredtype, @interface_type

"""
    requiredtype(::Type{<:Interface})

Returns the supertype required for all interface implementations.
"""
function requiredtype end

"""
    Interface{Components}

Abstract supertype for all Interfaces.jl interfaces.

Components is an `Tuple` of `Symbol`.
"""

abstract type Interface{Components} end

macro interface_core(interface::Symbol, type)
    quote
        @assert $type isa Type
        abstract type $interface{Components} <: $InterfacesCore.Interface{Components} end
    end |> esc
end

end

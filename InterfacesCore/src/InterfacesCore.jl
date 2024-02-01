module InterfacesCore

export Interface, @interface_type

"""
    Interface{Components}

Abstract supertype for all Interfaces.jl interfaces.

Components is an `Tuple` of `Symbol`.
"""

abstract type Interface{Components} end

macro interface_type(interface::Symbol)
    :(abstract type $interface{Components} <: $InterfacesCore.Interface{Components} end) |> esc
end

end

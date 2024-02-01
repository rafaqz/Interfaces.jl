"""
    Interfaces

A Julia package for specifying and testing interfaces (conditions verified by a set of methods applied to a type).
"""
module Interfaces

using InterfacesCore

export Arguments
export @implements, @interface

include("arguments.jl")
include("interface.jl")
include("implements.jl")
include("test.jl")

end

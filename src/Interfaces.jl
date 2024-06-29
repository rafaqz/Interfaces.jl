"""
    Interfaces

A Julia package for specifying and testing interfaces (conditions verified by a set of methods applied to a type).
"""
module Interfaces

export Arguments
export @implements, @interface

include("arguments.jl")
include("interface.jl")
include("documentation.jl")
include("implements.jl")
include("test.jl")

end

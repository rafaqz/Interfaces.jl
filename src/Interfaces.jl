module Interfaces

@doc read(joinpath(dirname(@__DIR__), "README.md"), String) Interfaces

export @implements, @interface

include("interface.jl")
include("implements.jl")
include("test.jl")

end

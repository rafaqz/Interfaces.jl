# The AbstractString interface is not clearly documented and large.
#
# This discourse post likely has the best information, although outdated
# https://discourse.julialang.org/t/what-is-the-interface-of-abstractstring/8937/4
#
# See required methods here: https://github.com/JuliaLang/julia/blob/b88f64f16c454c238c9fa0ae858ca02b7084f329/base/strings/basic.jl#L41

@interface StringInterface AbstractString (;
    mandatory = (;
        ncodeunits = "ncodeunit returns an Int" => s -> ncodeunits(s) isa Int,
        iterate = "AbstractString follows the IterationInterface" => 
            s -> Interfaces.test(IterationInterface, s; show=false) && first(iterate(s)) isa AbstractChar,
        codeunit = "the first codeunit is a UInt8/16/32" => s -> codeunit(s, 1) isa Union{UInt8,UInt16,UInt32},
        isvalid = "isvalid returns a Bool" => s -> isvalid(s, 1) isa Bool,
        eltype = "eltype returns a type <: AbatractChar" => s -> eltype(s) <: AbstractChar,
    ),
    optional = (;
        length = "length return an Int" => s -> length(s) isa Int,
        # ?
    )
) """
`AbstractString` interface

Test objects must not be empty, so that `isempty(obj) == false`.
"""

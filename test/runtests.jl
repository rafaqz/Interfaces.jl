using Aqua
using Documenter
using Interfaces
using Test

@testset verbose = true "Interfaces.jl" begin
    doctest(Interfaces)
    @testset "Aqua" begin
        Aqua.test_all(Interfaces)
    end
    @testset "Animals" begin
        include("animals.jl")
    end
end

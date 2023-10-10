using Aqua
using Documenter
using Interfaces
using Test
using Aqua

@testset verbose = true "Interfaces.jl" begin
    # Formal tests
    doctest(Interfaces)
    @testset "Aqua" begin
        Aqua.test_all(Interfaces)
    end

    # Real tests
    @testset "Arguments" begin
        include("arguments.jl")
    end
    @testset "Basic" begin
        include("basic.jl")
    end
    @testset "Advanced" begin
        include("advanced.jl")
    end
end

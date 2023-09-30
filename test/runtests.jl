using Interfaces
using Test

@testset verbose = true "Interfaces.jl" begin
    @testset "Arguments" begin
        include("arguments.jl")
    end
    @testset "AnimalInterface" begin
        include("animalinterface.jl")
    end
    @testset "GroupInterface" begin
        include("groupinterface.jl")
    end
end

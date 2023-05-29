using BaseInterfaces
using Interfaces
using Test

@testset "BaseInterfaces.jl" begin
    @test Interfaces.test(IterationInterface, UnitRange, [1:5, -2:2])
    @test Interfaces.test(IterationInterface, StepRange, [1:2:10, 20:-10:-20])
    @test Interfaces.test(IterationInterface, Array, [[1, 2, 3, 4], [:a :b; :c :d]])
    @test Interfaces.test(IterationInterface, Base.Generator, [(i for i in 1:5), (i for i in 1:5)])
    @test Interfaces.test(IterationInterface, Tuple, [(1, 2, 3, 4)])
end

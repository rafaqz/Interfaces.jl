using BaseInterfaces
using Interfaces
using Test

@testset "ArrayInterface" begin
    @test Interfaces.test(ArrayInterface, Array, [[1, 2]])
    @test Interfaces.test(ArrayInterface, SubArray, [view([1, 2], 1:2)])
end

@testset "DictInterface" begin
    @test Interfaces.test(DictInterface, Dict, [Arguments(d=Dict(:a => 1, :b => 2), k=:c, v=3)])
    @test Interfaces.test(DictInterface, IdDict, [Arguments(d=IdDict(:a => 1, :b => 2), k=:c, v=3)])
    @test Interfaces.test(DictInterface, Base.EnvDict, [Arguments(d=Base.EnvDict())])
    @test Interfaces.test(DictInterface, Base.ImmutableDict, [Arguments(d=Base.ImmutableDict(:a => 1, :b => 2))])
    @test Interfaces.test(DictInterface, Base.Pairs, [Arguments(d=Base.pairs((a = 1, b = 2)))])
end

@testset "IterationInterface" begin
    @test Interfaces.test(IterationInterface, UnitRange, [1:5, -2:2])
    @test Interfaces.test(IterationInterface, StepRange, [1:2:10, 20:-10:-20])
    @test Interfaces.test(IterationInterface, Array, [[1, 2, 3, 4], [:a :b; :c :d]])
    @test Interfaces.test(IterationInterface, Base.Generator, [(i for i in 1:5), (i for i in 1:5)])
    @test Interfaces.test(IterationInterface, Tuple, [(1, 2, 3, 4)])
end

@testset "SetInterface" begin
    @test Interfaces.test(SetInterface, Set, [Set((1, 2))])
end

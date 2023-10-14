using BaseInterfaces
using Interfaces
using Test

@implements SetInterface{(:empty,:emptymutable,:hasfastin,:intersect,:union,:sizehint)} Test.GenericSet
@implements DictInterface Test.GenericDict

@testset "ArrayInterface" begin
    @test Interfaces.test(ArrayInterface, Array, [[3, 2], ['a' 'b'; 'n' 'm']])
    @test Interfaces.test(ArrayInterface, BitArray, [BitArray([false true; true false])])
    @test Interfaces.test(ArrayInterface, SubArray, [view([7, 2], 1:2)])
    @test Interfaces.test(ArrayInterface, PermutedDimsArray, [PermutedDimsArray([7 2], (2, 1))])
    @test Interfaces.test(ArrayInterface, Base.ReshapedArray, [reshape(view([7, 2], 1:2), 2, 1)])
    @test Interfaces.test(ArrayInterface, UnitRange, [2:10])
    @test Interfaces.test(ArrayInterface, StepRange, [2:1:10])
    @test Interfaces.test(ArrayInterface, Base.OneTo, [Base.OneTo(10)])
    @test Interfaces.test(ArrayInterface, Base.Slice, [Base.Slice(100:150)])
    @test Interfaces.test(ArrayInterface, Base.IdentityUnitRange, [Base.IdentityUnitRange(100:150)])
    @test Interfaces.test(ArrayInterface, Base.CodeUnits, [codeunits("abcde")])
    # No `getindex` defined for LogicalIndex
    @test_broken Interfaces.test(ArrayInterface, Base.LogicalIndex, [to_indices([1, 2, 3], ([false, true, true],))[1]])

    # TODO test LinearAlgebra arrays and SparseArrays
end

@testset "DictInterface" begin
    @test Interfaces.test(DictInterface, Dict, [Arguments(d=Dict(:a => 1, :b => 2), k=:c, v=3)])
    @test Interfaces.test(DictInterface, IdDict, [Arguments(d=IdDict(:a => 1, :b => 2), k=:c, v=3)])
    @test Interfaces.test(DictInterface, Base.EnvDict, [Arguments(d=Base.EnvDict())])
    @test Interfaces.test(DictInterface, Base.ImmutableDict, [Arguments(d=Base.ImmutableDict(:a => 1, :b => 2))])
    @test Interfaces.test(DictInterface, Base.Pairs, [Arguments(d=Base.pairs((a = 1, b = 2)))])
    @test Interfaces.test(DictInterface, Test.GenericDict, [Arguments(d=Test.GenericDict(Dict(:a => 1, :b => 2)), k=:c, v=3)])
    a = Ref(1); b = Ref(2)
    @test Interfaces.test(DictInterface, WeakKeyDict, [Arguments(d= d = WeakKeyDict(a => 1, b => 2), k=Ref(3), v=3)])
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
    @test Interfaces.test(SetInterface, BitSet, [BitSet((1, 2))])
    @test Interfaces.test(SetInterface, Base.KeySet, [Base.KeySet(Dict(:a=>1, :b=>2))])
    @test Interfaces.test(SetInterface, Test.GenericSet, [Test.GenericSet(Set((1, 2)))])
    # @test Interfaces.test(SetInterface, Base.IdSet, ?) 
end

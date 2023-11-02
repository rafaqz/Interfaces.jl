# Some example interface delarations.

# @implements ArrayInterface Base.LogicalIndex # No getindex


@implements ArrayInterface UnitRange [2:10]
@implements ArrayInterface StepRange [2:1:10]
@implements ArrayInterface Base.OneTo [Base.OneTo(10)]
@implements ArrayInterface Base.Slice [Base.Slice(100:150)]
@implements ArrayInterface Base.CodeUnits [codeunits("abcde")]
@implements ArrayInterface Base.IdentityUnitRange [Base.IdentityUnitRange(100:150)]
@implements ArrayInterface{(:setindex!,:similar_type,:similar_eltype,:similar_size)} Array [[3, 2], ['a' 'b'; 'n' 'm']]
@implements ArrayInterface{(:setindex!,:similar_type,:similar_size)} BitArray [BitArray([false true; true false])]
@implements ArrayInterface{:setindex!} SubArray [view([7, 2], 1:2)]
@implements ArrayInterface{:setindex!} PermutedDimsArray [PermutedDimsArray([7 2], (2, 1))]
@implements ArrayInterface{:setindex!} Base.ReshapedArray [reshape(view([7, 2], 1:2), 2, 1)]

@implements DictInterface{:setindex!} Dict [Arguments(d=Dict(:a => 1, :b => 2), k=:c, v=3)]
@implements DictInterface{:setindex!} IdDict [Arguments(d=IdDict(:a => 1, :b => 2), k=:c, v=3)]
# This errors because the ref is garbage collected?
# @implements DictInterface{:setindex!} WeakKeyDict [Arguments(; d=WeakKeyDict(Ref(1) => 1, Ref(2) => 2), k=Ref(3), v=3)]
@implements DictInterface Base.EnvDict [Arguments(d=Base.EnvDict())]
@implements DictInterface Base.ImmutableDict [Arguments(d=Base.ImmutableDict(:a => 1, :b => 2))]
@static if VERSION >= v"1.9.0"
    @implements DictInterface Base.Pairs [Arguments(d=Base.pairs((a = 1, b = 2)))]
end

@implements IterationInterface{(:reverse,:indexing)} UnitRange [1:5, -2:2]
@implements IterationInterface{(:reverse,:indexing)} StepRange [1:2:10, 20:-10:-20]
@implements IterationInterface{(:reverse,:indexing)} Array [[1, 2, 3, 4], [:a :b; :c :d]]
@implements IterationInterface{(:reverse,:indexing)} Tuple [(1, 2, 3, 4)]
@implements IterationInterface{(:reverse,:indexing)} NamedTuple [(a=1, b=2, c=3, d=4)]
# @implements IterationInterface{(:reverse,:indexing)} String
# @implements IterationInterface{(:reverse,:indexing)} Pair
# @implements IterationInterface{(:reverse,:indexing)} Number
# @implements IterationInterface{(:reverse,:indexing)} Base.EachLine
@implements IterationInterface{(:reverse,)} Base.Generator [(i for i in 1:5), (i for i in 1:5)]
# @implements IterationInterface Set
# @implements IterationInterface BitSet
# @implements IterationInterface IdDict
# @implements IterationInterface Dict
# @implements IterationInterface WeakKeyDict

# TODO add grouping to reduce the number of options
@implements SetInterface{(:copy,:empty,:emptymutable,:hasfastin,:setdiff,:intersect,:union,:empty!,:delete!,:push!,:copymutable,:sizehint!)} Set [Set((1, 2))]
@implements SetInterface{(:copy,:empty,:emptymutable,:hasfastin,:setdiff,:intersect,:union,:empty!,:delete!,:push!,:copymutable,:sizehint!)} BitSet [BitSet((1, 2))]
@implements SetInterface{(:empty,:emptymutable,:hasfastin,:intersect,:union,:sizehint!)} Base.KeySet [Base.KeySet(Dict(:a=>1, :b=>2))]
@implements SetInterface{(:empty,:hasfastin,:intersect,:union,:sizehint!)} Base.IdSet (s = Base.IdSet(); push!(s, "a"); push!(s, "b"); [s])

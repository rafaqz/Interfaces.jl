# Some example interface delarations.

# @implements ArrayInterface Base.LogicalIndex # No getindex
@implements ArrayInterface UnitRange
@implements ArrayInterface StepRange
@implements ArrayInterface Base.Slice
@implements ArrayInterface Base.IdentityUnitRange
@implements ArrayInterface Base.CodeUnits
@implements ArrayInterface{(:setindex!,:similar_type,:similar_eltype,:similar_size)} Array
@implements ArrayInterface{(:setindex!,:similar_type,:similar_size)} BitArray
@implements ArrayInterface{:setindex!} SubArray
@implements ArrayInterface{:setindex!} PermutedDimsArray
@implements ArrayInterface{:setindex!} Base.ReshapedArray

@implements DictInterface{:setindex!} Dict
@implements DictInterface{:setindex!} IdDict
@implements DictInterface{:setindex!} WeakKeyDict
@implements DictInterface Base.EnvDict
@implements DictInterface Base.ImmutableDict
# @implements DictInterface Base.Pairs - not on 1.6?

@implements IterationInterface{(:reverse,:indexing)} UnitRange
@implements IterationInterface{(:reverse,:indexing)} StepRange
@implements IterationInterface{(:reverse,:indexing)} Array
@implements IterationInterface{(:reverse,:indexing)} Tuple
@implements IterationInterface{(:reverse,:indexing)} NamedTuple
@implements IterationInterface{(:reverse,:indexing)} String
@implements IterationInterface{(:reverse,:indexing)} Pair
@implements IterationInterface{(:reverse,:indexing)} Number
@implements IterationInterface{(:reverse,:indexing)} Base.EachLine
@implements IterationInterface{(:reverse,)} Base.Generator
@implements IterationInterface Set
@implements IterationInterface BitSet
@implements IterationInterface IdDict
@implements IterationInterface Dict
@implements IterationInterface WeakKeyDict

# TODO add grouping to reduce the number of options
@implements SetInterface{(:copy,:empty,:emptymutable,:hasfastin,:setdiff,:intersect,:empty!,:delete!,:push!,:copymutable,:sizehint)} Set
@implements SetInterface{(:copy,:empty,:emptymutable,:hasfastin,:setdiff,:intersect,:empty!,:delete!,:push!,:copymutable,:sizehint)} BitSet
@implements SetInterface{(:empty,:emptymutable,:hasfastin,:intersect,:union,:sizehint)} Base.KeySet

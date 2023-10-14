module BaseInterfaces

using Interfaces

export ArrayInterface, DictInterface, IterationInterface, SetInterface

include("iteration.jl")
include("dict.jl")
include("set.jl")
include("array.jl")

# Some example interface delarations.

# @implements ArrayInterface Base.LogicalIndex # No getindex
@implements ArrayInterface UnitRange
@implements ArrayInterface StepRange
@implements ArrayInterface LinRange
@implements ArrayInterface Base.OneTo
@implements ArrayInterface Base.Slice
@implements ArrayInterface Base.IdentityUnitRange
@implements ArrayInterface Base.CodeUnits
@implements ArrayInterface{(:setindex!,:similar_type,:similar_eltype,:similar_size)} Array
@implements ArrayInterface{(:setindex!,:similar_type,:similar_size)} BitArray
@implements ArrayInterface{(:setindex!,)} SubArray
@implements ArrayInterface{(:setindex!,)} PermutedDimsArray
@implements ArrayInterface{(:setindex!,)} Base.ReshapedArray

@implements DictInterface{(:setindex,)} Dict
@implements DictInterface{(:setindex,)} IdDict
@implements DictInterface{(:setindex,)} WeakKeyDict
@implements DictInterface Base.EnvDict
@implements DictInterface Base.ImmutableDict
@implements DictInterface Base.Pairs

@implements IterationInterface{(:reverse,:indexing,)} UnitRange
@implements IterationInterface{(:reverse,:indexing,)} StepRange
@implements IterationInterface{(:reverse,:indexing,)} Array
@implements IterationInterface{(:reverse,)} Base.Generator
@implements IterationInterface{(:reverse,:indexing,)} Tuple

# TODO add grouping to reduce the number of options
@implements SetInterface{(:copy,:empty,:emptymutable,:hasfastin,:setdiff,:intersect,:empty!,:delete!,:push!,:copymutable,:sizehint)} Set
@implements SetInterface{(:copy,:empty,:emptymutable,:hasfastin,:setdiff,:intersect,:empty!,:delete!,:push!,:copymutable,:sizehint)} BitSet
@implements SetInterface{(:empty,:emptymutable,:hasfastin,:intersect,:union,:sizehint)} Base.KeySet

end

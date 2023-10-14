module BaseInterfaces

using Interfaces

export ArrayInterface, DictInterface, IterationInterface, SetInterface

include("iteration.jl")
include("dict.jl")
include("set.jl")
include("array.jl")

# Some example interface delarations.
@implements IterationInterface{(:reverse,:indexing,)} UnitRange
@implements IterationInterface{(:reverse,:indexing,)} StepRange
@implements IterationInterface{(:reverse,:indexing,)} Array
@implements IterationInterface{(:reverse,)} Base.Generator
@implements IterationInterface{(:reverse,:indexing,)} Tuple

@implements SetInterface Set

@implements DictInterface{(:setindex,)} Dict
@implements DictInterface{(:setindex,)} IdDict
# @implements DictInterface GenericDict
# @implements DictInterface{(:setindex,)} WeakKeyDict
@implements DictInterface Base.EnvDict
@implements DictInterface Base.ImmutableDict
@implements DictInterface Base.Pairs

# Some example interface delarations.
@implements ArrayInterface Base.LogicalIndex # No getindex
@implements ArrayInterface{(:getindex,)} UnitRange
@implements ArrayInterface{(:getindex,)} StepRange
@implements ArrayInterface{(:getindex,:setindex,)} Array
@implements ArrayInterface{(:getindex,:setindex,)} SubArray
@implements ArrayInterface{(:getindex,:setindex,)} PermutedDimsArray
@implements ArrayInterface{(:getindex,:setindex,)} Base.ReshapedArray

end

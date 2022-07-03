module BaseInterfaces

using Interfaces

export IterationInterface

include("iteration.jl")

@implements IterationInterface{(:reverse,:indexing,)} StepRange 1:2:10
@implements IterationInterface{(:reverse,:indexing,)} Array [1,2,3]
@implements IterationInterface{(:reverse,)} Base.Generator (i for i in 1:5)
@implements IterationInterface{(:reverse,:indexing,)} Tuple (1, 2, 3)

end

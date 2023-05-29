module BaseInterfaces

using Interfaces

export IterationInterface

include("iteration.jl")

# Some example interface delarations.
@implements IterationInterface{(:reverse,:indexing,)} UnitRange
@implements IterationInterface{(:reverse,:indexing,)} StepRange
@implements IterationInterface{(:reverse,:indexing,)} Array
@implements IterationInterface{(:reverse,)} Base.Generator
@implements IterationInterface{(:reverse,:indexing,)} Tuple

end

module BaseInterfaces

using Interfaces

export IterationInterface

include("iteration.jl")

# Some example interface delarations.
@implements IterationInterface{(:reverse,:indexing,)} UnitRange [1:5, -2:2]
@implements IterationInterface{(:reverse,:indexing,)} StepRange [1:2:10, 20:-10:-20]
@implements IterationInterface{(:reverse,:indexing,)} Array [[1, 2, 3, 4], [:a :b; :c :d]]
@implements IterationInterface{(:reverse,)} Base.Generator [(i for i in 1:5), (i for i in 1:5)]
@implements IterationInterface{(:reverse,:indexing,)} Tuple [(1, 2, 3, 4)]

end

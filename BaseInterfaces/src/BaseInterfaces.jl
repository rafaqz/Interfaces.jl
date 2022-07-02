module BaseInterfaces

using Interfaces

include("iterators.jl")

@implements IteratorInterface StepRange 
@implements IteratorInterface Array 
@implements IteratorInterface Generator
@implements IteratorInterface Tuple

end

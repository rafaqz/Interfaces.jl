module BaseInterfaces

using Interfaces

export Interfaces

export ArrayInterface, DictInterface, IterationInterface, SetInterface

include("iteration.jl")
include("dict.jl")
include("set.jl")
include("array.jl")

include("implementations.jl")

end

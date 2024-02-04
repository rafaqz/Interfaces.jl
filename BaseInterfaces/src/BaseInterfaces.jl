module BaseInterfaces

using Interfaces

import Interfaces: test, test_objects, implements, description, components, requiredtype, @implements

export Interfaces

export ArrayInterface, DictInterface, IterationInterface, SetInterface

include("interfaces/iteration.jl")
include("interfaces/dict.jl")
include("interfaces/set.jl")
include("interfaces/array.jl")

include("implementations/iteration.jl")
include("implementations/dict.jl")
include("implementations/set.jl")
include("implementations/array.jl")

end

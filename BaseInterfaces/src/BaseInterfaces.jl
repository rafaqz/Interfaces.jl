module BaseInterfaces

using Interfaces

import Interfaces: test, test_objects, implements, description, components, requiredtype, @implements

export Interfaces

export ArrayInterface, DictInterface, IterationInterface, SetInterface, StringInterface

include("interfaces/iteration.jl")
include("interfaces/dict.jl")
include("interfaces/set.jl")
include("interfaces/array.jl")
include("interfaces/string.jl")

include("implementations/iteration.jl")
include("implementations/dict.jl")
include("implementations/set.jl")
include("implementations/array.jl")
include("implementations/string.jl")

end

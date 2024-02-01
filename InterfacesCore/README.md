# BaseInterfaces

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://rafaqz.github.io/Interfaces.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://rafaqz.github.io/Interfaces.jl/dev/)
[![Build Status](https://github.com/rafaqz/Interfaces.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/rafaqz/Interfaces.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/rafaqz/Interfaces.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/rafaqz/Interfaces.jl)

BaseInterfaces.jl is a subpackage of Interfaces.jl that provides predifined 
definition and testing for Base Julia interfaces.

Currently this includes:
- A general iteration interface: `IterationInterface`
- `AbstractArray` interface: `ArrayInterface`
- `AbstractSet` interface: `SetInterface`
- `AbstractDict` interface: `DictInterface`


Testing your object follows the interfaces is as simple as:

```julia
using BaseInterfaces, Interfaces
Interfaces.tests(DictInterface, MyDict, [mydict1, mydict2, ...])
```

Declaring that it follows the interface is done with:

```julia
@implements DictInterface{(:component1, :component2)} MyDict
```

Where components can be chosen from `Interfaces.optional_keys(DictInterface)`.

See [the docs](https://rafaqz.github.io/Interfaces.jl/stable/) for use.

If you want to add more Base julia interfaces here, or think the existing 
ones could be improved, please make an issue or pull request.

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
- `AbstractString` interface: `StringInterface`

None of these should be considered either complete or authoritative,
but they may be helpful in testing your objects basically conform.
Please make issues and PRs with missing behaviours if you find them.

Declaring that it follows the interface is done with:

```julia
@implements DictInterface{(:component1, :component2)} MyDict [MyDict(some_values...), MyDict(other_values...)]
```

Optional components can be chosen from `Interfaces.optional_keys(DictInterface)`.

After this you can easily test it with:

```julia
Interfaces.test(DictInterface, MyDict)
```

See [the docs](https://rafaqz.github.io/Interfaces.jl/stable/) for use.

If you want to add more Base julia interfaces here, or think the existing 
ones could be improved, please make an issue or pull request.

# Interfaces

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://rafaqz.github.io/Interfaces.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://rafaqz.github.io/Interfaces.jl/dev/)
[![Build Status](https://github.com/rafaqz/Interfaces.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/rafaqz/Interfaces.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/rafaqz/Interfaces.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/rafaqz/Interfaces.jl)

Macros for defining the required behaviours of Julia interfaces,
and stating that an object implements them.

The goal is to get as much as possible out of defining an interface,
specifically: 

- Traits: All `@implements` declarations produce compile-time traits that can be
  checked by other packages - for the whole interface and all of it's optional
  components.
- Tests: `@implements` declarations are automatically tested againts the interfaces
  and subtypes they define, during precompilation. 
- Docs: interface documentation can be inserted into trait documentation.

## Example

See the `IterationInterface` in BaseInterfaces.jl (a subpackage of this package)
for examples of `@interface` and `@implements`.

But heres an examples using Animals, and the implementation of a Duck.

```julia
module Animals

@interface AnimalInterface begin
    # tests
    @mandatory :age begin
        x -> age(x) isa Int
    end
    @optional :walk begin
        # Return a tuple of functions
        x -> walk(x) isa String
    end
    @optional :talk begin
        x -> talk(x) isa Symbol
    end
    @optional :dig begin
        x -> dig(x) isa String
    end
end
```

The we can create a Duck and state that it implements the Animals interface:

```julia
using Animals

"""
    Duck

$(Interfaces.@document Duck AnimalInterface)
"""
struct Duck
    age::Int
end

Animals.age(duck::Duck) = duck.age
Animals.walk(::Duck) = "waddle"
Animals.talk(::Duck) = :quack

@implements Duck AnimalInterface{(:)} Duck() 
```


And we get a bunch of functions to use as traits and test the interface with:

```julia
julia> Interfaces.implements(AnimalInterface{:walk}, Duck)
true

julia> Interfaces.implements(AnimalInterface{:dig}, Duck)
false

# We can get the functions for any interface component tests
julia> Interfaces.conditions(AnimalInterface{:dig})
(var"#3#4"(),)

# And test them
julia> Interfaces.test(AnimalInterface{(:walk,:talk)}, Duck)
true

julia> Interfaces.test(AnimalInterface{:dig}, Duck)
false
```

By the way, none of this works at all yet! but soon it will. 
If you think it should behave differently or there is better syntax,
please make an issue.

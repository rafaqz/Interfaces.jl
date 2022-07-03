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

using Interfaces

function age end
function walk end
function talk end
function dig end

#= @interface takes two argumens
1. The name of the interface, which should usingaally take the form "_____Interface"
2. The `mandatory` and `optional` components of the interface written as a `NamedTuple`,
  with functions or tuple of functions that test them. These will soon include objects
  from Invariants.jl - the idea is to add allow error messages from another package,
  but accept simple `Bool` return values.
=#
@interface AnimalInterface (
    mandatory = (
        age = (
            x -> age(x) isa Real, 
            x -> age(x) >= 0,
        )
    )
,
    optional = (
        walk = x -> walk(x) isa String,
        talk = x -> talk(x) isa Symbol,
        dig = x -> dig(x) isa String,
    )
)

end
```

The we can create a Duck and state that it implements the Animals interface:

```julia
using Animals, Interfaces

struct Duck
    age::Int
end

Animals.age(duck::Duck) = duck.age
Animals.walk(::Duck) = "waddle"
Animals.talk(::Duck) = :quack

#= @implements takes three arguments.
1. The interface type, with a tuple of optional components in
  its first type parameter. 
2. The the type of the object implementing the interface
3. Some code that defines an instance of that type that can be used in tests.  =#

@implements AnimalInterface{(:walk, :talk)} Duck Duck(2)
```


And we get a bunch of functions to use as traits and test the interface with:

```julia
julia> Interfaces.implements(AnimalInterface{:walk}, Duck)
true

julia> Interfaces.implements(AnimalInterface{:dig}, Duck)
false

# We can test the interface
julia> Interfaces.test(AnimalInterface, Duck)
true

# Or components of it:
julia> Interfaces.test(AnimalInterface{(:walk,:talk)}, Duck)
true

julia> Interfaces.test(AnimalInterface{:dig}, Duck)
false

# Test another object
struct Chicken end

julia> Interfaces.implements(Animals.AnimalInterface, Chicken()) 
false
```

If you think it should behave differently or there is better syntax,
please make an issue.

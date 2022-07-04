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

First we define the interface methods, and a list of mandatory and
optional properties of the interface, with conditions, using the `@interface`
macro.

The `@interface` macro takes two argumens
1. The name of the interface, which should usingaally end with "Interface"
2. The `mandatory` and `optional` components of the interface written as a `NamedTuple`,
  with functions or tuple of functions that test them. These will soon include objects
  from Invariants.jl - the idea is to add allow error messages from packages
  built for that, but alse accept simple anonymous functions with `Bool` return values.

```julia
module Animals

using Interfaces

# Define the methods the interface uses
function age end
function walk end
function talk end
function dig end

# Define the interface conditions
@interface AnimalInterface (
    mandatory = (;
        age = (
            x -> age(x) isa Real,
            x -> age(x) >= 0,
        )
    ),
    optional = (;
        walk = x -> walk(x) isa String,
        talk = x -> talk(x) isa Symbol,
        dig = x -> dig(x) isa String,
    ),
)

end
```

Now we can implement the AnimalInterface, for a Duck.

The `@implements` macro takes three arguments.
1. The interface type, with a tuple of optional components in
  its first type parameter. 
2. The the type of the object implementing the interface
3. Some code that defines an instance of that type that can be used in tests. 

```julia
using Interfaces

# Define our Duck object
struct Duck
    age::Int
end

# And extend Animals methods for it
Animals.age(duck::Duck) = duck.age
Animals.walk(::Duck) = "waddle"
Animals.talk(::Duck) = :quack

# And define the interface
@implements Animals.AnimalInterface{(:walk, :talk)} Duck Duck(2)
```

Now we have some methods we can use as traits, and test the interface with:

```julia
julia> Interfaces.implements(Animals.AnimalInterface{:walk}, Duck)
true

julia> Interfaces.implements(Animals.AnimalInterface{:dig}, Duck)
false

# We can test the interface
julia> Interfaces.test(Animals.AnimalInterface, Duck)
true

# Or components of it:
julia> Interfaces.test(Animals.AnimalInterface{(:walk,:talk)}, Duck)
true

# Test another object
struct Chicken end

julia> Interfaces.implements(Animals.AnimalInterface, Chicken()) 
false
```

If you think it should behave differently or there is better syntax,
please make an issue.

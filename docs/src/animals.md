```@meta
EditURL = "../../test/animals.jl"
```

# Single-argument interface

Here's an examples using animals, and the implementation of a duck.

## Definition

First we define the interface methods, and a list of mandatory and
optional properties of the interface, with conditions, using the `@interface`
macro.

The `@interface` macro takes three arguments:
1. The name of the interface, which should usully end with "Interface"
2. The `mandatory` and `optional` components of the interface written as a `NamedTuple`, with functions or tuple of functions that test them.
3. The interface docstring (the interface is represented as a type)

````@example animals
module Animals

using Interfaces

function age end
function walk end
function talk end
function dig end

@interface AnimalInterface (
    mandatory = (
        age = (
             "all animals have a `Real` age" => x -> age(x) isa Real,
             "all animals have an age larger than zero" => x -> age(x) >= 0,
        ),
    ),
    optional = (
        walk = "this animal can walk" => x -> walk(x) isa String,
        talk = "this animal can talk" => x -> talk(x) isa Symbol,
        dig = "this animal can dig" => x -> dig(x) isa String,
    )
) """
Defines a generic interface for animals to do the things they do best.
"""

end;
nothing #hide
````

## Implementation

````@example animals
using Interfaces
````

Now we implement the `AnimalInterface`, for a `Duck`.

````@example animals
struct Duck
    age::Int
end

Animals.age(duck::Duck) = duck.age
Animals.walk(::Duck) = "waddle"
Animals.talk(::Duck) = :quack
````

We then test that the interface is correctly implemented

````@example animals
ducks = [Duck(1), Duck(2)]
Interfaces.test(Animals.AnimalInterface, Duck, ducks)
````

Finally we declare it, so that the information can be used in static dispatch.

The `@implements` macro takes two arguments.
1. The interface type, with a tuple of optional components in its first type parameter.
2. The type for which the interface is implemented.

````@example animals
@implements Animals.AnimalInterface{(:walk,:talk)} Duck
````

Now let's see what happens when the interface is not correctly implemented.

````@example animals
struct Chicken end
````

As expected, the tests fail

````@example animals
chickens = [Chicken()]
try
    Interfaces.test(Animals.AnimalInterface, Chicken, chickens)
catch e
    print(e)
end
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*


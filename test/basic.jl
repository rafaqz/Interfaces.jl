# # Basic

# Here's an example of single-argument interface using animals, and the implementation of a duck.

# ## Definition

#=
First we define the interface methods, and a list of mandatory and
optional properties of the interface, with conditions, using the `@interface`
macro.

The `@interface` macro takes three arguments:
1. The name of the interface, which should usully end with "Interface"
2. The `mandatory` and `optional` components of the interface written as a `NamedTuple`, with functions or tuple of functions that test them.
3. The interface docstring (the interface is represented as a type)
=#

module Animals

using Interfaces

abstract type Animal end

function age end
function walk end
function talk end
function dig end

components = (
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
)

description = """
Defines a generic interface for animals to do the things they do best.
"""

@interface AnimalInterface Animal components description

end;

# ## Implementation

using Interfaces

# Now we implement the `AnimalInterface`, for a `Duck`.

struct Duck <: Animals.Animal
    age::Int
end

Animals.age(duck::Duck) = duck.age
Animals.walk(::Duck) = "waddle"
Animals.talk(::Duck) = :quack

# We then test that the interface is correctly implemented

ducks = [Duck(1), Duck(2)]
Interfaces.test(Animals.AnimalInterface, Duck, ducks)

# As well as two optional methods

Interfaces.test(Animals.AnimalInterface{(:walk,:talk)}, Duck, ducks)

#=
Finally we declare it, so that the information can be used in static dispatch.

The `@implements` macro takes two arguments.
1. The interface type, with a tuple of optional components in its first type parameter. 
2. The type for which the interface is implemented.
=#

@implements Animals.AnimalInterface{(:walk,:talk)} Duck [Duck(1), Duck(2)]

# Now let's see what happens when the interface is not correctly implemented.
struct Chicken <: Animals.Animal end

# As expected, the tests fail
chickens = 
try
    Interfaces.test(Animals.AnimalInterface, Chicken)
catch e
    print(e)
end

# The following tests are not included in the docs  #src

using Test  #src

@testset "Duck" begin  #src
    @test Interfaces.implements(Animals.AnimalInterface, Duck) == true  #src
    @test Interfaces.implements(Animals.AnimalInterface{:dig}, Duck) == false  #src
    @test Interfaces.test(Animals.AnimalInterface, Duck, ducks) == true  #src
    @test Interfaces.test(Animals.AnimalInterface{(:walk,:talk)}, Duck, ducks) == true  #src
    # TODO wrap errors somehow, or just let Invariants.jl handle that.  #src
    @test_throws Interfaces.InterfaceError Interfaces.test(Animals.AnimalInterface{:dig}, Duck, ducks)  #src
end  #src

@testset "Chicken" begin  #src
    @test Interfaces.implements(Animals.AnimalInterface{(:walk,:talk)}, Chicken()) == false  #src
    @test_throws Interfaces.InterfaceError Interfaces.test(Animals.AnimalInterface{(:walk,:talk)}, Chicken())  #src
end  #src

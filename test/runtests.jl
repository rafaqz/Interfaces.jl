using Interfaces
using Test

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

end

struct Duck
    age::Int
end

Animals.age(duck::Duck) = duck.age
Animals.walk(::Duck) = "waddle"
Animals.talk(::Duck) = :quack

@implements dev Animals.AnimalInterface{(:walk,:talk)} Duck

@testset "duck" begin
    ducks = [Duck(1), Duck(2)]
    @test Interfaces.implements(Animals.AnimalInterface, Duck) == true
    @test Interfaces.implements(Animals.AnimalInterface, first(ducks)) == true
    @test Interfaces.implements(Animals.AnimalInterface{:dig}, Duck) == false
    @test Interfaces.implements(Animals.AnimalInterface{:dig}, first(ducks)) == false
    @test @inferred Interfaces.implemented_trait(Animals.AnimalInterface{:walk}, Duck) == Interfaces.Implemented{Animals.AnimalInterface{:walk}}()
    @test @inferred Interfaces.implemented_trait(Animals.AnimalInterface{:walk}, first(ducks)) == Interfaces.Implemented{Animals.AnimalInterface{:walk}}()
    @test @inferred Interfaces.implemented_trait(Animals.AnimalInterface{:dig}, Duck) == Interfaces.NotImplemented{Animals.AnimalInterface{:dig}}()
    @test @inferred Interfaces.implemented_trait(Animals.AnimalInterface{:dig}, first(ducks)) == Interfaces.NotImplemented{Animals.AnimalInterface{:dig}}()
    @test Interfaces.test(Animals.AnimalInterface, Duck, ducks) == true
    @test Interfaces.test(Animals.AnimalInterface{(:walk,:talk)}, Duck, ducks) == true
    # TODO wrap errors somehow, or just let Invariants.jl handle that.
    @test_throws MethodError Interfaces.test(Animals.AnimalInterface{:dig}, Duck, ducks)
end

struct Chicken end

@testset "chicken" begin
    @test Interfaces.implements(Animals.AnimalInterface{(:walk,:talk)}, Chicken()) == false
    @test_throws MethodError Interfaces.test(Animals.AnimalInterface{(:walk,:talk)}, Chicken())
end

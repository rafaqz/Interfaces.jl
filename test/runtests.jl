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

@implements dev Animals.AnimalInterface{(:walk,:talk)} Duck [Duck(1), Duck(2)]

@testset "duck" begin
    @test Interfaces.implements(Animals.AnimalInterface, Duck) == true
    @test Interfaces.implements(Animals.AnimalInterface{:dig}, Duck) == false
    @test Interfaces.test(Animals.AnimalInterface, Duck) == true
    @test Interfaces.test(Animals.AnimalInterface{(:walk,:talk)}, Duck) == true
    # TODO wrap errors somehow, or just let Invariants.jl handle that.
    @test_throws MethodError Interfaces.test(Animals.AnimalInterface{:dig}, Duck)
end

struct Chicken end

@testset "chicken" begin
    @test Interfaces.implements(Animals.AnimalInterface{(:walk,:talk)}, Chicken()) == false
    @test_throws MethodError Interfaces.test(Animals.AnimalInterface{(:walk,:talk)}, Chicken())
end

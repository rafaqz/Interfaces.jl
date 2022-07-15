using Interfaces
using Test

module Organisms

using Interfaces

function age end

function source end
abstract type Origin end
struct Spore <: Origin end
struct Seed <: Origin end
struct Egg <: Origin end
struct LiveBirth <: Origin end

# We implement an OrganismInterface with a mandatory component :age
# and and optional component :source
@interface OrganismInterface (
    mandatory = (
        age = (
             "all organisms have a `Real` age" => x -> age(x) isa Real,
             "all organisms have an age larger than zero" => x -> age(x) >= 0,
        ),
    ),
    optional = (
        source = "this organism starts from some source" => x -> source(x) isa Origin,
    )
) """
Defines a generic interface for any organism.
"""

function walk end
function talk end
function dig end

# We implement AnimalInterface as an OrganismInterface with the mandatory component
# :age and the optional component :source both now mandatory.
# No completely new mandatory components are added, but we add new optional
# components :walk, :talk and :dig.
@interface AnimalInterface <: OrganismInterface{(:source,)} (
    mandatory = (),
    optional = (
        walk = "this animal can walk" => x -> walk(x) isa String,
        talk = "this animal can talk" => x -> talk(x) isa Symbol,
        dig = "this animal can dig" => x -> dig(x) isa String,
    )
) """
Defines a generic interface for animals to do the things they do best.
"""

end

@testset "interfaces" begin
    organism_components = Interfaces.components(Organisms.OrganismInterface)
    animal_components = Interfaces.components(Organisms.AnimalInterface)
    @test keys(organism_components.mandatory) == (:age,)
    @test keys(organism_components.optional) == (:source,)
    @test keys(animal_components.mandatory) == (:age, :source,)
    @test keys(animal_components.optional) == (:walk, :talk, :dig,)
end

struct Duck
    age::Int
end

Organisms.age(duck::Duck) = duck.age
Organisms.source(duck::Duck) = Organisms.Egg()
Organisms.walk(::Duck) = "waddle"
Organisms.talk(::Duck) = :quack

@implements dev Organisms.AnimalInterface{(:walk,:talk)} Duck [Duck(1), Duck(2)]

@testset "duck" begin
    @test Interfaces.implements(Organisms.AnimalInterface, Duck) == true
    @test Interfaces.implements(Organisms.AnimalInterface{:age}, Duck) == true
    @test Interfaces.implements(Organisms.AnimalInterface{:source}, Duck) == true
    @test Interfaces.implements(Organisms.AnimalInterface{:dig}, Duck) == false
    @test Interfaces.test(Organisms.AnimalInterface, Duck) == true
    @test Interfaces.test(Organisms.AnimalInterface{(:walk,:talk)}, Duck) == true
    # TODO wrap errors somehow, or just let Invariants.jl handle that.
    @test_throws MethodError Interfaces.test(Organisms.AnimalInterface{:dig}, Duck)
end

struct Chicken end

@testset "chicken" begin
    @test Interfaces.implements(Organisms.AnimalInterface{(:walk,:talk)}, Chicken()) == false
    @test_throws MethodError Interfaces.test(Organisms.AnimalInterface{(:walk,:talk)}, Chicken())
end

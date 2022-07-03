using Interfaces
using Test

module Animals

using Interfaces, Invariants

using Invariants: invariant, md

function age end
function walk end
function talk end
function dig end

@interface AnimalInterface begin
    (
        mandatory = (
            age = (
                 x -> age(x) isa Real,
                 x -> age(x) >= 0,
            ),
        ),
        optional = (
            walk = (invariant("`walk` returns a `String`") do x
                walk(x) isa String ? nothing : md("return value is not a `String`")
            end,
            invariant("`walk` returns a `String`") do x
                walk(x) isa String ? nothing : md("return value is not a `String`")
            end,),
            talk = invariant("`talk` returns a `Symbol`") do x
                talk(x) isa Symbol ? nothing : md("return value is not a `Symbol`")
            end,
            dig = invariant("`dig` returns a `String`") do x
                dig(x) isa String ? nothing : md("return value is not a `String`")
            end,
        )
    )
end

end


struct Duck
    age::Int
end

Animals.age(duck::Duck) = duck.age
Animals.walk(::Duck) = "waddle"
Animals.talk(::Duck) = :quack

@implements Animals.AnimalInterface{(:walk,:talk)} Duck Duck(1)

@doc Interfaces.document(Animals.AnimalInterface, Duck) Duck

Interfaces.implementing_module(Animals.AnimalInterface, Duck)

@testset "duck" begin
    @test Interfaces.implements(Animals.AnimalInterface, Duck) == true
    @test Interfaces.implements(Animals.AnimalInterface{:dig}, Duck) == false
    @test Interfaces.test(Animals.AnimalInterface, Duck) == true
    @test Interfaces.test(Animals.AnimalInterface{(:walk,:talk)}, Duck) == true
    # TODO wrap errors somehow, or just let Invariants.jl handle that.
    @test_throws MethodError Interfaces.test(Animals.AnimalInterface{:dig}, Duck)

    struct Chicken end

    @test Interfaces.implements(Animals.AnimalInterface{(:walk,:talk)}, Chicken()) == false
end

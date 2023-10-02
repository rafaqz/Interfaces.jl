using Interfaces
using Interfaces: first_field_type
using Test

ks = (:x, :y, :z)
vs = (1, 2.0, "3")

a = Arguments(x = 1, y = 2.0, z = "3")

a2 = Arguments{ks}(vs)
@test a == a2

@test keys(a) == (:x, :y, :z)
@test values(a) == (1, 2.0, "3")
@test length(a) == 3
@test collect(a) == [1, 2.0, "3"]

@test haskey(a, :x)
@test haskey(a, 1)
@test !haskey(a, :w)
@test !haskey(a, 4)

@test a.x == 1
@test a[:x] == 1
@test a[1] == 1
@test a[:] == a

@test first_field_type(typeof(a)) == Int

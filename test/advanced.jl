using Interfaces
using Test

module Group

using Interfaces

function neutral end
function multiplication end
function inversion end

@interface GroupInterface (
    mandatory = (;
        neutral_check = (
            "neutral stable" => a::Arguments -> neutral(a.x) isa typeof(a.x),
        ),
        multiplication_check = (
            "multiplication stable" => a::Arguments -> multiplication(a.x, a.y) isa typeof(a.x),
        ),
        inversion_check = (
            "inversion stable" => a::Arguments -> inversion(a.x) isa typeof(a.x),
            "inversion works" => a::Arguments -> multiplication(a.x, inversion(a.x)) ≈ neutral(typeof(a.x)),
        ),
    ),
    optional = (;
        abelian = (
            "multiplication commutes" => a::Arguments -> multiplication(a.x, a.y) ≈ multiplication(a.y, a.x),
        ),
    )
) """
A group is a set of elements with a neutral element where you can perform multiplications and inversions.
"""

end

Group.neutral(x::Number) = zero(x)
Group.multiplication(x::Number, y::Number) = x + y
Group.inversion(x::Number) = -x

@implements dev Group.GroupInterface{(:abelian,)} Number

@test Interfaces.implements(Group.GroupInterface{(:abelian,)}, Number)

number_pairs = [
    Arguments(x=rand(1:10), y=rand(1:10)),
    Arguments(x=rand(), y=rand()),
]
@test Interfaces.test(Group.GroupInterface{(:abelian,)}, Number, number_pairs)

bad_pairs = [
    Arguments(x=rand(2, 3), y=rand(2, 3)),  # the first type is not a number
]
@test_throws ArgumentError Interfaces.test(Group.GroupInterface, Number, bad_pairs)

bad_pairs = [
    Arguments(x=1, y=rand(2, 3)),  # the operations are ill defined
]
@test_throws MethodError Interfaces.test(Group.GroupInterface, Number, bad_pairs)

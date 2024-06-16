# # Advanced

#=
Here's an example of a multi-argument interface where we implement _groups_.
For mathematicians, a group is just a set of objects where you can perform `multiplication` and `inversion`, such that an element multiplied by its inverse yields a `neutral` element.

!!! warning "Warning"
    This functionality is still experimental and might evolve in the future.
    If you have feedback about it, open an issue to help us improve it!
=#

using Interfaces

# ## Definition

#=
Unlike the `AnimalInterface`, this example involves functions with more than one argument.
Such arguments need to be passed to the interface testing code, which means the interface definition must take them into account as well.

For technical reasons, we provide a type called `Arguments` that you should use for this purpose.
It behaves exactly like a `NamedTuple` but enables easier dispatch.
=#

module Group

using Interfaces

function neutral end
function multiplication end
function inversion end

@interface GroupInterface Number (
    mandatory = (;
        neutral_check = (
            "neutral stable" => a::Arguments -> neutral(typeof(a.x)) isa typeof(a.x),
        ),
        multiplication_check = (
            "multiplication stable" => a::Arguments -> multiplication(a.x, a.y) isa typeof(a.x),
        ),
        inversion_check = (
            "inversion stable" => a::Arguments -> inversion(a.x) isa typeof(a.x),
            "inversion works" => a::Arguments -> multiplication(a.x, inversion(a.x)) ≈ neutral(typeof(a.x)),
        ),
    ),
    optional = (;),
) """
A group is a set of elements with a neutral element where you can perform multiplications and inversions.

The conditions checking the interface accept an `Arguments` object with two fields named `x` and `y`.
The type of the first field `x` must be the type you wish to declare as implementing `GroupInterface`.
"""

end;

# ## Implementation

# Let's try to see if our favorite number types do indeed behave like a group.

Group.neutral(::Type{N}) where {N<:Number} = one(N)
Group.multiplication(x::Number, y::Number) = x * y
Group.inversion(x::Number) = inv(x)

# First, we check it for floating point numbers, giving a list of `Arguments` objects with the proper fields to the `test` function.

float_pairs = [Arguments(x = 2.0, y = 1.0)]
Interfaces.test(Group.GroupInterface, Float64, float_pairs)

# We can thus declare proudly

@implements Group.GroupInterface Float64 [Arguments(x = 2.0, y = 1.0)]

#=
Now we check it for integer numbers.
The reason it fails is because for an integer `x`, the inverse `1/x` is no longer an integer!
Thus integer numbers are not a multiplicative group.
=#

int_pairs = [Arguments(x = 2, y = 1)]
Interfaces.test(Group.GroupInterface, Int, int_pairs)

#=
What happens if we give an input whose field types (`Int`) are not coherent with the type we are testing (`Float64`)?
=#

try
    Interfaces.test(Group.GroupInterface, Float64, int_pairs)
catch e
    print(e.msg)
end

#=
In summary, there are two things to remember:

1. The anonymous functions in the interface conditions of `Interfaces.@interface` should accept a single object of type `Arguments` and then work with its named fields. These fields should be listed in the docstring.
2. The list of objects passed to `Interface.test` must all be of type `Arguments`, with the right named fields. At least one field must have the type you are testing.
=#

# The following tests are not part of the docs  #src

using Test  #src

@test Interfaces.test(Group.GroupInterface, Float64)  #src
@test !Interfaces.test(Group.GroupInterface, Int, int_pairs)  #src
@test_throws ArgumentError Interfaces.test(Group.GroupInterface, Float64, int_pairs)  #src

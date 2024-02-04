# Some example interface delarations.

# @implements ArrayInterface Base.LogicalIndex # No getindex

@implements ArrayInterface{:logical} UnitRange [2:10]
@implements ArrayInterface{:logical} StepRange [2:1:10]
@implements ArrayInterface{:logical} Base.OneTo [Base.OneTo(10)]

# @implements ArrayInterface Base.Slice [Base.Slice(100:150)]
# These are breaking unreliably in CI. No idea how this can work sometimes and not others...
#
# Testing ArrayInterface is implemented for Base.IdentityUnitRange
# InterfaceError: test for ArrayInterface :getindex 19 "Can index with a Vector of Int32" threw a BoundsError 
#  For test object Base.IdentityUnitRange(100:150):

# Error During Test at /home/runner/work/Interfaces.jl/Interfaces.jl/BaseInterfaces/test/runtests.jl:10
#   Test threw exception
#   Expression: Interfaces.test()
#   BoundsError: attempt to access 51-element Base.IdentityUnitRange{UnitRange{Int64}} with indices 100:150 at index [100]
#   Stacktrace:
# @implements ArrayInterface Base.IdentityUnitRange [Base.IdentityUnitRange(100:150)]
@implements ArrayInterface{:logical} Base.CodeUnits [codeunits("abcde")]
@implements ArrayInterface{(:logical,:setindex!,:similar_type,:similar_eltype,:similar_size)} Array [[3, 2], ['a' 'b'; 'n' 'm']]
@implements ArrayInterface{(:logical,:setindex!,:similar_type,:similar_size)} BitArray [BitArray([false true; true false])]
@implements ArrayInterface{(:logical,:setindex!)} SubArray [view([7, 2], 1:2)]
@implements ArrayInterface{(:logical,:setindex!)} PermutedDimsArray [PermutedDimsArray([7 2], (2, 1))]
@implements ArrayInterface{(:logical,:setindex!)} Base.ReshapedArray [reshape(view([7, 2], 1:2), 2, 1)]

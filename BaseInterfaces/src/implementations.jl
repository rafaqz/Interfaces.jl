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

@implements DictInterface{:setindex!} Dict [Arguments(d=Dict(:a => 1, :b => 2), k=:c, v=3)]
@implements DictInterface{:setindex!} IdDict [Arguments(d=IdDict(:a => 1, :b => 2), k=:c, v=3)]
# This errors because the ref is garbage collected
# @implements DictInterface{:setindex!} WeakKeyDict [Arguments(; d=WeakKeyDict(Ref(1) => 1, Ref(2) => 2), k=Ref(3), v=3)]
@implements DictInterface Base.EnvDict [Arguments(d=Base.EnvDict())]
@implements DictInterface Base.ImmutableDict [Arguments(d=Base.ImmutableDict(:a => 1, :b => 2))]
@static if VERSION >= v"1.9.0"
    @implements DictInterface Base.Pairs [Arguments(d=Base.pairs((a = 1, b = 2)))]
end

@implements IterationInterface{(:reverse,:indexing)} UnitRange [1:5, -2:2]
@implements IterationInterface{(:reverse,:indexing)} StepRange [1:2:10, 20:-10:-20]
@implements IterationInterface{(:reverse,:indexing)} Array [[1, 2, 3, 4], [:a :b; :c :d]]
@implements IterationInterface{(:reverse,:indexing)} Tuple [(1, 2, 3, 4)]
@static if VERSION >= v"1.9.0"
    @implements IterationInterface{(:reverse,:indexing)} NamedTuple [(a=1, b=2, c=3, d=4)]
else
    @implements IterationInterface{:indexing} NamedTuple [(a=1, b=2, c=3, d=4)] # No reverse on 1.6
end
@implements IterationInterface{(:reverse,:indexing)} String ["abcdefg"]
@implements IterationInterface{(:reverse,:indexing)} Pair [:a => 2]
@implements IterationInterface Number [1, 1.0, 1.0f0, UInt(8), false]
@implements IterationInterface{:reverse} Base.Generator [(i for i in 1:5), (i for i in 1:5)]
# @implements IterationInterface{(:reverse,:indexing)} Base.EachLine [eachline(joinpath(dirname(pathof(BaseInterfaces)), "implementations.jl"))]

@implements IterationInterface Set [Set((1, 2, 3, 4))]
@implements IterationInterface BitSet [BitSet((1, 2, 3, 4))]
@implements IterationInterface Dict [Dict("a" => 2, :b => 3.0)]
@implements IterationInterface Base.EnvDict [Arguments(d=Base.EnvDict())]
@implements IterationInterface Base.ImmutableDict [Arguments(d=Base.ImmutableDict(:a => 1, :b => 2))]
# @implements IterationInterface IdDict
# @implements IterationInterface WeakKeyDict

# TODO add grouping to reduce the number of options
@implements SetInterface{(:copy,:empty,:emptymutable,:hasfastin,:setdiff,:intersect,:union,:empty!,:delete!,:push!,:copymutable,:sizehint!)} Set [Set((1, 2))]
@implements SetInterface{(:copy,:empty,:emptymutable,:hasfastin,:setdiff,:intersect,:union,:empty!,:delete!,:push!,:copymutable,:sizehint!)} BitSet [BitSet((1, 2))]
@implements SetInterface{(:empty,:emptymutable,:hasfastin,:intersect,:union,:sizehint!)} Base.KeySet [Base.KeySet(Dict(:a=>1, :b=>2))]
@implements SetInterface{(:empty,:hasfastin,:intersect,:union,:sizehint!)} Base.IdSet (s = Base.IdSet(); push!(s, "a"); push!(s, "b"); [s])


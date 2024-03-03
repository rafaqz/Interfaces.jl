
# @implements IterationInterface{(:reverse,:indexing)} UnitRange [1:5, -2:2]
# @implements IterationInterface{(:reverse,:indexing)} StepRange [1:2:10, 20:-10:-20]
# @implements IterationInterface{(:reverse,:indexing)} Array [[1, 2, 3, 4], [:a :b; :c :d]]
# @implements IterationInterface{(:reverse,:indexing)} Tuple [(1, 2, 3, 4)]
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

# @implements IterationInterface Set [Set((1, 2, 3, 4))]
# @implements IterationInterface BitSet [BitSet((1, 2, 3, 4))]
# @implements IterationInterface Dict [Dict("a" => 2, :b => 3.0)]
# @implements IterationInterface Base.EnvDict [Arguments(d=Base.EnvDict())]
# @implements IterationInterface Base.ImmutableDict [Arguments(d=Base.ImmutableDict(:a => 1, :b => 2))]
# @implements IterationInterface IdDict
# @implements IterationInterface WeakKeyDict


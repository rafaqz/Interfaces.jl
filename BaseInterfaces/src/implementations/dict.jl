
@implements DictInterface{:setindex!} Dict [Arguments(d=Dict(:a => 1, :b => 2), k=:c, v=3)]
@implements DictInterface{:setindex!} IdDict [Arguments(d=IdDict(:a => 1, :b => 2), k=:c, v=3)]
# This errors because the ref is garbage collected
# @implements DictInterface{:setindex!} WeakKeyDict [Arguments(; d=WeakKeyDict(Ref(1) => 1, Ref(2) => 2), k=Ref(3), v=3)]
@implements DictInterface Base.EnvDict [Arguments(d=Base.EnvDict())]
@implements DictInterface Base.ImmutableDict [Arguments(d=Base.ImmutableDict(:a => 1, :b => 2))]
@static if VERSION >= v"1.9.0"
    @implements DictInterface Base.Pairs [Arguments(d=Base.pairs((a = 1, b = 2)))]
end

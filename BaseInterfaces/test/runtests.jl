using BaseInterfaces
using Interfaces
using Test

@implements SetInterface{(:empty,:emptymutable,:hasfastin,:intersect,:union,:sizehint!)} Test.GenericSet [Test.GenericSet(Set((1, 2)))]
@implements DictInterface Test.GenericDict [Arguments(d=Test.GenericDict(Dict(:a => 1, :b => 2)), k=:c, v=3)]

# Test all interfaaces in BaseInterfaces
@test Interfaces.test(BaseInterfaces)

# Or test each interface in the module individually
@test Interfaces.test(ArrayInterface, BaseInterfaces)
@test Interfaces.test(DictInterface, BaseInterfaces)
@test Interfaces.test(IterationInterface, BaseInterfaces)
@test Interfaces.test(SetInterface, BaseInterfaces)

@test_broken Interfaces.test(ArrayInterface, Base.LogicalIndex, [to_indices([1, 2, 3], ([false, true, true],))[1]])

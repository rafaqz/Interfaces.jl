using BaseInterfaces
using Interfaces
using Test

# Test some Test objects
@implements SetInterface{(:empty,:emptymutable,:hasfastin,:intersect,:union,:sizehint!)} Test.GenericSet [Test.GenericSet(Set((1, 2)))]
@implements DictInterface Test.GenericDict [Arguments(d=Test.GenericDict(Dict(:a => 1, :b => 2)), k=:c, v=3)]

# Test all interfaces
@test Interfaces.test()

# Test all interfaaces in BaseInterfaces
@test Interfaces.test(BaseInterfaces)
@test Interfaces.test(Main)

# Or test each interface in the module individually
@test Interfaces.test(ArrayInterface, BaseInterfaces)
@test Interfaces.test(DictInterface, BaseInterfaces)
@test Interfaces.test(IterationInterface, BaseInterfaces)
@test Interfaces.test(SetInterface, BaseInterfaces)

# Now test all the interfaces implementations independent of where they are implemented
@test Interfaces.test(ArrayInterface)
@test Interfaces.test(DictInterface)
@test Interfaces.test(IterationInterface)
@test Interfaces.test(SetInterface)

@test_throws ArgumentError Interfaces.test(SetInterface{:empty})

# We can't implement LogicalIndex as it breaks the documented Base AbstractArray interface
@test_broken Interfaces.test(ArrayInterface, Base.LogicalIndex, [to_indices([1, 2, 3], ([false, true, true],))[1]])

using BaseInterfaces
using Interfaces
using Test

@testset "BaseInterfaces.jl" begin
    @test Interfaces.test(IterationInterface, UnitRange)
    @test Interfaces.test(IterationInterface, StepRange)
    @test Interfaces.test(IterationInterface, Array)
    @test Interfaces.test(IterationInterface, Base.Generator)
    @test Interfaces.test(IterationInterface, Tuple)
end

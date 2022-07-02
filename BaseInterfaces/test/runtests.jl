using BaseInterfaces
using Interfaces
using Test

@testset "BaseInterfaces.jl" begin
    Interfaces.test_interface(IteratorInterface)
end

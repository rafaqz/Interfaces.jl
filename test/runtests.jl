using Interfaces
using Test

abstract type MyInterface <: Interface end

struct MyObj end

@implements MyObj MyInterface

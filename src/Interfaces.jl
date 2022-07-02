module Interfaces

using InteractiveUtils

export Interface, @implements, @defines, implements, 

"""
    Interface 

Abstract supertype for all interfaces.
"""
abstract type Interface end

implements(::Type{<:Interface}, obj) = false

"""
@defi, that you may like to implement.ne 

Define an interface

```julia
""""
    SomeInterface

An interface for some things. This
""""
@define MyInterface begin
    @mandatory size begin
        len = length(x)
        @insist length(x) = prod(size(x))
        @insist ndims(x) = length(size(x))
    end

    @optional  begin
    end
end 
```
"""
macro define(interface, tests, description)
    quote
        abstract type $interface{Options} <: Interfaces.Interface end
        Interfaces.test_interface(::Type{<:$interface}, $obj)
            $tests
        end
    end |> esc
end

"""
    @implements(type, obj, interface)

Declare that an interface implements an interface,
and pass an object or tuple of objects to test it with.

# Example

```julia
@implementsMyArray [
        BaseInterfaces.AbstractArray{(:getindex,:setindex!,:broadcast)},
        BaseInterfaces.Iteration{(:indexed)}
    ] (MyArray([1, 2, 3]), MyArray(rand(5, 4)))
```
"""
macro implements(T, interface, obj; test_during_precompile=true)
    precompile = test_during_precompile ? :(let Interfaces.test(interface, T) end) : :(nothing)
    quote
        Interfaces.implements(::Type{<:$interface}, ::Type{<:$obj}) = true
        __implements_interface__(::Type{<:$obj}) = [obj_interfaces] # Module.__implements__
        __implements_interface__(::Type{<:$interface}) = [interface_objects] # Module.__implements__
        __implements_interface__() = interfaces # Module.__implements__
        __interface_test_object__(::Type{T}) = obj
        $precompile
    end
end

_check_obj(::Type{T}, objs::Tuple) where T = @assert obj isa T
_check_obj(::Type{T}, objs::Tuple) where T = map(o -> _check_obj(T, o), objs)

"""
    @document 

Macro to insert interface documentation into docs for objects
That implement them.

# Example 

```julia
Interfaces.@document MyModule SomInterface
```
"""
macro document(mod)
    interfaces = mod.__implements__()
    docstrings = map(interfaces) do T
        Base.doc(T)
    end
end

macro document(mod, interface, interfaces...)
    docstrings = map((interfaces, interfaces...)) do T
        Base.doc(T)
    end
end


"""
    test_interface(::Type{<:Interface}, obj) 

Test if an interface is implemented for an object, returning `true` or `false`.

The default return value is `false`.
"""
test_interface(::Type{<:Interface}, obj) = false

function test(obj; scope=:direct)
    interfaces = if scope == :direct
        list_direct(obj)
    else
        list_all(obj)
    end
    for interface in interfaces
        test(interface, obj)
    end
end


function list_direct(obj)
    return obj.name.module.__implementations__
end

function list_all(obj)
    interfaces = Type[]
    _add_interfaces!(interfaces, Interface, obj)
end

function _add_interfaces!(interfaces, T, obj)
    st = subtypes(T)
    if isempty(st)
        push!(interfaces, T)
    else
        for T in subtypes(T)
            _add_interfaces!(interfaces, T, obj)
        end
    end
    return interfaces
end

end

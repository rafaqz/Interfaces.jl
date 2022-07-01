module Interfaces

using InteractiveUtils

export Interface, @implements, implements

"""
    Interface 

Abstract supertype for all interfaces.
"""
abstract type Interface end

implements(::Type{<:Interface}, obj) = false

"""
    @implements 

```julia
@implements begin
    MyArray BaseInterfaces.AbstractArray
end
```

```julia
@implements MyArray BaseInterfaces.AbstractArrayGetindex 
```
"""
macro implements(obj, interface)
    quote
        Interfaces.hasimplemented(::Type{<:$interface}, ::Type{<:$obj}) = true
        __implements__(::Type{<:$obj}) = [obj_interfaces] # Module.__implements__
        __implements__(::Type{<:$interface}) = [interface_objects] # Module.__implements__
        __implements__() = interfaces # Module.__implements__
    end |> esc
end
macro implements(obj, interface)
    quote
        Interfaces.hasimplemented(::Type{<:$interface}, ::Type{<:$obj}) = true
        __implements__(::Type{<:$obj}) = [obj_interfaces] # Module.__implements__
        __implements__(::Type{<:$interface}) = [interface_objects] # Module.__implements__
        __implements__() = interfaces # Module.__implements__
    end |> esc
end

@implements begin 
    MyArray => BaseInterfaces.AbstractArray{(:getindex,:setindex!,:broadcast)}
    MyArray => BaseInterfaces.Iteration{(:indexed)}
    SomeArray => [BaseInterfaces.AbstractArray]
end

macro document(mod)
    interfaces = mod.__implements__
    docstrings = map(interfaces) do T
        Base.doc(T)
    end
end

"""

```julia
"""
```
"""
macro define(interface, obj, tests, description)
    quote
        abstract type $interface{Options} <: Interfaces.Interface end
        Interfaces.test_interface(::Type{<:$interface}, $obj)
            $tests
        end
    end |> esc
end


"""
    test_interface(::Type{<:Interface}, obj) 

Test if an interface is implemented for an object,
returning `true` or `false`.

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

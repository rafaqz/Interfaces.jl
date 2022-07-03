module Interfaces

export Interface, @implements, @interface, implements

"""
    Interface{Components}

Abstract supertype for all interfaces.

Components is an `NTuple` of `Symbol`.
"""
abstract type Interface{Components} end

function implementing_module end
optional_keys(T::Type{<:Interface}, obj) = optional_keys(T, typeof(obj)) 
optional_keys(T::Type{<:Interface}, obj::Type) = ()

"""
    (T::Interface)

Returns whether an object implements and interface, as a `Bool`.
"""
implements(::Type{<:Interface}, obj) = false

"""
    components(T::Interface)

Returns the components of interface tests, as a `NamedTuple` of
`Tuple` of functions or functors.
"""
function components end

"""
@interface

Define an interface.

```julia
@interface MyInterface begin
    mandatory = (
        length = x -> length(x) = prod(size(x)),
        ndims = x -> ndims(x) = length(size(x)),
    ),
    optional = (;)
end
```
"""
macro interface(interface, components::Expr)
    quote
        # Define the interface type (should it be concrete?)
        abstract type $interface{Components} <: Interfaces.Interface{Components} end
        # Define the interface methods
        Interfaces.components(::Type{<:$interface}) = $components
    end |> esc
end

"""
    @implements(interface, objtype, obj)

Declare that an interface implements an interface, or
multipleinterfaces.

Also pass an object or tuple of objects to test it with.

The macro can only be used once per module for any one type.
To define multiple interfaces a type implements, combine them
in square brackets.

# Example

```julia
@implements BaseInterfaces.Iteration{(:indexed,)} MyArray MyArray([1, 2, 3])
```
"""
macro implements(interface, objtype, obj)
    if interface isa Expr && interface.head == :curly
        interfacetype = interface.args[1]    
        optional_keys = interface.args[2]
    else
        interfacetype = interface
        optional_keys = ()
    end
    quote
        # Define a trait stating that `objtype` implements `interface`
        Interfaces.implements(::Type{<:$interfacetype}, ::Type{<:$objtype}) = true
        Interfaces.implements(T::Type{<:$interfacetype{Options}}, O::Type{<:$objtype}) where Options = 
            Interfaces._all_in(Options, Interfaces.optional_keys(T, O))
        Interfaces.optional_keys(::Type{<:$interfacetype}, ::Type{<:$objtype}) = $optional_keys
        Interfaces.implementing_module(::Type{<:$interfacetype}, ::Type{<:$objtype}) = @__MODULE__

        # Define the Module.__implements__ methods, for lookups both ways
        __implements__(x::$objtype) = __implements__(typeof(x))
        __implements__(::Type{<:$objtype}) = $interfacetype

        # Define Module.__interface_test_object__ method
        __interface_test_object__(::Type{<:$interfacetype}, ::Type{<:$objtype}) = $obj


        # Run tests in precompilation
        Interfaces.test($interface, $objtype)
    end |> esc
end

_all_in(items::Tuple, collection) = all(map(in(collection), items))
_all_in(item::Symbol, collection) = in(item, collection)


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
    test(obj)
    test(::Type{<:Interface}, obj)

Test if an interface is implemented correctly for an object,
returning `true` or `false`.

If no interface type is passed, Interfaces.jl will find all the
interfaces available and test them.
"""
function test(T::Type; kw...)
    mod =  implementing_module(T, O)
    test(mod.__interface_test_object__(T); kw...)
end
function test(obj; scope=:direct)
    # Get all the interfaces an object implements
    interfaces = if scope == :direct
        _module_implements(obj)
    else
        _any_implements(obj)
    end

    # Run `test` for all the interfaces.
    for interface in interfaces
        test(interface, obj)
    end
end
test(T::Type{<:Interface}, O::Type) = test(T{optional_keys(T, O)}, O)
test(T::Type{<:Interface}, obj) = test(T{optional_keys(T, obj)}, obj)
function test(T::Type{<:Interface{Options}}, O::Type) where Options
    mod = implementing_module(T, O)
    obj = mod.__interface_test_object__(T, O)
    test(T, obj)
end
function test(T::Type{<:Interface{Options}}, obj) where Options
    mandatory_results = _test(components(T).mandatory, obj) 
    optional_results = _test(components(T).optional[Options], obj)
    mandatory_failures = keys(mandatory_results)[collect(map(!, mandatory_results))]
    optional_failures = keys(optional_results)[collect(map(!, optional_results))]
    if length(mandatory_failures) > 0 || length(optional_failures) > 0
        error("errors found in required components $mandatory_failures and optional components $optional_failures")
        return false
    else
        return true
    end
end

_test(tests::NamedTuple, obj) = map(t -> _test(t, obj), tests)
function _test(condition, obj)
    if condition isa Tuple
        all(map(f -> f(obj), condition))
    else
        condition(obj)
    end
end

# List interfaces defined for the object in its own module
function _module_implements(obj)
    filter(_all_interfaces()) do interface
        implementing_module(interface, obj) == _get_module(obj) && implements(interface, obj)
    end
end

# List all interfaces defined for the object type.
function _any_implements(obj)
    filter(_all_interfaces()) do interface
        implements(interface, obj)
    end
end

# Walk the subtype tree of `Interface` to find interfaces
# that are defined for the object
function _all_interfaces(T=Interface)
    interfaces = Type[]
    _add_interfaces!(interfaces, Interface)
end

_get_module(obj) = _get_type(obj).name.module

_get_type(obj) = _get_type(typeof(obj))
_get_type(T::Type) = T
_get_type(T::UnionAll) = _get_type(T.body)

function _add_interfaces!(interfaces, T)
    st = subtypes(T)
    if isempty(st)
        push!(interfaces, T)
    else
        for T in subtypes(T)
            _add_interfaces!(interfaces, T)
        end
    end
    return interfaces
end

end

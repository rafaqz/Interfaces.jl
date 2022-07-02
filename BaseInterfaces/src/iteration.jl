#=
Required methods		Brief description
iterate(iter)		        Returns either a tuple of the first item and initial state or nothing if empty
iterate(iter, state)		Returns either a tuple of the next item and next state or nothing if no items remain

Important optional methods	Default definition	Brief description
IteratorSize(IterType)	        HasLength()	One of HasLength(), HasShape{N}(), IsInfinite(), or SizeUnknown() as appropriate
IteratorEltype(IterType)	HasEltype()	Either EltypeUnknown() or HasEltype() as appropriate
eltype(IterType)	        Any	        The type of the first entry of the tuple returned by iterate()
length(iter)	                (undefined)	The number of items, if known
size(iter, [dim])	        (undefined)	The number of items in each dimension, if known

Value returned by IteratorSize(IterType)	Required Methods
HasLength()	                length(iter)
HasShape{N}()	                length(iter) and size(iter, [dim])
IsInfinite()	                (none)
SizeUnknown()	                (none)

Value returned by IteratorEltype(IterType)	Required Methods
HasEltype()	eltype(IterType)
EltypeUnknown()	(none)
=#

@interface IterationInterface x begin

    @mandatory iterate begin
        (
            x -> isnothing(iterate(x)),
            x -> isnothing(iterate(iterate(x))),
            x -> iterate(x) isa Tuple,
            x -> iterate(iterate(x)...) isa Tuple
        )
    end

    #= output something like:
    function conditions(T::Type{IteratorInterface{:interate})
        (
            x -> isnothing(iterate(x)),
            x -> isnothing(iterate(iterate(x))),
            x -> iterate(x) isa Tuple,
            x -> iterate(iterate(x)...) isa Tuple
        )
    end
    =#

    """
    Base.IteratorSize allows return values of
    `HasLength()`, `HasShape{N}()`, `IsInfinite()`, or `SizeUnknown()`.

    `HasLength()` is the default. This means that by default `length` 
    must be defined for the object. If `HasShape{N}()` is returned, `length` and
    `size` must be defined`.
    """
    @mandatory size begin
         x -> begin
             trait = IteratorSize(x)
             if trait isa HasLength
                 x -> length(x) isa Integer
             elseif trait isa HasShape
                 (
                     x -> length(x) isa Integer,
                     x -> size(x) isa NTuple{<:Any,<:Integer},
                     x -> length(size(x)) == typeof(itsize).parameters[1],
                     x -> length(x) == prod(size(x)),
                 )
             elseif trait isa Union{IsInfinite,SizeUnknown} 
                 true
             else
                 # Error here because its actually breaking the default?
                 error("IteratorSize(x) must return `HasLength`, `HasShape`, `IsInfinite` or `SizeUnknown`")
             end
         end
    end
    #= output something like:
    function conditions(T::Type{IteratorInterface{:size})
        ...

    end
    =#

    @mandatory eltype begin
        x -> begin
            Base.IteratorEltype(x) 
            if trait isa HasEltype 
                eltype(x) == typeof(first(x))
            else trait isa EltypeUnknown || error("IteratorEltype(x) must return `HasEltype` or `EltypeUnknown`")
                true
            end
        end
    end
    #= Not sure I'm totally happy with this output for traits
    function conditions(T::Type{IteratorInterface{:eltype})
        x -> begin
            Base.IteratorEltype(x) 
            if trait isa HasEltype 
                @assert eltype(x) == typeof(first(x))
            else trait isa EltypeUnknown || error("IteratorEltype(x) must return `HasEltype` or `EltypeUnknown`")
                noting
            end
        end
    end
    =#

    @optional reverse begin
        x -> collect(Iterators.reverse(x)) == reverse(collect(x))
    end
    #= output something like:
    function condition(T::IteratorInterface{:reverse})
        x -> collect(Iterators.reverse(x)) == reverse(collect(x))
    end
    =#

    """
    We force the implementation of `firstindex` and `lastindex`
    Or it is impossible to test `getindex` generically
    """
    @optional indexing begin
        (
            x -> firstindex(x) isa Integer,
            x -> lastindex(x) isa Integer,
            x -> getindex(x, firstindex(x)) == first(iterate(x)),
        )
    end
    #= output something like:
    function conditions(T::IteratorInterface{:reverse}, x)
        (
            x -> firstindex(x) isa Integer,
            x -> lastindex(x) isa Integer,
            x -> getindex(x, firstindex(x)) == first(iterate(x)),
        )
    end
    =#

    @optional setindex! begin
        @assert first(x) != last(x) "should contain no repeated values"
        @assert (setindex(firstindex(x)) = last(x); first(x) == last(x))
    end
end
#= output something like:
function conditions(T::Type{IteratorInterface{:interate})
    (
        x -> isnothing(iterate(x)),
        x -> isnothing(iterate(iterate(x))),
        x -> iterate(x) isa Tuple,
        x -> iterate(iterate(x)...) isa Tuple
    )
end
function conditions(T::Type{IteratorInterface{:otherthings})
    ...

mandatory_components(::IteratorInterface) = (:iterate, :size)
optional_components(::IteratorInterface) = (:reverse, :indexing, setindex!)



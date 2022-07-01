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

@define IterationInterface x begin


    @mandatory iterate begin
        @insist isnothing(iterate(x)) "must have two or more elements"
        @insist isnothing(iterate(iterate(x))) "must have two or more elements"
        @insist iterate(x) isa Tuple
        @insist iterate(iterate(x)...) isa Tuple
    end
    #= output something like:
    function implements(::Type{IteratorInterface{:reverse}}, ::Type{<:ObjType}) 
        true
    end
    function conditions(T::Type{IteratorInterface{:interate}, obj)
        (
            x -> iterate(x) isa Tuple => "iterate(x) isa Tuple",
            x -> iterate(iterate(x)...) isa Tuple => "iterate(iterate(x)...) isa Tuple",
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
        @trait Base.IteratorSize [
             HasLength => @insist length(x) isa Integer
             HasShape => begin
                @insist length(x) isa Integer
                @insist size(x) isa NTuple{<:Any,<:Integer}
                @insist length(size(x)) == typeof(itsize).parameters[1]
                @insist length(x) == prod(size(x))
             end
             IsInfinite
             SizeUnknown
        ]
    end
    #= output something like:
    function implements(::Type{IteratorInterface{:size}}, ::Type{<:ObjType}) 
        true
    end
    function conditions(T::Type{IteratorInterface{:size}, obj)
        (
            x -> iterate(x) isa Tuple,
            x -> iterate(iterate(x)...),
        )
    end
    =#

    @mandatory eltype begin
        @trait Base.IteratorEltype [
             HasEltype => @insist eltype(x) == typeof(first(x))
             EltypeUnknown
        ]
    end
    #= output something like:
    function conditions(T::Type{IteratorInterface{:eltype}, x::ObjType)
         trait = Base.IteratorEltype(x) 
         if #19trait isa HasEltype
             (
                 x -> eltype(x) == typeof(first(x)) => "`eltype(x) == typeof(first(x))`",
             )
         elseif trait isa EltypeUnknown
             ()
         else
             throw(TraitError("trait Base.IteratorEltype(x) must be `<: HasEltype` or `<: EltypeUnknown`, but returns $trait".))
         end
    end
    =#

    @optional reverse begin
        @insist collect(Iterators.reverse(x)) == reverse(collect(x))
    end
    #= output something like:
    function implements(::Type{IteratorInterface{:reverse}}, ::Type{<:ObjType}) 
        true
    end
    function conditions(T::IteratorInterface{:reverse}, x)
        (
            x -> collect(Iterators.reverse(x)) == reverse(collect(x)),
        )
    end
    =#

    """
    We force the implementation of `firstindex` and `lastindex`
    Or it is impossible to test `getindex`
    """
    @optional indexing begin
        @insist firstindex(x) isa Integer
        @insist lastindex(x) isa Integer
        @insist getindex(x, firstindex(x)) == first(iterate(x))
    end
    #= output something like:
    function implements(::Type{IteratorInterface{:indexing}}, ::Type{<:ObjType}) 
        true
    end
    function conditions(T::IteratorInterface{:reverse}, x)
        (
            x -> firstindex(x) isa Integer
            x -> lastindex(x) isa Integer
            x -> getindex(x, firstindex(x)) == first(iterate(x))
        )
    end
    =#

    @optional setindex! begin
        @needs indexing
        @insist first(x) != last(x) "should contain no repeated values"
        @insist (setindex(firstindex(x)) = last(x); first(x) == last(x))
    end
end


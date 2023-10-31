#=
From the Base julia interface docs:

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

# :size demonstrates an interface condition that instead of return a Bool,
function test_iterator_size(x)
    sizetrait = Base.IteratorSize(typeof(x))
    if sizetrait isa Base.HasLength
        length(x) isa Integer
    elseif sizetrait isa Base.HasShape
        length(x) isa Integer &&
        size(x) isa NTuple{<:Any,<:Integer} &&
        length(size(x)) == typeof(sizetrait).parameters[1] &&
        length(x) == prod(size(x))
    elseif sizetrait isa Base.IsInfinite
        return true
    elseif sizetrait isa Base.SizeUnknown
        return true
    else
        error("IteratorSize returns $sizetrait, allowed options are: `HasLength`, `HasLength`, `IsInfinite`, `SizeUnknown`")
    end
end

function test_iterator_eltype(x)
    eltypetrait = Base.IteratorEltype(x)
    if eltypetrait isa Base.HasEltype
        x1, _ = iterate(x)
        typeof(first(x)) <: eltype(x)
    elseif eltypetrait isa Base.EltypeUnknown
        true
    else
        error("IteratorEltype(x) returns $eltypetrait, allowed options are `HasEltype` or `EltypeUnknown`")
    end
end

# `Iterators.reverse` gives reverse iteration

@interface IterationInterface Any (
    # Mandatory conditions: these must be met by all types
    # that implement the interface.
    mandatory = (
        iterate = (
            x -> !isempty(x),
            x -> !isnothing(iterate(x)),
            x -> !isnothing(iterate(iterate(x))),
            x -> iterate(x) isa Tuple,
            x -> iterate(x, last(iterate(x))) isa Tuple,
        ),
        isiterable = x -> Base.isiterable(typeof(x)),
        size = test_iterator_size,
        eltype = test_iterator_eltype,
        in = x -> first(x) in x,
    ),
    # Optional conditions. These should be specified in the
    # interface type if an object implements them: IterationInterface{(:reverse,:indexing)}
    optional = (
        reverse = x -> collect(Iterators.reverse(x)) == reverse(collect(x)),
        # TODO: move this to collections?
        indexing = (
             x -> firstindex(x) isa Integer,
             x -> lastindex(x) isa Integer,
             x -> getindex(x, firstindex(x)) == first(iterate(x)),
        ),
    )
) "An interface for Base Julia iteration"

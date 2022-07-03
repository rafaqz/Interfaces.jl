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


@interface IterationInterface (
    mandatory = (
        iterate = (
            x -> !isnothing(iterate(x)),
            x -> !isnothing(iterate(iterate(x))),
            x -> iterate(x) isa Tuple,
            x -> iterate(x, last(iterate(x))) isa Tuple,
        ),

        #=
        Base.IteratorSize allows return values of
        `HasLength()`, `HasShape{N}()`, `IsInfinite()`, or `SizeUnknown()`.

        `HasLength()` is the default. This means that by default `length` 
        must be defined for the object. If `HasShape{N}()` is returned, `length` and
        `size` must be defined`.

        TODO: use Invariants.jl for this
        =#

        # haslength = (
        #     x -> IteratorSize(x) == Base.HasLength(),
        #     x -> length(x) isa Integer,
        # )
        # hasshape = (
        #     x -> IteratorSize(x) == isa Base.HasShape
        #     x -> length(x) isa Integer,
        #     x -> size(x) isa NTuple{<:Any,<:Integer},
        #     x -> length(size(x)) == typeof(IteratorSize(x)).parameters[1],
        #     x -> length(x) == prod(size(x)),
        # )
        # isinfinie = x -> IteratorSize(x) == isa Base.IsInfinite(),
        # sizeunknown = x -> IteratorSize(x) == isa Base.SizeUnknown(),
        # eltype = x -> begin
        #     trait = Base.IteratorEltype(x) 
        #     if trait isa Base.HasEltype 
        #         eltype(x) == typeof(first(x))
        #     else trait isa Base.EltypeUnknown || error("IteratorEltype(x) must return `HasEltype` or `EltypeUnknown`")
        #         true
        #     end
        # end,
    ),

    optional = (
        reverse = x -> collect(Iterators.reverse(x)) == reverse(collect(x)),
        #=
        We force the implementation of `firstindex` and `lastindex`
        Or it is hard to test `getindex` generically
        =#
        indexing = (
            x -> firstindex(x) isa Integer,
            x -> lastindex(x) isa Integer,
            x -> getindex(x, firstindex(x)) == first(iterate(x)),
        ),
    )
)



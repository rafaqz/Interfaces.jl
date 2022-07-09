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

@interface IterationInterface (
    # Mandatory conditions: these must be met by all types
    # that implement the interface.
    mandatory = (
        # :iterate returns a Tuple of anonymous functions
        # that will each be tested for some object `x`.
        iterate = (
            "test objects must be longer than 1" => x -> !isnothing(iterate(x)),
            "test objects must be longer than 2" => x -> !isnothing(iterate(iterate(x))),
            "iterate must return a tuple" => x -> iterate(x) isa Tuple,
            "iteration on the last `iterate` output works" => x -> iterate(x, last(iterate(x))) isa Tuple,
        ),
        # :size demonstrates an interface condition that instead of return a Bool,
        # returns a Tuple of functions to run for `x` depending on the IteratorSize
        # trait.
        size = x -> begin
            sizetrait = Base.IteratorSize(typeof(x))
            if sizetrait isa Base.HasLength
                return (
                    "`length(x)` returns an Integer for HasLength objects" => x -> length(x) isa Integer,
                )
            elseif sizetrait isa Base.HasShape 
                return (
                    "`length(x)` returns an Integer for HasShape objects" => x -> length(x) isa Integer,
                    "`size(x)` returns a Tuple of Integer for HasShape objects" => x -> size(x) isa NTuple{<:Any,<:Integer},
                    "`size(x)` returns a Tuple of length `N` matching `HasShape{N}`" => x -> length(size(x)) == typeof(sizetrait).parameters[1],
                    "`length(x)` is the product of `size(x)` for `HasShape` objects" => x -> length(x) == prod(size(x)),
                )
            elseif sizetrait isa Base.IsInfinite
                return true
            elseif sizetrait isa Base.SizeUnknown
                return true
            else
                error("IteratorSize returns $sizetrait, allowed options are: `HasLength`, `HasLength`, `IsInfinite`, `SizeUnknown`")
            end
        end,
        eltype = x -> begin
            eltypetrait = Base.IteratorEltype(x) 
            if eltypetrait isa Base.HasEltype 
                x -> typeof(first(x)) <: eltype(x) 
            elseif eltypetrait isa Base.EltypeUnknown 
                true
            else
                error("IteratorEltype(x) returns $eltypetrait, allowed options are `HasEltype` or `EltypeUnknown`")
            end
        end,
    ),

    # Optional conditions. These should be specified in the
    # interface type if an object implements them: IterationInterface{(:reverse,:indexing)}
    optional = (
        # :reverse returns a single function to test Iterators.reverse
        reverse = "`Iterators.reverse` gives reverse iteration" => x -> collect(Iterators.reverse(x)) == reverse(collect(x)),
        #=
        :indexing returns three condition functions.
        We force the implementation of `firstindex` and `lastindex`
        Or it is hard to test `getindex` generically
        =#
        indexing = (
            "`firstindex` returns an Integer" => x -> firstindex(x) isa Integer,
            "`lastindex` returns an Integer" => x -> lastindex(x) isa Integer,
            "`getindex(x, firstindex(x))` returns the first value of `iterate(x)`" => x -> getindex(x, firstindex(x)) == first(iterate(x)),
        ),
    )
)



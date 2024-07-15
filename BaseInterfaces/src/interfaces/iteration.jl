#=
From the Base julia interface docs
https://docs.julialang.org/en/v1/manual/interfaces/

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

# `Iterators.reverse` gives reverse iteration

@interface IterationInterface Any (
    # Mandatory conditions: these must be met by all types
    # that implement the interface.
    mandatory = (
        isempty = "test iterator is not empty" => x -> !isempty(x),
        iterate = (
            "`iterate` does not return `nothing`" => x -> !isnothing(iterate(x)),
            "`iterate` returns a `Tuple`" => x -> iterate(x) isa Tuple{<:Any,<:Any},
            "second `iterate` returns a `Tuple` or `Nothing`" => x -> iterate(x, last(iterate(x))) isa Union{Nothing,Tuple{<:Any,<:Any}},
        ),
        isiterable = x -> Base.isiterable(typeof(x)),
        eltype = x -> begin
            eltypetrait = Base.IteratorEltype(x)
            if eltypetrait isa Base.HasEltype
                return "values of `x` are `<: eltype(x)`" => x -> typeof(first(x)) <: eltype(x)
            elseif eltypetrait isa Base.EltypeUnknown
                return true
            else
                error("IteratorEltype(x) returns $eltypetrait, allowed options are `HasEltype` or `EltypeUnknown`")
            end
        end,
        size = x -> begin
            sizetrait = Base.IteratorSize(typeof(x))
            if sizetrait isa Base.HasLength
                return "`length(x)` returns an `Integer`" => x -> length(x) isa Integer
            elseif sizetrait isa Base.HasShape
                # Return more functions to test 
                return (
                    "`length(x)` returns an `Int`" => x -> length(x) isa Integer,
                    "`size(x)` returns a `Tuple` of `Integer`" => 
                        x -> size(x) isa NTuple{<:Any,<:Integer},
                    "`size(x)` matches the type parameter of `HasShape`" =>
                        x -> length(size(x)) == typeof(sizetrait).parameters[1],
                    "`length(x)` is the product of size(x)" =>
                        x -> length(x) == prod(size(x)),
                 )
            elseif sizetrait isa Base.IsInfinite
                return true
            elseif sizetrait isa Base.SizeUnknown
                return true
            else
                error("IteratorSize returns $sizetrait, allowed options are: `HasLength`, `HasLength`, `IsInfinite`, `SizeUnknown`")
            end
        end,
        in = "`in` returns true for all values in x" => x -> all(a -> a in x, x),
    ),
    # Optional conditions. These should be specified in the
    # interface type if an object implements them: IterationInterface{(:reverse,:indexing)}
    optional = (
        reverse = x -> collect(Iterators.reverse(x)) == reverse(collect(x)),
        # TODO: move this to collections?
        indexing = (
             "can call firstindex" => x -> firstindex(x) isa Integer,
             "can call lastindex" => x -> lastindex(x) isa Integer,
             "can call getindex" => x -> getindex(x, firstindex(x)) == first(iterate(x)),
             "getindex matches iteration order" => x -> begin
                 itr = iterate(x)
                 i = firstindex(x)
                 while !isnothing(itr)
                     getindex(x, i) == itr[1] || return false
                     itr = iterate(x, itr[2])
                     i += 1
                 end
                 return true
             end,
        ),
    )
) """
An interface for Base Julia iteration. 

Test objects must not be empty, so that `isempty(obj) == false`.
"""

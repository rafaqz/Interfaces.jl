#= Abstract Arrays

Methods to implement		            Brief description
size(A)		                            Returns a tuple containing the dimensions of A
getindex(A, i::Int)		                (if IndexLinear) Linear scalar indexing
getindex(A, I::Vararg{Int, N})          (if IndexCartesian, where N = ndims(A)) N-dimensional scalar indexing

Optional methods	                    Default definition	                    Brief description
IndexStyle(::Type)	                    IndexCartesian()	                    Returns either IndexLinear() or IndexCartesian(). See the description below.
setindex!(A, v, i::Int)		                                                    (if IndexLinear) Scalar indexed assignment
setindex!(A, v, I::Vararg{Int, N})                                              (if IndexCartesian, where N = ndims(A)) N-dimensional scalar indexed assignment
getindex(A, I...)	                    defined in terms of scalar getindex	    Multidimensional and nonscalar indexing
setindex!(A, X, I...)	                defined in terms of scalar setindex!	Multidimensional and nonscalar indexed assignment 
iterate	                                defined in terms of scalar getindex	Iteration
length(A)	                            prod(size(A))	                        Number of elements
similar(A)	                            similar(A, eltype(A), size(A))	        Return a mutable array with the same shape and element type
similar(A, ::Type{S})	                similar(A, S, size(A))	                Return a mutable array with the same shape and the specified element type
similar(A, dims::Dims)	                similar(A, eltype(A), dims)	            Return a mutable array with the same element type and size dims
similar(A, ::Type{S}, dims::Dims)	    Array{S}(undef, dims)	                Return a mutable array with the specified element type and size

Non-traditional indices	                Default definition	                    Brief description
axes(A)	                                map(OneTo, size(A))	                    Return a tuple of AbstractUnitRange{<:Integer} of valid indices
similar(A, ::Type{S}, inds)	            similar(A, S, Base.to_shape(inds))	    Return a mutable array with the specified indices inds (see below)
similar(T::Union{Type,Function}, inds)	T(Base.to_shape(inds))	                Return an array similar to T with the specified indices inds (see below)
=#

# And arbitrary new type for array values
struct ArrayTestVal
    a::Int
end

# In case `eltype` and `ndims` have custom methods
# We should always be able to use these to mean the same thing
_eltype(::AbstractArray{T}) where T = T
_ndims(::AbstractArray{<:Any,N}) where N = N

array_components = (;
    mandatory = (;
        type = A -> A isa AbstractArray,
        eltype = (
            A -> eltype(A) isa Type,
            A -> eltype(A) == _eltype(A),
        ),
        ndims = (
            A -> ndims(A) isa Int,
            A -> ndims(A) == _ndims(A),
        ),
        size = (
            A -> size(A) isa NTuple{<:Any,Int},
            A -> length(size(A)) == ndims(A),
        ),
        getindex = (
            A -> A[begin] isa eltype(A),
            A -> A[map(first, axes(A))...] isa eltype(A),
        ),
        indexstyle = A -> IndexStyle(A) in (IndexCartesian(), IndexLinear()),
    ),
    # TODO implement all the optional conditions
    optional = (;
        setindex! = (
            A -> length(A) > 1 || throw(ArgumentError("Test arrays must have more than one element to test setindex!")),
            A -> begin
                # Tests setindex! by simply swapping the first and last elements
                x1 = A[begin]; x2 = A[end]
                A[begin] = x2
                A[end] = x1
                A[begin] == x2 && A[end] == x1
            end,
            A -> begin
                fs = map(first, axes(A))
                ls = map(last, axes(A))
                x1 = A[fs...]; 
                x2 = A[ls...]
                A[fs...] = x2
                A[ls...] = x1
                A[fs...] == x2 && A[ls...] == x1
            end,
        ),
        similar_type = A -> similar(A) isa typeof(A),
        similar_eltype = A -> begin
            A1 = similar(A, ArrayTestVal) 
            eltype(A1) == ArrayTestVal && _wrappertype(A) == _wrappertype(A1)
        end,
        similar_size = A -> begin
            A1 = similar(A, (2, 3))
            size(A1) == (2, 3) && _wrappertype(A) == _wrappertype(A1)
        end,
    )
)

_wrappertype(A) = Base.typename(typeof(A)).wrapper

@interface ArrayInterface AbstractArray array_components "Base Julia AbstractArray interface"

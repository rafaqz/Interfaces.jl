#= Abstract Arrays
https://docs.julialang.org/en/v1/manual/interfaces/

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
            "size(A) returns a tuple of Integer" => A -> size(A) isa NTuple{<:Any,Integer},
            "length of size(A) matches ndims(A)" => A -> length(size(A)) == ndims(A),
        ),
        getindex = (
           "Can index with begin/firstinex" => A -> A[begin] isa eltype(A),
           "Can index with end/lastindex" => A -> A[end] isa eltype(A),
           "Can index with all indices in `eachindex(A)`" => A -> all(x -> A[x] isa eltype(A), eachindex(A)),
           "Can index with multiple dimensions" => A -> A[map(first, axes(A))...] isa eltype(A),
           "Can use trailing ones" => A -> A[map(first, axes(A))..., 1, 1, 1] isa eltype(A),
           "Can index with CartesianIndex" => A -> A[CartesianIndex(map(first, axes(A))...)] isa eltype(A),
           "Can use trailing ones in CartesianIndex" => A -> A[CartesianIndex(map(first, axes(A))..., 1, 1, 1)] isa eltype(A),
        ),
        indexstyle = "IndexStyle returns IndexCartesian or IndexLinear" => A -> IndexStyle(A) in (IndexCartesian(), IndexLinear()),
    ),
    # TODO implement all the optional conditions
    optional = (;
        setindex! = (
            A -> length(A) > 1 || throw(ArgumentError("Test arrays must have more than one element to test setindex!")),
            "setindex! can write the first to the last element" => 
                A -> begin
                    x1 = A[begin]; x2 = A[end]
                    A[begin] = x2
                    A[end] = x1
                    A[begin] == x2 && A[end] == x1
                end,
            "setindex! can write the first to the last element using multidimensional indices" =>
                A -> begin
                    fs = map(first, axes(A))
                    ls = map(last, axes(A))
                    x1 = A[fs...];
                    x2 = A[ls...]
                    A[fs...] = x2
                    A[ls...] = x1
                    A[fs...] == x2 && A[ls...] == x1
                end,
            "setindex! can write to all indices in eachindex(A)" => 
                A -> begin
                    v = first(A)
                    all(eachindex(A)) do i
                        A[i] = v
                        A[i] === v
                    end
                end,
            "setindex! can write to all indices in CartesianIndices(A)" => 
                A -> begin
                    v = first(A) # We have already tested writing to the first index above
                    all(CartesianIndices(A)) do i
                        A[i] = v
                        A[i] === v
                    end
                end,
        ),
        similar_type = "`similar(A)` returns an object the same type and size as `A`" => 
            A -> begin
                A1 = similar(A)
                A1 isa typeof(A) && size(A1) == size(A)
            end,
        similar_eltype = "similar(A, T::Type) returns an object the same base type as `A` with eltype of `T`" => 
            A -> begin
                A1 = similar(A, ArrayTestVal); 
                _wrappertype(A) == _wrappertype(A1) && eltype(A1) == ArrayTestVal && size(A) == size(A1)
            end,
        similar_size = "similar(A, s::NTuple{Int}) returns an object the same type as `A` with size `s`" =>
            A -> begin
                A1 = similar(A, (2, 3))
                A2 = similar(A, (4, 5))
                _wrappertype(A) == _wrappertype(A1) && size(A1) == (2, 3) && size(A2) == (4, 5)
            end,
        similar_eltype_size = "similar(A, T::Type, s::NTuple{Int}) returns an object the same type as `A` with eltype `T` and size `s`" =>
            A -> begin
                A1 = similar(A, ArrayTestVal, (2, 3))
                A2 = similar(A, ArrayTestVal, (4, 5))
                _wrappertype(A) == _wrappertype(A1) && eltype(A1) == ArrayTestVal && size(A1) == (2, 3) && size(A2) == (4, 5) 
            end,
    )
)

_wrappertype(A) = Base.typename(typeof(A)).wrapper

@interface ArrayInterface AbstractArray array_components "Base Julia AbstractArray interface"

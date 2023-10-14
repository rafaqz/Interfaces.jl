@interface ArrayInterface (
    mandatory = (
        iterate = A -> Interfaces.test(IterationInterface, A),
        ndims = A -> ndims(A) isa Int,
        size = (
            A -> size(A) isa NTuple{<:Any,Int},
            A -> length(size(A)) == ndims(A),
        ),
        eltype = A -> typeof(first(iterate(A))) <: eltype(A)
    ),
    # TODO implement all the optional conditions
    optional = (;
        getindex = A -> true,
        setindex = A -> true,
    ),
) "Base Julia AbstractArray interface"

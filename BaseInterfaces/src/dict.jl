
@interface DictInterface AbstractDict (
    mandatory = (;
        iterate = a -> Interfaces.test(IterationInterface, a.d; show=false) && first(iterate(a.d)) isa Pair,
        eltype = a -> eltype(a.d) <: Pair,
        getindex = a -> a.d[first(keys(a.d))] === last(first(iterate(a.d))),
    ),
    optional = (;
        setindex = a -> begin
            a.d[a.k] = a.v
            a.d[a.k] == a.v
        end,
    )
) """
`AbstractDict` interface requires Arguments, with `d = the_dict` mandatory, and
when `setindex` is needed, `k = any_valid_key_not_in_d, v = any_valid_val`
"""

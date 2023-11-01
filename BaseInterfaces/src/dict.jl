
@interface DictInterface AbstractDict ( # <: CollectionInterface
    mandatory = (;
        iterate = a -> Interfaces.test(IterationInterface, a.d; show=false) && first(iterate(a.d)) isa Pair,
        eltype = a -> eltype(a.d) <: Pair,
        keytype = a -> keytype(a.d) == eltype(a.d).parameters[1],
        valtype = a -> valtype(a.d) == eltype(a.d).parameters[2],
        getindex = a -> a.d[first(keys(a.d))] === last(first(iterate(a.d))),
        keys = a -> all(k -> k isa keytype(a.d), keys(a.d)),
        values = a -> all(v -> v isa valtype(a.d), values(a.d)),
    ),
    optional = (;
        setindex! = (
            a -> !haskey(a.d, a.k),
            a -> (a.d[a.k] = a.v; a.d[a.k] == a.v),
        ),
    )
) """
`AbstractDict` interface requires Arguments, with `d = the_dict` mandatory, and
when `setindex` is needed, `k = any_valid_key_not_in_d, v = any_valid_val`
"""


@interface DictInterface <: Union{IterationInterface{(:reverse,)}} AbstractDict ( # <: CollectionInterface
    mandatory = (;
        iterate = "AbstractDict follows the IterationInterface" => a -> Interfaces.test(IterationInterface, a.d; show=false) && first(iterate(a.d)) isa Pair,
        eltype = "eltype is a Pair" => a -> eltype(a.d) <: Pair,
        keytype = a -> keytype(a.d) == eltype(a.d).parameters[1],
        valtype = a -> valtype(a.d) == eltype(a.d).parameters[2],
        keys = a -> all(k -> k isa keytype(a.d), keys(a.d)),
        values = a -> all(v -> v isa valtype(a.d), values(a.d)),
        getindex = (
            a -> a.d[first(keys(a.d))] === first(values(a.d)),
            a -> all(k -> a.d[k] isa valtype(a.d), keys(a.d)), 
        ),
    ),
    optional = (;
        setindex! = (
            "test object `d` does not yet have test key `k`" => a -> !haskey(a.d, a.k),
            "can set key `k` to value `v`" => a -> (a.d[a.k] = a.v; a.d[a.k] == a.v),
        ),
    )
) """
`AbstractDict` interface requires Arguments, with `d = the_dict` mandatory, and
when `setindex` is needed, `k = any_valid_key_not_in_d, v = any_valid_val`
"""

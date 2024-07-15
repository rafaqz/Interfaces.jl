# This is a completely insufficient interface for AbstractDict
# See https://github.com/JuliaLang/julia/issues/25941 for discussion

@interface DictInterface AbstractDict ( # <: CollectionInterface
    mandatory = (;
        # This is kind of unsatisfactory as interface inheritance, but its simple
        iterate = "AbstractDict follows the IterationInterface" => 
            a -> Interfaces.test(IterationInterface, a.d; show=false) && first(iterate(a.d)) isa Pair,
        length = "length is defined" => a -> length(a.d) isa Integer,
        eltype = (
            "eltype is a Pair" => a -> eltype(a.d) <: Pair,
            "the first value isa eltype" => a -> eltype(a.d) <: Pair,
        ),
        keytype = "keytype is the same as the first type in eltype parameters" =>
            a -> keytype(a.d) == eltype(a.d).parameters[1],
        valtype = "valtype is the same as the second type in eltype paremeters" =>
            a -> valtype(a.d) == eltype(a.d).parameters[2],
        keys = "keys are all of type keytype" => a -> all(k -> k isa keytype(a.d), keys(a.d)),
        values = "values are all of type valtype" => a -> all(v -> v isa valtype(a.d), values(a.d)),
        getindex = (
            "getindex of the first key is the first object in `values`" =>
                a -> a.d[first(keys(a.d))] === first(values(a.d)),
            "getindex of all keys match values" =>
                a -> all(p -> a.d[p[1]] == p[2], a.d), 
        ),
    ),
    optional = (;
        setindex! = (
            "test object `d` does not yet have test key `k`" => 
                a -> !haskey(a.d, a.k),
            "can set key `k` to value `v`" => 
                a -> (a.d[a.k] = a.v; a.d[a.k] == a.v),
        ),
        get! = (
            "test object `d` does not yet have test key `k`" => a -> !haskey(a.d, a.k),
            "can set and get key `k` to value `v` with using get!" => 
                a -> begin 
                    v = get!(a.d, a.k, a.v)
                    v == a.d[a.k] == a.v
                end,
        ),
        delete! = "can delete existing keys from the object" => 
            a -> begin
                k = first(keys(a.d))
                delete!(a.d, k)
                !haskey(a.d, k)
            end,
        empty! = "can empty the dictionary" => 
            a -> begin
                empty!(a.d)
                length(a.d) == 0
            end,
    )
) """
`AbstractDict` interface

Requires test data wrapped with `Interfaces.Arguments`, with 
- `d = the_dict` mandatory
When `get!` or `setindex!` is needed
- `k`: any valid key not initially in d  
- `v`: any valid value
"""

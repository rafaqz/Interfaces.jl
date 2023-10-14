# See https://github.com/JuliaLang/julia/issues/34677

# Requirements for AbstractSet subtypes:

mandatory = (
    type = s -> s isa AbstractSet,
    eltype = "elements eltype of set `s` are subtypes of `eltype(s)`" => s -> typeof(first(iterate(s))) <: eltype(s),
    length = "set defines length and test object has length larger than zero" => s -> length(s) isa Int && length(s) > 0,
    iteration = "follows the IterationInterface" => x -> Interfaces.test(IterationInterface, x),
    copy = s -> begin
        s1 = copy(s) 
        s1 !== s && s1 isa typeof(s) && collect(s) == collect(s1)
    end,
    in = "`in` is true for elements in set" => s -> begin
        all(x -> in(x, s), s)
    end,
)

optional = (
    empty = "returns a empty set able to hold elements of type U" => s -> begin
        s1 = Base.empty(s)
        eltype(s1) == eltype(s) || return false
        s1 = Base.empty(s, Int)
        eltype(s1) == Int || return false
    end,
    emptymutable = "returns a empty set able to hold elements of type U" => s -> begin
        s1 = Base.empty(s)
        s1 isa typeof(s)
        eltype(s1) == eltype(s) || return false
        s1 = Base.empty(s, Int)
        eltype(s1) == Int || return false
    end,
    hasfastin = s -> Base.hasfastin(s) isa Bool,
    setdiff = s -> begin
        sd = setdiff(s, collect(s))
        typeof(sd) == typeof(s) && length(sd) == 0
    end,
    intersect = s -> intesect(s, itr),
    union = s -> union(s, itr),
    mutable = (
        "empty! removes all elements from the set" => s -> empty!(s),
        "delete! removes element valued x of the set" => s -> begin
            x = first(iterate(s))
            !in(delete!(s, x), x)
        end,
        "push! adds element x to the set" => s -> begin
            x = first(iterate(s))
            delete!(s, x)
            push!(s, x)
            in(s, x)
        end,
    ),
    coppymutable = s -> begin
        s1 = Base.copymutable(s)
        s1 isa typeof(s) && s1 !== s
    end,
    sizehint = s -> (sizehint!(s, n); true),
)

@interface SetInterface (; mandatory, optional) "The `AbstractSet` interface"

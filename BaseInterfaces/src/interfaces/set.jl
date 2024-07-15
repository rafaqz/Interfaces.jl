# See https://github.com/JuliaLang/julia/issues/34677

# Requirements for AbstractSet subtypes:

struct SetTestVal
    x::Int
end

set_components = (;
    mandatory = (;
        isempty = "defines `isempty` and testdata is not empty" => !isempty,
        eltype = "elements eltype of set `s` are subtypes of `eltype(s)`" => s -> typeof(first(iterate(s))) <: eltype(s),
        length = "set defines length and test object has length larger than zero" => s -> length(s) isa Int && length(s) > 0,
        # This is kind of unsatisfactory as interface inheritance, but its simple
        iteration = "follows the IterationInterface" => s -> Interfaces.test(IterationInterface, s; show=false),
    ),
    optional = (;
        copy = "creates an identical object with the same values, that is not the same object" => 
            s -> (s1 = copy(s); s1 !== s && s1 isa typeof(s) && collect(s) == collect(s1)),
        empty = (
            "returns an empty set able to hold elements of type U" => 
                s -> (s1 = Base.empty(s); isempty(s1) && eltype(s1) == eltype(s)),
            "returns an empty set able to hold elements of arbitrary types" => 
                s -> (s1 = Base.empty(s, SetTestVal); isempty(s1) && eltype(s1) == SetTestVal),
        ),
        hasfastin = "`hasfastin` returns a `Bool`" => s -> Base.hasfastin(s) isa Bool,
        setdiff = (
            "setdiff with itself is an empty set of the same type" => s -> begin
                sd = setdiff(s, collect(s))
                sd isa typeof(s) && isempty(sd)
            end,
            "setdiff with an empty set is equal to itself" => s -> begin
                sd = setdiff(s, collect(empty(s)))
                sd isa typeof(s) && sd == s
            end,
        ),
        intersect = (
            # TODO how to cleanly get the intersect with another non-empty set
            "`intersect` of set with itself is itself" => s -> intersect(s, s) == s,
            "`intersect` of set with an empty set is an empty set" => s -> intersect(s, empty(s)) == empty(s),
        ),
        union = (
            # TODO how to cleanly get the union with another non-empty set
            "union of a set with itself equals itself" => s -> union(s, s) == s,
            "union of a set an empty set equals itself" => s -> union(s, empty(s)) == s,
        ),
        copymutable = "creates an identical mutable object with the same values, that is not the same object" => 
            s -> (s1 = Base.copymutable(s); s1 !== s && s1 isa typeof(s) && collect(s) == collect(s1)),
        emptymutable = (
            "returns an empty set able to hold elements of type U" => 
                s -> (s1 = Base.emptymutable(s); isempty(s1) && eltype(s1) == eltype(s)),
            "returns an empty set able to hold elements of arbitrary types" => 
                s -> (s1 = Base.emptymutable(s, SetTestVal); isempty(s1) && eltype(s1) == SetTestVal),
        ),
        empty! =  "empty! removes all elements from the set" => isempty ∘ empty!,
        delete! = "delete! removes element valued x of the set" => 
            s -> (x = first(iterate(s)); !in(delete!(s, x), x)),
        push! = "push! adds an element to the set" => s -> begin
            # TODO do this without delete!
            x = first(iterate(s))
            delete!(s, x)
            push!(s, x)
            in(x, s)
        end,
        # No real way to test this does anything?
        sizehint! = "can set a size hint" => s -> (sizehint!(s, 10); true),
    )
)

@interface SetInterface AbstractSet set_components "The `AbstractSet` interface"

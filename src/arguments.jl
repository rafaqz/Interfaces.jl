"""
    Arguments{names,T}

    Arguments(; kw...)
    Arguments(nt::NamedTuple)

A wrapper for a `NamedTuple`.
"""
struct Arguments{names,T}
    nt::NamedTuple{names,T}
end

Arguments(; kw...) = Arguments(values(kw))
Arguments{names}(vals) where {names} = Arguments(NamedTuple{names}(vals))

nt(a::Arguments) = getfield(a, :nt)

for f in (:length, :firstindex, :lastindex, :isempty, :keys, :values)
    @eval Base.$f(a::Arguments) = $f(nt(a))
end

for f in (:(==), :isequal, :<, :isless, :isapprox)
    @eval Base.$f(a1::Arguments, a2::Arguments) = $f(nt(a1), nt(a2))
end

Base.iterate(a::Arguments, iter=1) = iterate(nt(a), iter)

Base.getindex(a::Arguments, i::Union{<:Integer, Symbol}) = getindex(nt(a), i)
Base.getindex(a::Arguments, ::Colon) = a
Base.getindex(a::Arguments, idxs::Union{<:Tuple{Vararg{Symbol}},AbstractVector{Symbol}}) = Arguments(nt(a)[idxs])

Base.haskey(a::Arguments, key::Union{<:Integer,Symbol}) = haskey(nt(a), key)

Base.getproperty(a::Arguments, key::Symbol) = getproperty(nt(a), key)

first_field_type(::Type{Arguments{names,T}}) where {names,T} = first(fieldtypes(T))

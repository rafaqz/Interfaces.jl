
# TODO add grouping to reduce the number of options
@implements SetInterface{(:copy,:empty,:emptymutable,:hasfastin,:setdiff,:intersect,:union,:empty!,:delete!,:push!,:copymutable,:sizehint!)} Set [Set((1, 2))]
@implements SetInterface{(:copy,:empty,:emptymutable,:hasfastin,:setdiff,:intersect,:union,:empty!,:delete!,:push!,:copymutable,:sizehint!)} BitSet [BitSet((1, 2))]
@implements SetInterface{(:empty,:emptymutable,:hasfastin,:intersect,:union,:sizehint!)} Base.KeySet [Base.KeySet(Dict(:a=>1, :b=>2))]
@implements SetInterface{(:empty,:hasfastin,:intersect,:union,:sizehint!)} Base.IdSet (s = Base.IdSet(); push!(s, "a"); push!(s, "b"); [s])


# Should iteration be here?

mandatory = (;
    isempty = !isempty,
)

optional = (; 
    empty! = c -> isempty(empty!(c)),
    length = c -> length(c) isa Integer,
    # push! = 
    # pushfirst! = 
    # deleteat! = 
    # splice! = 
    # pop! = 
    # popfirst! = 
)

components = (; mandatory, optional)

@interface CollectionInterface Any _components "Base interface for shared methods of various collections"

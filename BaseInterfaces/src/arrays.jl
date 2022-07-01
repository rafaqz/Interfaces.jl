
@define AbstractArrayInterface x begin

    @mandatory size begin
        len = length(x)
        @insist length(x) = prod(size(x))
        @insist ndims(x) = length(size(x))
    end

    @mandatory getindex_linear begin
        getindex(x, firstindex(x)) = first(x)
        getindex(x, lastindex(x)) = last(x)
    end

    @optional iteration begin
        iterate(x)
    end

    @optional_group getindex begin
        @optional getindex_single begin
            @insist getindex(x, size(x)...) == last(x)
            @insist getindex(x, CartesianIndex(1, 1), 1) == x[1]
        end

        @optional getindex_range begin
            @insist getindex(x, size(x)...) == last(x)
            @insist getindex(x, CartesianIndex(1, 1), 1) == x[1]
        end

        @optional getindex_binary begin
            @insist getindex(x, size(x)...) == last(x)
            @insist getindex(x, CartesianIndex(1, 1), 1) == x[1]
        end
    end

    @optional_group setindex begin
        getindex(x)
        @insist x = 1
    end

    @optional broadcast begin
        x .* 2 == x * 2 
        @insist x = 1
    end

end

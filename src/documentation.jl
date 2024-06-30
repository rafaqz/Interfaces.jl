function _help_header(@nospecialize(interface::Type{<:Interface}))
    m_keys = mandatory_keys(interface)
    o_keys = optional_keys(interface)
    return "An Interfaces.jl `Interface` with mandatory components `$m_keys` and optional components `$o_keys`."
end

function _extended_help(@nospecialize(interface::Type{<:Interface}))
    comp = components(interface)

    io_buf = IOBuffer()
    # ^(More efficient and readable than string concatenation)

    println(io_buf, "# Extended help")
    !isempty(comp.mandatory) && println(io_buf, "\n## Mandatory keys:\n")
    _list_keys(io_buf, comp.mandatory)

    !isempty(comp.optional) && println(io_buf, "\n## Optional keys:\n")
    _list_keys(io_buf, comp.optional)

    return String(take!(io_buf))
end

function _list_keys(io::IO, @nospecialize(component))
    for key in keys(component)
        print(io, "* `$key`")
        values = component[key]
        if values isa Tuple && all(Base.Fix2(isa, Pair), values)
            # Such as `iterate = ("description1" => f, "description2" => g)`
            println(io, ":")
            for value in values
                println(io, "  * $(first(value))")
            end
        elseif values isa Pair
            # Such as `iterate = "description" => f`
            println(io, ": $(first(values))")
        else
            # all other cases, like `iterate = f`
            println(io)
        end
    end
    return nothing
end

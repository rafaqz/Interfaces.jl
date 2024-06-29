function header(interface::Type{<:Interface})
    m_keys = mandatory_keys(interface)
    o_keys = optional_keys(interface)
    return "An Interfaces.jl `Interface` with mandatory components `$m_keys` and optional components `$o_keys`."
end

function extended_help(interface::Type{<:Interface})
    comp = components(interface)

    io_buf = IOBuffer()
    # ^(More efficient and readable than string concatenation)

    println(io_buf, "# Extended help")
    !isempty(comp.mandatory) && println(io_buf, "\n## Mandatory keys:\n")
    for key in keys(comp.mandatory)
        values = comp.mandatory[key]
        if values isa Tuple
            println(io_buf, "* `$key`:")
            for value in values
                println(io_buf, "  * $(first(value))")
            end
        else
            println(io_buf, "* `$key`: $(first(values))")
        end
    end

    !isempty(comp.optional) && println(io_buf, "\n## Optional keys:\n")
    for key in keys(comp.optional)
        values = comp.optional[key]
        if values isa Tuple
            println(io_buf, "* `$key`:")
            for value in values
                println(io_buf, "  * $(first(value))")
            end
        else
            println(io_buf, "* `$key`: $(first(values))")
        end
    end

    return String(take!(io_buf))
end

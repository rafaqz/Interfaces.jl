function header(interface::Type{<:Interface})
    m_keys = mandatory_keys(interface)
    o_keys = optional_keys(interface)
    return "An Interfaces.jl `Interface` with mandatory components `$m_keys` and optional components `$o_keys`."
end

function extended_help(@nospecialize(interface::Type{<:Interface}))
    m_keys = mandatory_keys(interface)
    o_keys = optional_keys(interface)

    io_buf = IOBuffer()
    # ^(More efficient and readable than string concatenation)

    println(io_buf, "# Extended help\n")
    println(io_buf, "## Mandatory keys:\n")
    for (key, (value, _)) in m_keys
        println(io_buf, "* `$key`: $value")
    end

    println(io_buf, "\n## Optional keys:\n")
    for (key, (value, _)) in o_keys
        println(io_buf, "* `$key`: $value")
    end

    return String(take!(io_buf))
end

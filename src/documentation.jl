function header(interface::Type{<:Interface})
    m_keys = mandatory_keys(interface)
    o_keys = optional_keys(interface)
    return "An Interfaces.jl `Interface` with mandatory components `$m_keys` and optional components `$o_keys`."
end

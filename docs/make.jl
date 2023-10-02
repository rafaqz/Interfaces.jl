using Documenter
using Interfaces
using Literate

DocMeta.setdocmeta!(Interfaces, :DocTestSetup, :(using Interfaces); recursive=true)

# Copy README
base_url = "https://github.com/rafaqz/Interfaces.jl/blob/main/"
index_path = joinpath(@__DIR__, "src", "index.md")
readme_path = joinpath(dirname(@__DIR__), "README.md")

open(index_path, "w") do io
    println(
        io,
        """
        ```@meta
        EditURL = "$(base_url)README.md"
        ```
        """,
    )
    for line in eachline(readme_path)
        println(io, line)
    end
end

# Copy test files
Literate.markdown(
    joinpath(dirname(@__DIR__), "test", "basic.jl"),
    joinpath(@__DIR__, "src")
)
Literate.markdown(
    joinpath(dirname(@__DIR__), "test", "advanced.jl"),
    joinpath(@__DIR__, "src")
)

makedocs(;
    modules=[Interfaces],
    authors="Rafael Schouten <rafaelschouten@gmail.com>",
    sitename="Interfaces.jl",
    format=Documenter.HTML(;
        repolink="https://github.com/rafaqz/Interfaces.jl",
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://rafaqz.github.io/Interfaces.jl",
        edit_link="main",
    ),
    pages=[
        "Home" => "index.md",
        "API reference" => "api.md",
        "Examples" => [
            "Basic" => "basic.md",
            "Advanced" => "advanced.md"
        ]
    ]
)

deploydocs(;
    repo="github.com/rafaqz/Interfaces.jl",
    devbranch="main",
    push_preview=true
)

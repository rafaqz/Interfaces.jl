using Documenter
using Interfaces
using Literate

DocMeta.setdocmeta!(Interfaces, :DocTestSetup, :(using Interfaces); recursive=true)

# Copy README
cp(
    joinpath(dirname(@__DIR__), "README.md"),
    joinpath(@__DIR__, "src", "index.md"),
    force=true,
)

# Copy test files
Literate.markdown(
    joinpath(dirname(@__DIR__), "test", "animals.jl"),
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
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API reference" => "api.md",
        "Examples" => [
            "Basic" => "animals.md",
        ]
    ],
)

deploydocs(;
    repo="github.com/rafaqz/Interfaces.jl",
    devbranch="main",
    push_preview=true,
)

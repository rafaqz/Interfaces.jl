using Interfaces
using Documenter

DocMeta.setdocmeta!(Interfaces, :DocTestSetup, :(using Interfaces); recursive=true)

makedocs(;
    modules=[Interfaces],
    authors="Rafael Schouten <rafaelschouten@gmail.com>",
    repo="https://github.com/rafaqz/Interfaces.jl/blob/{commit}{path}#{line}",
    sitename="Interfaces.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://rafaqz.github.io/Interfaces.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/rafaqz/Interfaces.jl",
    devbranch="main",
)

using PickAssets
using Documenter

DocMeta.setdocmeta!(PickAssets, :DocTestSetup, :(using PickAssets); recursive=true)

makedocs(;
    modules=[PickAssets],
    authors="Shayan <sh0davoodi@gmail.com>",
    sitename="PickAssets.jl",
    format=Documenter.HTML(;
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

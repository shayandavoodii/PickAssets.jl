using PickAssets
using Test

tickers = ["CSCO", "RY", "SHOP", "TD", "ENB", "BN"]
startdt = "2023-7-15"
enddt = "2025-01-02"
using YFinance, Dates

data = get.(get_prices.(tickers, startdt=startdt, enddt=enddt), "vol", nothing)
vols = stack(data, dims=1)
dates = get_prices(tickers[1], startdt=startdt, enddt=enddt)["timestamp"] .|> Date

@testset "PickAssets.jl" begin
  @info "types.jl unit tests..."
  include("types.jl")

  @info "func.jl unit tests..."
  include("func.jl")

  @info "extensions unit tests..."
  include("ext.jl")
end

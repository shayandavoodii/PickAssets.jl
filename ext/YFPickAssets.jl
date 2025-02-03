module YFPickAssets

using YFinance
using PickAssets

"""
    pickassets(m::MarketCap, tickers::AbstractVector{<:String})

Pick the supreme tickers according to their market cap.

!!! note
    You need to import the `YFinance` package to use this function.

# Arguments
- `m::MarketCap`: An object of [MarketCap](@ref).
- `tickers::AbstractVector{<:String}`: The Vector of tickers.

# Returns
- `::PickedAssets`: An object of [PickedAssets](@ref).
"""
function PickAssets.pickassets(m::PickAssets.MarketCap, tickers::AbstractVector{<:String})
  m.n ≤ length(tickers) || throw(ArgumentError("The number of assets to pick must be less \
  than or equal to the number of tickers."))
  caps::Vector{Int} = map(x->x["marketCap"], get_summary_detail.(tickers))
  meancaps = PickAssets._mean(caps)
  idxs = findall(caps.≥meancaps)[1:m.n]
  res = Dict(tickers[i] => float(caps[i]) for i=eachindex(caps))
  return PickAssets.PickedAssets(meancaps, tickers[idxs], idxs, res)
end

end #module

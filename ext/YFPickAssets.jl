module YFPickAssets

using YFinance
using PickAssets

"""
    pickassets(m::MarketCap, tickers::AbstractVector{<:AbstractString})

Pick the supreme tickers according to their market cap.

!!! note
    You need to import the `YFinance` package to use this function.

# Arguments
- `m::MarketCap`: An object of [MarketCap](@ref).
- `tickers::AbstractVector{<:String}`: The Vector of tickers.

# Returns
- `::PickedAssets`: An object of [PickedAssets](@ref).
"""
function PickAssets.pickassets!(m::PickAssets.MarketCap, tickers::AbstractVector{<:String})
  m.n ≤ length(tickers) || throw(ArgumentError("The number of assets to pick must be less \
  than or equal to the number of tickers."))
  caps::AbstractVector{<:Union{Nothing, Integer}} = get.(get_summary_detail.(tickers), "marketCap", nothing)
  all(isnothing, caps) && return nothing
  if any(isnothing, caps)
    idxnothing = findall(isnothing, caps)
    @warn "There is no market cap recorded for $(tickers[idxnothing]). These tickers will get \
    deleted from the `tickers` Vector."
    deleteat!(caps, idxnothing)
    deleteat!(tickers, idxnothing)
    if length(caps)==1
      @info "There is only one ticker with a market cap recorded. This ticker will be picked."
      return PickAssets.PickedAssets(caps[1], tickers[1], 1, Dict(tickers[1] => float(caps[1])))
    end
  end
  meancaps = PickAssets._mean(caps)
  idxs = findall(caps.≥meancaps)
  if length(idxs) < m.n
    @warn "The number of assets to pick is greater than the number of tickers with a market \
    cap greater than the mean. The most possible number of assets ($(length(idxs))) will be picked."
    idxs = idxs[1:length(idxs)]
  else
    idxs = idxs[1:m.n]
  end
  res = Dict(tickers[i] => float(caps[i]) for i=eachindex(caps))
  return PickAssets.PickedAssets(meancaps, tickers[idxs], idxs, res)
end

end #module

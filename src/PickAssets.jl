module PickAssets

using Dates
using StatsBase

include("Types.jl")

export pickassets, HighVolume, RandomWise, ValueBased, DateBased, Monthly, Yearly

pickassets(m::RandomWise, tickers::AbstractVector{<:String}) = sample(tickers, m.n, replace=false)

function pickassets(
  m::HighVolume,
  tickers::AbstractVector{<:String},
)
  if m.partition isa DateBased
    ranges = _partition(m.partition.span, m.dates)
  else
    ranges = _partition(m.partition.span, m.vol[1, :])
  end
  eachyearvol = stack([vec(mean(m.vol[:, r], dims=2)) for r=ranges], dims=2)
  overalmean = mean(eachyearvol, dims=2)
  meanoveralmean = mean(overalmean, dims=1) |> only
  res = Dict(tickers[i] => overalmean[i] for i=eachindex(tickers))
  supremetickers = (keys(res) |> collect)[findall(meanoveralmean.≤values(res))]
  idxsupremes = findall(x->x∈supremetickers, tickers)
  return PickedAssets(meanoveralmean, supremetickers, idxsupremes, res)
end

function _partition(::Yearly, dates::AbstractVector{<:Date})
  uniqueyears = unique(year.(dates))
  ranges = Memory{UnitRange}(undef, length(uniqueyears))
  for (idx, year_) ∈ enumerate(uniqueyears)
    idxs = findall(year.(dates).==year_)
    ranges[idx] = range(idxs[1], idxs[end])
  end
  return ranges
end

function _partition(::Monthly, vals::AbstractVector{<:Date})
  currentmonth, currentyear = month(first(vals)), year(first(vals))
  lastmonth, lastyear = month(last(vals)), year(last(vals))
  nmonths_ = nmonths(currentyear, currentmonth, lastyear, lastmonth)
  ranges = Memory{UnitRange}(undef, nmonths_)
  for i ∈ 1:nmonths_
    ranges[i] = range(findfirst((month.(vals) .== currentmonth).&&(year.(vals) .== currentyear)), findlast((month.(vals) .== currentmonth).&&(year.(vals) .== currentyear)))
    currentmonth = nextmonth(currentmonth)
    currentyear += currentmonth == 12 ? 1 : 0
  end
  return ranges
end

function _partition(type::Span, vals::AbstractVector)
  span = length(vals)
  nperiods = span/type.val |> ceil |> Int
  ranges = Memory{UnitRange}(undef, nperiods)
  for i ∈ 1:nperiods
    ranges[i] = range((i-1)*type.val+1, i*type.val)
  end
  if last(ranges).stop > span
    ranges[end] = range(last(ranges).start, span)
  end
  return ranges
end

nextmonth(id::Int) = id==12 ? 1 : id+1

nmonths(y1::Int, m1::Int, y2::Int, m2::Int) = abs(y1-y2)*12 + abs(m1 - m2)

mean(series::AbstractVector) = sum(series) / length(series)

mean(mat::AbstractMatrix; dims::Int) = sum(mat, dims=dims) / size(mat, dims)

end

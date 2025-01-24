module PickAssets

using Dates
using StatsBase

include("Types.jl")

export pickassets, HighVolatility, HighVolume, RandomWise, ValueBased, DateBased, Monthly, Yearly

function pickedassets(overalmethod::AbstractMatrix, tickers::AbstractVector{<:String})
  meanoveralmethod = _mean(overalmethod, dims=1) |> only
  res = Dict(tickers[i] => overalmethod[i] for i=eachindex(tickers))
  supremetickers = (keys(res) |> collect)[findall(meanoveralmethod.≤values(res))]
  idxsupremes = findall(x->x∈supremetickers, tickers)
  return PickedAssets(meanoveralmethod, supremetickers, idxsupremes, res)
end

function pickassets(m::HighVolatility, tickers)
  ranges = _ranges(m)
  eachspanvol = stack([vec(_std(m.val[:, r], dims=2)) for r=ranges], dims=2)
  overalstd = _mean(eachspanvol, dims=2)
  return pickedassets(overalstd, tickers)
end

function pickassets(m::RandomWise, tickers::AbstractVector{<:String})
  sup = sample(tickers, m.n, replace=false)
  idx = findall(x->x∈sup, tickers)
  res = Dict{String, Float64}()
  return PickedAssets(-1., sup, idx, res)
end

function pickassets(
  m::HighVolume,
  tickers::AbstractVector{<:String},
)
  ranges = _ranges(m)
  eachspanvol = stack([vec(_mean(m.val[:, r], dims=2)) for r=ranges], dims=2)
  overalmean = _mean(eachspanvol, dims=2)
  return pickedassets(overalmean, tickers)
end

function _ranges(m::Method)
  if m.partition isa DateBased
    return _partition(m.partition.span, m.dates)
  else
    return _partition(m.partition.span, m.val[1, :])
  end
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

_mean(series::AbstractVector) = sum(series) / length(series)

_mean(mat::AbstractMatrix; dims::Int) = sum(mat, dims=dims) / size(mat, dims)

function _var(series::AbstractVector)
  mean_ = _mean(series)
  return sum((series .- mean_).^2) / (length(series)-1)
end

function _var(mat::AbstractMatrix; dims::Int)
  mean_ = _mean(mat, dims=dims)
  return sum((mat .- mean_).^2, dims=dims) / (size(mat, dims)-1)
end

_std(series::AbstractVector) = √_var(series)

_std(mat::AbstractMatrix; dims::Int) = sqrt.(_var(mat, dims=dims))

end # module

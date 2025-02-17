module PickAssets

using Dates
using StatsBase: sample

include("Types.jl")

export pickassets, pickassets!, HighVolatility, HighVolume, RandomWise, ValueBased
export MarketCap, DateBased, Monthly, Seasonally, Yearly

function pickedassets(overalmethod::AbstractMatrix, tickers::AbstractVector{<:AbstractString})
  meanoveralmethod = _mean(overalmethod, dims=1) |> only
  res = Dict(tickers[i] => overalmethod[i] for i=eachindex(tickers))
  supremetickers = (keys(res) |> collect)[findall(meanoveralmethod.≤values(res))]
  idxsupremes = findall(x->x∈supremetickers, tickers)
  return PickedAssets(meanoveralmethod, supremetickers, idxsupremes, res)
end

function pickassets! end

"""
    pickassets(m::HighVolatility, tickers::AbstractVector{<:AbstractString})

Pick the supreme tickers using the [HighVolatility](@ref) method. According to this method, /
the supreme tickers are the ones that have the highest average of the standard deviation in /
each [Span](@ref) regarding the [Partition](@ref) method.

# Arguments
- `m::HighVolatility`: An object of [HighVolatility](@ref).
- `tickers::AbstractVector{<:AbstractString}`: The Vector of tickers.

# Returns
- `::PickedAssets`: An object of [PickedAssets](@ref).
"""
function pickassets(m::HighVolatility, tickers::AbstractVector{<:AbstractString})
  ranges = _ranges(m)
  eachspanvol = stack([vec(_std(m.val[:, r], dims=2)) for r=ranges], dims=2)
  overalstd = _mean(eachspanvol, dims=2)
  return pickedassets(overalstd, tickers)
end

"""
    pickassets(m::RandomWise, tickers::AbstractVector{<:AbstractString})

Randomly pick `m` tickers from the `tickers` Vector.

# Arguments
- `m::RandomWise`: An object of [RandomWise](@ref).
- `tickers::AbstractVector{<:AbstractString}`: The Vector of tickers.

# Returns
- `::PickedAssets`: An object of [PickedAssets](@ref) comprised of `-1.` as the overal mean, /
  the supreme tickers (randomly chosen), the indexes of the supreme tickers and an empty /
  dictionary as the overal result. In summary, the `sup` and `idx` fields are the main /
  fields of the returned object in this case.
"""
function pickassets(m::RandomWise, tickers::AbstractVector{<:AbstractString})
  sup = sample(tickers, m.n, replace=false)
  idx = findall(x->x∈sup, tickers)
  res = Dict{String, Float64}()
  return PickedAssets(-1., sup, idx, res)
end

"""
    pickassets(m::HighVolume, tickers::AbstractVector{<:AbstractString})

Pick the supreme tickers using the [HighVolume](@ref) method. According to this method, /
the supreme tickers are the ones that have the highest average of the volume in /
each [Span](@ref) regarding the [Partition](@ref) method.

# Arguments
- `m::HighVolume`: An object of [HighVolume](@ref).
- `tickers::AbstractVector{<:AbstractString}`: The Vector of tickers.

# Returns
- `::PickedAssets`: An object of [PickedAssets](@ref).
"""
function pickassets(
  m::HighVolume,
  tickers::AbstractVector{<:AbstractString},
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
    currentyear += currentmonth == 12 ? 1 : 0
    currentmonth = nextmonth(currentmonth)
  end
  return ranges
end

function _partition(::Seasonally, vals::AbstractVector{<:Date})
  currentseason, currentyear = quarterofyear(first(vals)), year(first(vals))
  lastseason, lastyear = quarterofyear(last(vals)), year(last(vals))
  nseasons_ = nseasons(currentyear, currentseason, lastyear, lastseason)
  ranges = Memory{UnitRange}(undef, nseasons_)
  for i ∈ 1:nseasons_
    ranges[i] = range(findfirst((quarterofyear.(vals) .== currentseason).&&(year.(vals) .== currentyear)), findlast((quarterofyear.(vals) .== currentseason).&&(year.(vals) .== currentyear)))
    currentyear += currentseason == 4 ? 1 : 0
    currentseason = nextseason(currentseason)
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

nextseason(id::Int) = id==4 ? 1 : id+1

nmonths(y1::Int, m1::Int, y2::Int, m2::Int) = abs(y1-y2)*12 + abs(m1 - m2)

nseasons(y1::Int, q1::Int, y2::Int, q2::Int) = abs(y1-y2)*4 + (4-q1) + (4-q2)

_mean(series::AbstractVector) = sum(series) / length(series)

_mean(mat::AbstractMatrix; dims::Int) = sum(mat, dims=dims) / size(mat, dims)

function _var(mat::AbstractMatrix; dims::Int)
  mean_ = _mean(mat, dims=dims)
  return sum((mat .- mean_).^2, dims=dims) / (size(mat, dims)-1)
end

_std(mat::AbstractMatrix; dims::Int) = sqrt.(_var(mat, dims=dims))

end # module



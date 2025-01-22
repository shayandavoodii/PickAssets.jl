module PickAssets

using Dates

include("Types.jl")

export highvolatility, ValueBased, DateBased, Monthly, Yearly

function highvolatility(
  dates::AbstractVector{<:Date},
  partition::Partition,
  vol::AbstractMatrix{<:AbstractFloat},
  tickers::AbstractVector{<:String},
)
  if partition isa DateBased
    ranges = _partition(partition.span, dates)
  else
    ranges = _partition(partition.span, vol[1, :])
  end
  eachyearvol = stack([vec(mean(vol[:, r], dims=2)) for r=ranges], dims=2)
  overalmean = mean(eachyearvol, dims=2)
  return Dict(tickers[i] => overalmean[i] for i=eachindex(tickers)), mean(overalmean)
end

function _partition(::Yearly, dates::AbstractVector{<:Date})
  uniqueyears = unique(year.(dates))
  rangesfinal = UnitRange{Int}[]
  for year_ ∈ uniqueyears
    idxs = findall(year.(dates).==year_)
    push!(rangesfinal, range(idxs[1], idxs[end]))
  end
  return rangesfinal
end

function _partition(::Monthly, vals::AbstractVector{<:Date})
  currentmonth, currentyear = month(first(vals)), year(first(vals))
  lastmonth, lastyear = month(last(vals)), year(last(vals))
  nmonths_ = nmonths(currentyear, currentmonth, lastyear, lastmonth)
  ranges = UnitRange{Int}[]
  for _ ∈ 1:nmonths_
    push!(ranges, range(findfirst((month.(vals) .== currentmonth).&&(year.(vals) .== currentyear)), findlast((month.(vals) .== currentmonth).&&(year.(vals) .== currentyear))))
    currentmonth = nextmonth(currentmonth)
    currentyear += currentmonth == 12 ? 1 : 0
  end
  return ranges
end

function _partition(type::Span, vals::AbstractVector)
  nperiods = length(vals)/type.val |> ceil |> Int
  ranges = UnitRange{Int}[]
  for i ∈ 1:nperiods
    push!(ranges, range((i-1)*type.val+1, i*type.val))
  end
  if last(ranges).stop > length(vals)
    ranges[end] = range(ranges[end].start, length(vals))
  end
  return ranges
end

nextmonth(id::Int) = id==12 ? 1 : id+1

nmonths(y1::Int, m1::Int, y2::Int, m2::Int) = abs(y1-y2)*12 + abs(m1 - m2)

end

abstract type Method end
abstract type Partition end
abstract type Span end

"""
    HighVolatility(val::AbstractMatrix{<:AbstractFloat}, dates::AbstractVector{Date}, partition::Partition)

HighVolatility method.

# Fields
- `val::AbstractMatrix{<:AbstractFloat}`: Matrix of close price with dimensions (n_assets, n_dates).
- `dates::AbstractVector{Date}`: Vector of dates.
- `partition::Partition`: [Partition](@ref) method.
"""
struct HighVolatility{T<:AbstractMatrix{<:AbstractFloat}, S<:AbstractVector{Date}, F<:Partition} <: Method
  val::T
  dates::S
  partition::F
end
struct HighVolume{T<:AbstractMatrix{<:AbstractFloat}, S<:AbstractVector{Date}, F<:Partition} <: Method
  val::T
  dates::S
  partition::F
end

"""
    RandomWise(n::Int)

RandomWise method.

# Fields
- `n::Int`: Number of assets to pick.
"""
struct RandomWise{T<:Int} <: Method
  n::T
  function RandomWise(n::T) where T
    n≤0 && throw(ArgumentError("`n` must be a positive integer."))
    new{T}(n)
  end
end

"""
    MarketCap(n::Int)

MarketCap method.

# Fields
- `m::Int`: Number of assets to pick.
"""
struct MarketCap{T<:Int} <: Method
  n::T
  function MarketCap(n::T) where T
    n≤0 && throw(ArgumentError("`n` must be a positive integer."))
    new{T}(n)
  end
end

"""
    DateBased(span::Span)

DateBased partition.

# Fields
- `span::Span`: [Span](@ref) method.
"""
struct DateBased{T<:Span} <: Partition
  span::T
end

"""
    ValueBased(span::Span)

ValueBased partition.

# Fields
- `span::Span`: [Span](@ref) method.
"""
struct ValueBased{T<:Span} <: Partition
  span::T
end

"""
    Yearly(val::Int)

Yearly span.

# Fields
- `val::Int=252`: Number of days in a year.
"""
@kwdef struct Yearly{T<:Int} <: Span
  val::T=252
  function Yearly(val::T) where T
    val≤0 && throw(ArgumentError("`val` must be a positive integer."))
    new{T}(val)
  end
end

"""
    Monthly(val::Int)

Monthly span.

# Fields
- `val::Int=21`: Number of days in a month.
"""
@kwdef struct Monthly{T<:Int} <: Span
  val::T=21
  function Monthly(val::T) where T
    val≤0 && throw(ArgumentError("`val` must be a positive integer."))
    new{T}(val)
  end
end

"""
    Seasonally(val::Int)

Seasonal span.

# Fields
- `val::Int=62`: Number of days in a season (quarter).
"""
@kwdef struct Seasonally{T<:Int} <: Span
  val::T=62
  function Seasonally(val::T) where T
    val≤0 && throw(ArgumentError("`val` must be a positive integer."))
    new{T}(val)
  end
end

"""
    PickedAssets{F<:AbstractFloat, T1<:AbstractVector{<:AbstractString}, T2<:AbstractVector{Int}, S<:Dict{<:AbstractString, F}}

The final result of the [pickassets](@ref) function which contains the overal mean of the \
dired [Method](@ref), the supreme tickers, the indexes of the supreme tickers and an \
ovierview of overal result through a dictionary.

# Fields
- `mean::F`: Overal mean of the dired [Method](@ref).
- `sup::T1`: Supreme tickers.
- `idx::T2`: Indexes of the supreme tickers.
- `res::S`: Overal result.
"""
struct PickedAssets{F<:AbstractFloat, T1<:AbstractVector{<:AbstractString}, T2<:AbstractVector{Int}, S<:Dict{<:AbstractString, F}}
  mean::F
  sup::T1
  idx::T2
  res::S
  sorted::T2
end

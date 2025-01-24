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

struct RandomWise{T<:Int} <: Method
  n::T
end

struct DateBased{T<:Span} <: Partition
  span::T
end

struct ValueBased{T<:Span} <: Partition
  span::T
end

@kwdef struct Yearly{T<:Int} <: Span
  val::T=252
end
@kwdef struct Monthly{T<:Int} <: Span
  val::T=21
end

struct Seasonaly <: Span end

struct PickedAssets{F<:AbstractFloat, T1<:AbstractVector{String}, T2<:AbstractVector{Int}, S<:Dict{String, F}}
  mean::F
  sup::T1
  idx::T2
  res::S
end

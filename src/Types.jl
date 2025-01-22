abstract type Method end
abstract type Partition end
abstract type Span end

struct HighVolatility <: Method end
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

struct PickedAssets{F<:AbstractFloat, T<:AbstractVector, S<:Dict{String, F}}
  mean::F
  sup::T
  res::S
end

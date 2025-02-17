@testset "YFPickAssets.jl" begin
  mc = MarketCap(3)
  r = pickassets!(mc, tickers)
  @test length(r.idx) ≤ mc.n
  @test r isa PickAssets.PickedAssets
  @test_throws ArgumentError pickassets!(mc, tickers[1:2])

  mc = MarketCap(3)
  r = pickassets!(mc, tickers[1:3])
  @test length(r.idx) < mc.n
  @test r isa PickAssets.PickedAssets

  mc = MarketCap(2)
  r = pickassets!(mc, tickers)
  @test length(r.idx) == mc.n
  @test r isa PickAssets.PickedAssets
end

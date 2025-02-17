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

  tickers_ = ["689009.SS", "MSFT", "TSLA", "AAPL"]
  @test_logs (:warn, r"There is no market cap recorded for \[\"689009.SS\"\]. These tickers will get deleted from the `tickers` Vector.") pickassets!(mc, tickers_)
  tickers_ = ["689009.SS", "MSFT", "TSLA", "AAPL"]
  mc = MarketCap(2)
  r = pickassets!(mc, tickers_)
  @test length(r.idx) == mc.n
  @test r isa PickAssets.PickedAssets
  @test tickers_ == ["MSFT", "TSLA", "AAPL"]
  @test length(r.idx) == 2

  tickers_ = ["MSFT", "689009.SS"]
  mc = MarketCap(2)
  r = pickassets!(mc, tickers_)
  @test tickers_ == ["MSFT"]
  @test length(r.idx) == 1
  @test r.idx == [1]
  @test r.sup == ["MSFT"]

end

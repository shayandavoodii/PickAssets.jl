vus = HighVolume(vols, dates, DateBased(Seasonally()))
vus_ = HighVolume(vols, dates, ValueBased(Seasonally(50)))
vuy = HighVolume(vols, dates, DateBased(Yearly()))
vuy_ = HighVolume(vols, dates, ValueBased(Yearly(200)))
vum = HighVolume(vols, dates, DateBased(Monthly()))
vum_ = HighVolume(vols, dates, ValueBased(Monthly(21)))

vos = HighVolatility(vols, dates, DateBased(Seasonally()))
vos_ = HighVolatility(vols, dates, ValueBased(Seasonally(50)))
voy = HighVolatility(vols, dates, DateBased(Yearly()))
voy_ = HighVolatility(vols, dates, ValueBased(Yearly(200)))
vom = HighVolatility(vols, dates, DateBased(Monthly()))
vom_ = HighVolatility(vols, dates, ValueBased(Monthly(21)))

rn = RandomWise(3)

r1 = pickassets(vus, tickers)
r2 = pickassets(vus_, tickers)
r3 = pickassets(vuy, tickers)
r4 = pickassets(vuy_, tickers)
r5 = pickassets(vum, tickers)
r6 = pickassets(vum_, tickers)
r7 = pickassets(rn, tickers)
r8 = pickassets(vos, tickers)

@testset "PickAssets.jl" begin

  @test r1 isa PickAssets.PickedAssets
  @test r2 isa PickAssets.PickedAssets
  @test r3 isa PickAssets.PickedAssets
  @test r4 isa PickAssets.PickedAssets
  @test r5 isa PickAssets.PickedAssets
  @test r6 isa PickAssets.PickedAssets
  @test r7 isa PickAssets.PickedAssets
  @test r8 isa PickAssets.PickedAssets

  @test length(r7.idx) == rn.n
  @test r6.res[tickers[r6.sorted[1]]] == maximum(values(r6.res))
  @test r6.res[tickers[r6.sorted[end]]] == minimum(values(r6.res))

  r = PickAssets._ranges(vus)
  @test length(r) == 5
  for idx ∈ 2:lastindex(r)
    @test r[idx][begin] == r[idx-1][end] + 1
  end

  @testset "utils" begin
    @test PickAssets._mean([1, 2]) == 1.5
  end
end

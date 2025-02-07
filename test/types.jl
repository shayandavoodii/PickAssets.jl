@testset "Types.jl" begin

  @testset "With valid arguments" begin
    m = RandomWise(2)
    @test hasproperty(m, :n)
    @test m.n isa Int

    m = MarketCap(3)
    @test hasproperty(m, :n)
    @test m.n isa Int

    m = Monthly(3)
    @test hasproperty(m, :val)
    @test m.val isa Int

    m = Monthly()
    @test hasproperty(m, :val)
    @test m.val isa Int

    m = Yearly(3)
    @test hasproperty(m, :val)
    @test m.val isa Int

    m = Yearly()
    @test hasproperty(m, :val)
    @test m.val isa Int

    m = Seasonally(3)
    @test hasproperty(m, :val)
    @test m.val isa Int

    m = Seasonally()
    @test hasproperty(m, :val)
    @test m.val isa Int

  end

  @testset "With invalid arguments" begin
    @test_throws ArgumentError RandomWise(0)
    @test_throws ArgumentError RandomWise(-1)
    @test_throws ArgumentError MarketCap(0)
    @test_throws ArgumentError MarketCap(-1)
    @test_throws ArgumentError Monthly(0)
    @test_throws ArgumentError Monthly(-1)
    @test_throws ArgumentError Yearly(0)
    @test_throws ArgumentError Yearly(-1)
    @test_throws ArgumentError Seasonally(0)
    @test_throws ArgumentError Seasonally(-1)

  end

end

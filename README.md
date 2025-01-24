<div align="center">

<img src="Banner.png" width="100%" height="auto" />

[![Build Status](https://github.com/shayandavoodii/PickAssets.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/shayandavoodii/PickAssets.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/shayandavoodii/PickAssets.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/shayandavoodii/PickAssets.jl)

</div>
<div align="justify">
This package aims to provide tools for creating a dataset from a universe of assets based on different criteria, such as the average volume, the average volatility, etc. during various time spans. The package is yet in its early stages and it is under development.
</div>
# Introduction

<div align="justify">
Researchers use certain datasets to analyse the performance of their proposed model or strategy. These datasets are usually created from a universe of assets based on different criteria. For example, one might want to create a dataset from a universe of stocks based on the average volume, the average volatility, etc. during various time spans. This package aims to provide tools for creating such datasets using a function called <code>pickassets</code>.
</div>
# Installation

You can install the package by running the following command in the Julia REPL:

```julia
using Pkg
Pkg.add(url="github.com/shayandavoodii/PickAssets.jl.git")
```

# Usage

<div align="justify">
As mentioned earlier, the main function of this package is <code>pickassets</code>. The function takes the following arguments:  

1. An object of type <code>Method</code>. This object specifies the method used to pick the assets. The available methods are:  
    - <code>HighVolume</code>: Picks the assets with the highest average volume during the specified time span.
    - <code>HighVolatility</code>: Picks the assets with the highest average volatility during the specified time span.
    - <code>RandomWise</code>: Picks <code>m</code> assets randomly from the passed Vector of assets.
2. A Vector of assets. This Vector should contain the names of the assets that you would like to create the dataset from.

The <code>HighVolume</code> and <code>HighVolatility</code> methods take the following additional arguments in order to specify the time span:

1. <code>val</code>: The values you intend to use for creating the dataset. I.e., the close price values of the assets (for the <code>HighVolatility</code> method), and the volume values of the assets (for the <code>HighVolume</code> method).
2. <code>dates</code>: The dates corresponding to the values passed in the <code>val</code> argument.
3. <code>partition</code>: The partition method used to partition the data. As of now, the <code>DateBased</code> and <code>ValueBased</code> methods are available which can be used in <code>Yearly</code> or <code>Monthly</code> spans. The <code>DateBased</code> method partitions the data based on the dates passed in the <code>dates</code> argument, while the <code>ValueBased</code> method partitions the data based on the values passed in the <code>val</code> argument. For example, if you pass the <code>Yearly</code> span to the <code>DateBased</code> method, the data will be partitioned into yearly spans based on the dates passed in the <code>dates</code> argument. The <code>ValueBased</code> method will partition the data into yearly spans based on the value passed to the time span. For example, if you pass the <code>Yearly(252)</code> span to the <code>ValueBased</code> method, the data will be partitioned into yearly spans each containing 252 values.

</div>

# Example

<div align="justify">
The following example demonstrates how to use the <code>pickassets</code> function to create datasets from a universe of assets based on the various configurations:
</div>

```julia
using PickAssets, Dates

# A Matrix of close price values of the assets of size (n, m)
# where n is the number of assets and m idicates the number of days.
close_prices = rand(10, 1000)
# A Vector of dates corresponding to the close price values
dates = [Date(2021, 1, 1) + Day(i) for i in 1:1000]
# A Vector of asset names
assets = ["Asset$i" for i=1:10]

# Dataset1: Picks the assets with the highest average volume in yearly time span based on the dates:
dataset1 = pickassets(HighVolume(close_prices, dates, DateBased(Yearly())), assets)

# Dataset2: Picks the assets with the highest average volume in yearly time span based on the values:
dataset2 = pickassets(HighVolume(close_prices, dates, ValueBased(Yearly(252))), assets)

# Dataset3: Picks the assets with the highest average volatility in monthly time span based on the dates:
dataset3 = pickassets(HighVolatility(close_prices, dates, DateBased(Monthly())), assets)

# Dataset4: Picks the assets with the highest average volatility in monthly time span based on the values:
dataset4 = pickassets(HighVolatility(close_prices, dates, ValueBased(Monthly(21))), assets)

# Dataset5: Picks 5 assets randomly from the universe of assets:
dataset5 = pickassets(RandomWise(5), assets)
```

<div align="justify">
The output of the <code>pickassets</code> function is an object of type <code>PickedAssets</code> which contains the following fields:

- <code>mean</code>: The mean of the performed method on <code>val</code>. I.e., the overal average of volatility (for the <code>HighVolatility</code> method) or volume (for the <code>HighVolume</code> method) over all partitions. The picked assets have definitely higher values than the <code>mean</code>.
- <code>sup</code>: The Vector of superior tickers.
- <code>idx</code>: The Vector of indexes of the superior tickers in the original Vector of assets. This can help you to find the superior tickers in the original Vector of assets.
- <code>res</code>: A <code>Dict</code> of the superior tickers and their corresponding values. This provides an overview of all tickers and their corresponding values.

</div>

```julia
dataset1.mean
# 0.49894928681020795

dataset1.sup
# 4-element Vector{String}:
#  "Asset2"
#  "Asset4"
#  "Asset10"
#  "Asset1"

dataset1.idx
# 4-element Vector{Int64}:
#   1
#   2
#   4
#  10

dataset1.res
# Dict{String, Float64} with 10 entries:
#   "Asset8"  => 0.481928
#   "Asset7"  => 0.498171
#   "Asset2"  => 0.508003
#   "Asset5"  => 0.497606
#   "Asset6"  => 0.492131
#   "Asset4"  => 0.507848
#   "Asset9"  => 0.495822
#   "Asset10" => 0.50147
#   "Asset3"  => 0.491802
#   "Asset1"  => 0.514713
```

# License

<div align="justify">
This package is released under the MIT License. Please see the <a href="https://github.com/shayandavoodii/PickAssets.jl?tab=MIT-1-ov-file#readme">LICENSE</a> file for more information.
</div>
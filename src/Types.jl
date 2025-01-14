abstract type Method end
abstract type Partition end

struct HighVolatility <: Method end
struct Random <: Method end

struct YearlyPartitioned <: Partition end
struct SeasonalyPartitioned <: Partition end
struct MonthlyPartitioned <: Partition end
struct DailyPartitioned <: Partition end

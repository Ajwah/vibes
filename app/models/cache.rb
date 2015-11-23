# This is a temporary cache table that stores the immediate results from Watson
# (e.g. /immediate/search route.) These results are not incorporated into the
# actual Tweet table to avoid dealing with the complexity of having gaps in the
# table. The temporary storage to a database is solely to leverage the same aggregation
# functionality as that of Tweet. In this way, I avoid having to maintain two
# different algorithms, e.g. the database aggregation algorithm and the previously
# in memory aggregation algorithm.
class Cache < Statistics
  def self.constraint(context)
    ""
  end

  def self.sql(context)
    constraint = self.constraint(context)
    unit = self.unit(context)
    quantity = self.quantity(context)

    sql = {
      :aggregate => "
          SELECT
              date_trunc('#{unit}', time) - (CAST(EXTRACT(#{unit} FROM time) AS integer) % #{quantity}) * interval '1 #{unit}' AS intervals,
              sentiment,
              count(*)
          FROM #{@db}
          #{constraint}
          GROUP BY sentiment, intervals
          ORDER BY sentiment, intervals;
        ",
      :min => "SELECT date_trunc('#{unit}', min) - (CAST(EXTRACT(#{unit} from min) AS integer) % #{quantity}) * interval '1 #{unit}' as intervals from (SELECT min(time) from #{@db} #{constraint}) as m;",
      :max => "SELECT date_trunc('#{unit}', max) - (CAST(EXTRACT(#{unit} from max) AS integer) % #{quantity}) * interval '1 #{unit}' as intervals from (SELECT max(time) from #{@db} #{constraint}) as m;"
    }
  end
end

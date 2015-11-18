class Tweet < Statistics
  def self.constraint(context)
    _from = context.time.time_format[:from].to_time.strftime('%Y-%m-%d %H:%M:%S')
    _until = context.time.time_format[:until].to_time.strftime('%Y-%m-%d %H:%M:%S')
    "WHERE time <= '#{_until}' and time >= '#{_from}'"
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


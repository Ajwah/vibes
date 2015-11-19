class Tweet < Statistics
  def self.constraint(context)
    term = context.term.to_db_compatible_s
    _from = context.time.time_format[:from].to_time.strftime('%Y-%m-%d %H:%M:%S')
    _until = context.time.time_format[:until].to_time.strftime('%Y-%m-%d %H:%M:%S')
    "WHERE url LIKE '%#{term}%' and time <= '#{_until}' and time >= '#{_from}'"
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
  end # Beware of potential bug with regards to @db which is only defined in statistics

  def self.total_quantity(context)
    term = context.term.to_db_compatible_s

    unit = context.stats.unit.to_s.sub('by_','').to_s
    step_unit = unit.to_sym
    in_steps_of = (context.stats.quantity).send(step_unit)

    min = context.time.time_format[:from].to_time.floor_to(in_steps_of).strftime('%Y-%m-%d %H:%M:%S')
    max = context.time.time_format[:until].to_time.floor_to(in_steps_of).strftime('%Y-%m-%d %H:%M:%S')
    sql = "url LIKE '%#{term}%' and time <= '#{max}' and time >= '#{min}'"
    db_total = Tweet.where(sql).count
  end
end


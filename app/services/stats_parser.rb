class StatsParser
  attr_reader :unit, :quantity
  VALID_STATS = [:by_seconds, :by_minutes, :by_hours, :by_days]
  DELIM = ':'
  def initialize(parameters)
    @stats = parameters.stats rescue nil
    @unit = (@stats && @stats.split(DELIM)[0].to_sym) || :by_minutes
    @quantity = (@stats && @stats.split(DELIM)[1].to_i) || 6
  end

  def errors
    "stats unit should be one of #{VALID_STATS.map(&:to_s)} deliminated with `#{DELIM}`" if ([@unit] & VALID_STATS).length != 1
  end

  def to_s
    ""
  end
end

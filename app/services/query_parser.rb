class QueryParser
  attr_reader :term, :time, :stats, :location, :query, :route

  def initialize(parameters)
    @parameters = ParametersParser.new(parameters)
    @term = TermParser.new(@parameters)
    @time = TimeParser.new(@parameters)
    @stats = StatsParser.new(@parameters)
    @location = LocationParser.new(@parameters)

    @route = @parameters.action.to_sym
    @pagination = PaginationParser.new(@parameters)

    @@parsers = [@parameters, @term, @time, @stats, @location, @pagination]
    @query = create_a_query
  end

  def create_a_query
    URI.encode(@@parsers.map(&:to_s).select(&:presence).join(' ')).gsub('\u0026',"&")
  end

  def errors?
    @@parsers.reduce(false) { |a, e| e.errors || a }
  end

  def errors
    @@parsers.map(&:errors).select(&:presence)
  end
end
class PaginationParser
  attr_reader :from, :size

  def initialize(parameters)
    @from = parameters.from.to_i rescue 0
    @size = parameters.size.to_i rescue 500
  end

  def errors
    nil
  end

  def to_s
    "&from=#{@from}&size=#{@size}"
  end
end

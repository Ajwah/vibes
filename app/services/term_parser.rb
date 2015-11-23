class TermParser
  attr_reader :contents

  def initialize(parameters)
    @contents = parameters.q.to_s rescue ""
  end

  def errors
    @contents.empty? ? "No search term provided" : nil
  end

  def to_s
    @contents.empty? ? "" : "q=#{@contents}"
  end

  def to_db_compatible_s
    @contents.split.join('+')
  end
end

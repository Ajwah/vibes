class LocationParser
  attr_reader :contents

  def initialize(parameters)
    loc = parameters.location rescue nil
    @contents = loc || ""
  end

  def errors
    nil
  end

  def to_s
    @contents.empty? ? "" : "bio_location:#{@contents}"
  end
end

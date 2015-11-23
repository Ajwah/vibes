class ParametersParser
  def initialize(parameters)
    parameters.keys.each do |key|
      instance_variable_set("@#{key}", parameters[key])
    end

    parameters.keys.each do |key|
      self.class.send(:define_method, key.to_s) do
        instance_variable_get("@#{key}")
      end
    end

    @relevant_instance_methods = self.instance_variables
                                     .map(&:to_s)
                                     .map {|e| e.sub('@','').to_sym}
  end

  def get_relevant_instance_methods
    @relevant_instance_methods
  end

  def errors?
    !@q
  end

  def errors
    errors? ? "Unable to search as the term-holder `q=` is missing." : nil
  end

  def to_s
    ""
  end
end
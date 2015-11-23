class TimeParser
  include Timestamp
  attr_reader :time_format, :unit, :quantity, :stamp

  def initialize(parameters)
    @parameters = parameters
    @unit = obtain_time_unit || :hours
    @since = nil
    @quantity = @parameters.send(@unit).to_i rescue 3
    @time_format = time_stamp(@since)
    @stamp = "#{@time_format[:from]},#{@time_format[:until]}"
  end

  def reset_stamp
    @stamp = "#{@time_format[:from]},#{@time_format[:until]}"
  end

  def update_stamp(interval)
    @stamp = "#{interval[:from]},#{interval[:until]}"
  end

  def errors
    (@parameters.get_relevant_instance_methods & TIMES).length > 1 ? "At most one time parameter allowed." : nil
  end

  def to_s
    "posted:#{@stamp}"
  end

  private
    def obtain_time_unit
      (@parameters.get_relevant_instance_methods & TIMES)[0]
    end

    def time_stamp(since)
      invoke(convert_time_to_method, since)
    end

    def invoke(time_method, since)
      if since
        method(time_method[:method]).call(time_method[:arg], since)
      else
        method(time_method[:method]).call(time_method[:arg])
      end
    end

    def convert_time_to_method
      {
        method: ('past_' + @unit.to_s).to_sym,
        arg: @quantity
      }
    end
end
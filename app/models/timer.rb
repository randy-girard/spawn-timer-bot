class Timer < Sequel::Model
  def has_window?
    window_end.to_s.length > 0 || variance.to_s.length > 0
  end

  def window_start
    _start = super

    if skip_count.to_i > 0
      s = ChronicDuration.parse(_start)
      s = s * (skip_count.to_i + 1)
      _start = ChronicDuration.output(s, :format => :short)
    end

    _start
  end

  def window_end
    _end = super

    if _end && skip_count.to_i > 0
      e = ChronicDuration.parse(_end)
      e = e * (skip_count.to_i + 1)
      _end = ChronicDuration.output(e, :format => :short)
    end

    _end
  end

  def variance
    _variance = super

    if _variance && skip_count.to_i > 0
      _variance = _variance * (skip_count.to_i + 1)
    end

    _variance
  end

  def display_window(format: :short)
    duration = nil

    parsed_variance = if variance
      ChronicDuration.parse(variance)
    end

    if window_end && parsed_variance
      ws = ChronicDuration.parse(window_start)
      we = ChronicDuration.parse(window_end)

      duration = ((we + parsed_variance) - (ws - parsed_variance))
    elsif window_end
      ws = ChronicDuration.parse(window_start)
      we = ChronicDuration.parse(window_end)

      duration = (we - ws)
    elsif parsed_variance
      ws = ChronicDuration.parse(window_start)

      duration = ((ws + parsed_variance) - (ws - parsed_variance))
    end

    if duration
      ChronicDuration.output(duration, :format => format)
    else
      nil
    end
  end
end

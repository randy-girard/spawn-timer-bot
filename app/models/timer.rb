class Timer < Sequel::Model
  def display_window
    duration = nil

    if window_end && variance
      ws = ChronicDuration.parse(window_start)
      we = ChronicDuration.parse(window_end)
      v = ChronicDuration.parse(variance)

      duration = ((we + v) - (ws - v))
    elsif window_end
      ws = ChronicDuration.parse(window_start)
      we = ChronicDuration.parse(window_end)

      duration = (we - ws)
    elsif variance
      ws = ChronicDuration.parse(window_start)
      v = ChronicDuration.parse(variance)

      duration = ((ws + v) - (ws - v))
    end

    if duration
      ChronicDuration.output(duration, :format => :short)
    else
      nil
    end
  end
end

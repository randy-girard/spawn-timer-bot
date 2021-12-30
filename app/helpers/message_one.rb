def build_timer_message(timers: nil)
  any_in_window = false
  any_need_tod = false
  any_mobs = false
  message = []

  upcoming_message = []
  in_window_message = []
  need_tod_message = []

  Timer.all.sort_by {|timer| next_spawn_time_start(timer.name, timer: timer) || Chronic.parse("100 years from now") }.reverse.each do |timer|
    window_start = ""
    starts_at = ""
    ends_at = ""
    window_end = ""
    no_window_end = false
    last_tod = ""

    if timer.last_tod
      tod = Time.at(timer.last_tod)
      last_tod = display_time_ago(tod)
      starts_at = next_spawn_time_start(timer.name, timer: timer)
      ends_at = next_spawn_time_end(timer.name, timer: timer)
      window_start = display_time_distance(starts_at)

      if timer.window_end || timer.variance
        window_end = display_time_distance(ends_at)
      else
        no_window_end = true
        window_end = window_start
      end
    else
      last_tod = false
    end

    begin
      if !last_tod
        any_need_tod = true
        need_tod_message << timer.name
      elsif in_window(timer.name, timer: timer)
        if ends_at > Time.now
          percentage = "(#{(((Time.now - starts_at) / (ends_at - starts_at)) * 100).round(2)}%)"
        else
          percentage = ""
        end

        any_in_window = true
        in_window_message << "**#{timer.name}** #{percentage}"
        if ends_at < Time.now
          in_window_message << "• Ended #{window_end} ago"
        else
          in_window_message << "• Started #{window_start} ago"
          in_window_message << "• Ends In  #{window_end}"
        end
        in_window_message << ""
      else
        any_mobs = true
        upcoming_message << "**#{timer.name}**"
        if no_window_end || window_end.to_s.length == 0
          if Time.now >= starts_at - (4 * 60 * 60)
            upcoming_message << "• Spawns in #{window_start}"
          else
            upcoming_message << "• Spawns #{starts_at.in_time_zone("Eastern Time (US & Canada)").strftime("%A, %B %d at %I:%M:%S %p %Z")}"
          end
        else
          if Time.now >= starts_at - (4 * 60 * 60)
            upcoming_message << "• Starts in #{window_start}"
            upcoming_message << "• Ends in #{window_end}"
          else
            upcoming_message << "• Starts at #{starts_at.in_time_zone("Eastern Time (US & Canada)").strftime("%A, %B %d at %I:%M:%S %p %Z")}"
          end
        end
        upcoming_message << ""
      end
    rescue => ex
      puts ex
      puts ex.backtrace
    end
  end

  if any_mobs
    message << "\:dragon: __**Mobs**__ \:dragon:"
    message << ""
    message << upcoming_message
  end

  if any_in_window
    message << ""
    message << "\:window: __**Mobs In Window**__ \:window:"
    message << ""
    message << in_window_message
  end

  if any_need_tod
    message << ""
    message << "\:warning: __**Mobs needing TOD**__ \:warning:"
    message << ""
    message << need_tod_message.sort.join(", ")
  end

  message.join("\n")
end

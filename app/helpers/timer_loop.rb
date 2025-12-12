def timer_loop(timer, this_run_time)
  everyone_alert = USE_EVERYONE_ALERT ? "@everyone " : ""
  can_auto_tod = false
  save_timer = false

  if UPDATE_TIMERS_ALERT_CHANNEL && timer_update?(:timer_alert)
    if !timer.alerted
      next_spawn = next_spawn_time_end(timer.name, timer: timer)
      if in_window(timer.name, timer: timer)
        if timer.window_end || timer.variance
          if TIMER_ALERT_CHANNEL_ID.to_s.length > 0
            BOT.send_message(TIMER_ALERT_CHANNEL_ID, "#{everyone_alert}**#{timer.name}** is in window for #{display_time_distance(next_spawn)}!")
          end
        else
          if TIMER_ALERT_CHANNEL_ID.to_s.length > 0
            BOT.send_message(TIMER_ALERT_CHANNEL_ID, "#{everyone_alert}**#{timer.name}** timer is up!")
          end
          can_auto_tod = true
        end
        timer.alerted = true
        save_timer = true
      elsif alerting_soon(timer.name, timer: timer) && !timer.alerting_soon
        if timer.window_end || timer.variance
          if TIMER_ALERT_CHANNEL_ID.to_s.length > 0 && timer.warn_time.to_s != "-1"
            BOT.send_message(TIMER_ALERT_CHANNEL_ID, "#{everyone_alert}**#{timer.name}** will be in window in #{display_time_distance(next_spawn_time_start(timer.name))}!")
          end
        else
          if TIMER_ALERT_CHANNEL_ID.to_s.length > 0 && timer.warn_time.to_s != "-1"
            BOT.send_message(TIMER_ALERT_CHANNEL_ID, "#{everyone_alert}**#{timer.name}** is up in #{display_time_distance(next_spawn_time_start(timer.name))}!")
          end
        end
        timer.alerting_soon = true
        save_timer = true
      end
    end
  end

  if past_possible_spawn_time(timer.name, timer: timer)
    timer.alerted = nil
    timer.alerting_soon = nil
    save_timer = true

    if timer.auto_tod == true
      can_auto_tod = true
    end
  end

  if save_timer
    if can_auto_tod && timer.auto_tod == true
      timer.last_tod = this_run_time.to_f
      timer.alerted = nil
      timer.alerting_soon = false
      timer.skip_count = 0

      todrecord = Tod.new
      todrecord.timer_id = timer.id
      todrecord.tod = this_run_time.to_f
      todrecord.created_at = Time.now
      todrecord.save
    elsif timer.has_window?
      timer.skip_count = timer.skip_count.to_i + 1

      if timer.skip_count > 2
        timer.last_tod = nil
        timer.skip_count = 0
      end
    else
      timer.skip_count = 0
      timer.last_tod = nil
    end

    timer.save_changes

    send_timer_channel_update = true
    can_auto_tod = false
  end
end

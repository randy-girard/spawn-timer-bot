require_relative 'config/boot'

@timer_updates = {
  :timer => { last: nil, refresh: TIMER_CHANNEL_REFRESH_RATE },
  :timer_alert => { last: nil, refresh: TIMER_ALERT_CHANNEL_REFRESH_RATE }
}

puts "Starting up"
sleep 2

BOT.run(true)

channel = BOT.channel(TIMER_CHANNEL_ID)

@timer_messages = []

everyone_alert = USE_EVERYONE_ALERT ? "@everyone " : ""
send_timer_channel_update = true

while true
  begin
    this_run_time = Time.now
    timers = nil

    if UPDATE_TIMERS_CHANNEL && timer_update?(:timer)
      timers ||= Timer.all
      send_timer_channel_update = true
    end

    if UPDATE_TIMERS_ALERT_CHANNEL && timer_update?(:timer_alert)
      timers ||= Timer.all
      timers.each do |timer|
        can_auto_tod = false
        save_timer = false
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

        if past_possible_spawn_time(timer.name, timer: timer)
          timer.alerted = nil
          timer.alerting_soon = nil
          timer.last_tod = nil
          save_timer = true
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
          end

          timer.save_changes

          send_timer_channel_update = true
          can_auto_tod = false
        end
      end
    end
  rescue => ex
    puts ex.message
    puts ex.backtrace
  end

  if send_timer_channel_update
    update_timers_channel(timers: timers)
    send_timer_channel_update = false
  end

  sleep 1
end

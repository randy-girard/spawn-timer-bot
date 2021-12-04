require_relative 'config/boot'

@timer_updates = {
  :timer => { last: nil, refresh: TIMER_CHANNEL_REFRESH_RATE },
  :timer_alert => { last: nil, refresh: TIMER_ALERT_CHANNEL_REFRESH_RATE }
}

puts "Starting up"
sleep 2

BOT.run(true)

channel = BOT.channel(TIMER_CHANNEL_ID)

timer_message_id = Setting.find_by_key("timer_message_id")
if timer_message_id
  @timers_message = channel.load_message(timer_message_id)
end
update_timers_channel

while true
  begin
    timers = nil
    if UPDATE_TIMERS_CHANNEL && timer_update?(:timer)
      timers ||= Timer.all
      update_timers_channel(timers: timers)
    end


    if UPDATE_TIMERS_ALERT_CHANNEL && timer_update?(:timer_alert)
      timers ||= Timer.all
      timers.each do |timer|
        save_timer = false
        if !timer.alerted
          if in_window(timer.name, timer: timer)
            if timer.window_end || timer.variance
              next_spawn = next_spawn_time_end(timer.name, timer: timer)
              BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**#{timer.name}** is in window for #{display_time_distance(next_spawn)}!")
            else
              BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**#{timer.name}** timer is up!")
            end
            timer.alerted = true
            save_timer = true
          elsif alerting_soon(timer.name, timer: timer) && !timer.alerting_soon
            if timer.window_end || timer.variance
              BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**#{timer.name}** will be in window in an hour!")
            else
              BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**#{timer.name}** is up in one hour!")
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
          timer.save_changes
        end
      end

      update_timers_channel(timers: timers)      
    end
  rescue => ex
    puts ex.message
    puts ex.backtrace
  end

  sleep 1
end

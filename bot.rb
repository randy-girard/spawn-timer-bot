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
    if UPDATE_TIMERS_CHANNEL && timer_update?(:timer)
      update_timers_channel
    end


    if UPDATE_TIMERS_ALERT_CHANNEL && timer_update?(:timer_alert)
      Timer.all.each do |timer|
        if !timer.alerted
          if in_window(timer.name)
            if timer.window_end || timer.variance
              next_spawn = next_spawn_time_end(timer.name)
              BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**#{timer.name}** is in window for #{display_time_distance(next_spawn)}!")
            else
              BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**#{timer.name}** timer is up!")
            end
            timer.alerted = true

            update_timers_channel
          elsif alerting_soon(timer.name) && !timer.alerting_soon
            if timer.window_end || timer.variance
              BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**#{timer.name}** will be in window in an hour!")
            else
              BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**#{timer.name}** is up in one hour!")
            end
            timer.alerting_soon = true
          end
        end

        if past_possible_spawn_time(timer.name)
          timer.alerted = nil
          timer.alerting_soon = nil
          timer.last_tod = nil
        end

        timer.save_changes
      end
    end
  rescue => ex
    puts ex.message
    puts ex.backtrace
  end

  sleep 1
end

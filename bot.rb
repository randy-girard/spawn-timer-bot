require_relative 'config/boot'

@timer_updates = {
  :timer => { last: nil, refresh: TIMER_CHANNEL_REFRESH_RATE },
  :timer_alert => { last: nil, refresh: TIMER_ALERT_CHANNEL_REFRESH_RATE }
}

puts "Starting up"
sleep 2

BOT.run(true)

send_timer_channel_update = true

while true
  begin
    this_run_time = Time.now
    timers = nil

    if UPDATE_TIMERS_CHANNEL && timer_update?(:timer)
      timers ||= Timer.all
      send_timer_channel_update = true
    end

    timers ||= Timer.all
    timers.each do |timer|
      timer_loop(timer, this_run_time)
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

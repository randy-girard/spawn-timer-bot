require_relative 'config/boot'

@timer_updates = {
  :timer => { last: nil, refresh: TIMER_CHANNEL_REFRESH_RATE },
  :timer_alert => { last: nil, refresh: TIMER_ALERT_CHANNEL_REFRESH_RATE }
}

BOT = Discordrb::Commands::CommandBot.new token: TOKEN,
                                          client_id: CLIENT_ID,
                                          prefix: '!'
puts "Starting up"
sleep 2


require_relative 'lib/helpers/time'
require_relative 'lib/helpers/message'
require_relative 'lib/helpers/timer'
require_relative 'lib/commands/help'
require_relative 'lib/commands/register'
require_relative 'lib/commands/unregister'
require_relative 'lib/commands/show'
require_relative 'lib/commands/tod'
require_relative 'lib/commands/todremove'
require_relative 'lib/commands/rename'
require_relative 'lib/commands/earthquake'
require_relative 'lib/commands/leaderboard'
require_relative 'lib/commands/timers'

threads = []
threads << Thread.new {

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
          if in_window(timer.name) && !timer.alerted
            if timer.window_end || timer.variance
              next_spawn = next_spawn_time_end(timer.name)
              BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**#{timer.name}** is in window for #{display_time_distance(next_spawn)}!")
            else
              BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**#{timer.name}** timer is up!")
            end
            timer.alerted = true

            update_timers_channel
          end

          if past_possible_spawn_time(timer.name)
            timer.alerted = nil
            timer.last_tod = nil
          end

          timer.save
        end
      end
    rescue => ex
      puts ex.message
      puts ex.backtrace
    end

    sleep 1
  end
}

threads << Thread.new {
  BOT.run
}

threads.each(&:join)

BOT.command(:schedule) do |event, *args|
  if !(event.channel.id == COMMAND_CHANNEL_ID || event.channel.type == 1)
    return
  end

  days = {}
  current_date = Date.today.dup
  Timer.each do |timer|
    next_spawn = next_spawn_time_start(timer.name, timer: timer)
    if next_spawn
      next_spawn_date = next_spawn.to_date
      days[next_spawn_date] ||= []
      days[next_spawn_date] << {
        timer: timer,
        time: next_spawn
      }
    end
  end

  output = ["** **"]
  (Date.today..(Date.today + 6)).each do |day|
    timers = days.fetch(day) { [] }
    if timers.size > 0
      output << "**#{day.strftime("%A %-m/%-d")}**"
      timers.each do |timer|
        output << "#{timer[:timer].name} - #{timer[:time].strftime("%I:%m %p")} EST"
      end
      output << ""
    end
  end

  event.respond output.join("\n")
end

BOT.command(:timers) do |event|
  if !(event.channel.id == COMMAND_CHANNEL_ID || event.channel.type == 1)
    return
  end

  timers = Timer.all.select {|t| t.name.to_s.length > 0 }.map(&:name).sort

  timers_string = if event.channel.type == 1
                    timer_array = []
                    timers.each do |timer|
                      if (timer_array.join("\n").length + "#{timer}\n".length) < 2_000
                        timer_array << timer
                      else
                        break
                      end
                    end
                    timer_array.join("\n")
                  else
                    timers.join(", ").truncate(1950, omission: "...")
                  end

  event << "```"
  event << "Currently registered timers:"
  event << ""
  event << timers_string
  event << "```"
end

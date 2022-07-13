BOT.command(:timers) do |event|
  if !(event.channel.id == COMMAND_CHANNEL_ID || event.channel.type == 1)
    return
  end

  timers = Timer.all.select {|t| t.name.to_s.length > 0 }.map(&:name).sort

  timers_string = if event.channel.type == 1
                    timers.join("\n").truncate(1950, omission: "...")
                  else
                    timers.join(", ").truncate(1950, omission: "...")
                  end

  event << "```"
  event << "Currently registered timers:"
  event << ""
  event << timers_string
  event << "```"
end

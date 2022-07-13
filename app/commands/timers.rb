BOT.command(:timers) do |event|
  if !(event.channel.id == COMMAND_CHANNEL_ID || event.channel.type == 1)
    return
  end

  timers = Timer.all.select {|t| t.name.to_s.length > 0 }.map(&:name).sort

  char_length = 0
  num_timers = 0
  timers.each do |timer|
    char_length += timer.length
    if char_length > 2_000
      break
    end
    num_timers += 1
  end

  timers_string = if event.channel.type == 1
                    timers[0..(num_timers-1)].join("\n")
                  else
                    timers.join(", ").truncate(1950, omission: "...")
                  end

  event << "```"
  event << "Currently registered timers:"
  event << ""
  event << timers_string
  event << "```"
end

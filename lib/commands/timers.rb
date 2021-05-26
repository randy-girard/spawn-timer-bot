BOT.command(:timers) do |event|
  if !(event.channel.id == COMMAND_CHANNEL_ID || event.channel.type == 1)
    return
  end

  timers = Timer.all

  event << "```"
  event << "Currently registered timers:"
  event << ""
  event << timers.map(&:name).sort.join(", ")
  event << "```"
end

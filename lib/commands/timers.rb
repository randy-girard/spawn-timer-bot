BOT.command(:timers) do |event|
  return if event.channel.id != COMMAND_CHANNEL_ID

  timers = Timer.all

  event << "```"
  event << "Currently registered timers:"
  event << ""
  event << timers.map(&:name).sort.join(", ")
  event << "```"
end

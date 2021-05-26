BOT.command(:show) do |event, *args|
  return if event.channel.id != COMMAND_CHANNEL_ID

  if args.size == 0
    event << "```"
    event << "!show [mob name]"
    event << ""
    event << "Examples:"
    event << ""
    event << "!show Faydedar"
    event << "```"
    return
  end

  mob = args.join(" ")
  mob.strip!

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    event.respond "Request returned multiple results: #{timers.map {|timer| "`#{timer.name}`" }.join(", ")}. Please be more specific."
  elsif found_timer || timers.size == 1
    show_message(event, found_timer || timers[0])
  else
    event.respond "No timer registered for **#{mob}**."
  end
end

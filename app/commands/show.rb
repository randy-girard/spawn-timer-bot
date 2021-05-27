BOT.command(:show) do |event, *args|
  if !(event.channel.id == COMMAND_CHANNEL_ID || event.channel.type == 1)
    return
  end

  output = []

  if args.size == 0
    output << "```"
    output << "!show [mob name]"
    output << ""
    output << "Examples:"
    output << ""
    output << "!show Faydedar"
    output << "```"
    event.respond(output.join("\n"))
    return
  end

  mob = args.join(" ")
  mob.strip!

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    event.respond "Request returned multiple results: #{timers.map {|timer| "`#{timer.name}`" }.join(", ")}. Please be more specific."
  elsif found_timer || timers.size == 1
    msg = build_show_message(found_timer || timers[0])
    event.respond(msg)
  else
    event.respond "No timer registered for **#{mob}**."
  end
end

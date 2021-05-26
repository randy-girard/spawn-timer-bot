BOT.command(:todremove) do |event, *args|
  return if event.channel.id != COMMAND_CHANNEL_ID

  if args.size == 0
    event << "```"
    event << "!todremove [mob name]"
    event << ""
    event << "Examples:"
    event << ""
    event << "!todremove Faydedar"
    event << "```"
    return
  end

  mob = args.join(" ")
  mob.strip!

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    event.respond "Request returned multiple results: #{timers.map {|timer| "`#{timer.name}`" }.join(", ")}. Please be more specific."
  elsif found_timer || timers.size == 1
    timer = found_timer || timers[0]
    timer.last_tod = nil
    timer.save
    update_timers_channel
    event.respond "Time of death removed for **#{timer.name}**!"
  else
    event.respond "No timer registered for **#{mob}**."
  end
end

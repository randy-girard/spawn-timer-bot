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
  mob.gsub!("`", "'")

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    event.user.pm "Request returned multiple results: #{timers.map {|timer| "`#{timer.name}`" }.join(", ")}. Please be more specific."
    event.message.create_reaction("⚠️")
  elsif found_timer || timers.size == 1
    timer = found_timer || timers[0]
    timer.last_tod = nil
    timer.alerting_soon = false
    timer.alerted = nil
    timer.skip_count = 0
    timer.save
    update_timers_channel
    event.user.pm "Time of death removed for **#{timer.name}**!"
    event.message.create_reaction("✅")
  else
    event.user.pm "No timer registered for **#{mob}**."
    event.message.create_reaction("⚠️")
  end
end

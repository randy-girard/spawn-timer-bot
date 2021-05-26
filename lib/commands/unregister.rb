BOT.command(:unregister) do |event, *args|
  return if event.channel.id != COMMAND_CHANNEL_ID

  if args.size == 0
    event << "```"
    event << "!unregister [mob name]"
    event << ""
    event << "Examples:"
    event << ""
    event << "!unregister Faydedar"
    event << "!unregister Vox"
    event << "!unregister Vessel"
    event << "```"
  else
    mob = args.join(" ")
    mob.strip!

    timers, found_timer = find_timer_by_mob(mob)

    if timers.size > 1 && !found_timer
      event.respond "Request returned multiple results: #{timers.map {|timer| "`#{timer.name}`" }.join(", ")}. Please be more specific."
    elsif found_timer || timers.size == 1
      Tod.where(timer_id: found_timer.id).delete
      found_timer.delete
      update_timers_channel
      event.respond "Registered timer for [#{found_timer.name}] removed."
    else
      event.respond "No timer registered for **#{mob}**."
    end
  end
end

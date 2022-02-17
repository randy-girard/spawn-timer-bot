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
    mob.gsub!("`", "'")

    timers, found_timer = find_timer_by_mob(mob)

    if timers.size > 1 && !found_timer
      multiple_result_response(event, timers)
    elsif found_timer
      Tod.where(timer_id: found_timer.id).delete
      found_timer.delete
      update_timers_channel
      event.user.pm "Registered timer for [#{found_timer.name}] removed."
      event.message.create_reaction("✅")
    else
      event.user.pm "No timer registered for **#{mob}**."
      event.message.create_reaction("⚠️")
    end
  end
end

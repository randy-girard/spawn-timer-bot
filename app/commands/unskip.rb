def command_unskip(event, *args)
  return if event.channel.id != COMMAND_CHANNEL_ID

  if args.size == 0
    event << "```"
    event << "!unskip [mob name]"
    event << ""
    event << "Examples:"
    event << ""
    event << "!unskip Lodizal"
    event << "```"
    return
  end

  mob = args.join(" ")
  mob.strip!

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    event.user.pm "Request returned multiple results: #{timers.map {|timer| "`#{timer.name}`" }.join(", ")}. Please be more specific."
    event.message.create_reaction("⚠️")
  elsif found_timer || timers.size == 1
    timer = found_timer || timers[0]
    if timer.last_tod.to_s.length > 0
      timer.skip_count ||= 0
      timer.skip_count -= 1
      if timer.skip_count < 0
        timer.skip_count = 0
        event.user.pm "There is no previous skip recorded to remove for **#{timer.name}**!"
        event.message.create_reaction("⚠️")
      else
        timer.save
        update_timers_channel
        event.user.pm "Last skip recorded removed for **#{timer.name}**! Updating window."
        event.message.create_reaction("✅")
      end
    else
      event.user.pm "Timer **#{timer.name}** has no TOD recorded to unskip!"
      event.message.create_reaction("⚠️")
    end
  else
    event.user.pm "No timer registered for **#{mob}**."
    event.message.create_reaction("⚠️")
  end
end

BOT.command(:unskip) do |event, *args|
  command_unskip(event, *args)
end

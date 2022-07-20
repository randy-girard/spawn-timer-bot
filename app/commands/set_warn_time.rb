BOT.command(:set_warn_time) do |event, *args|
  if !(event.channel.id == COMMAND_CHANNEL_ID || event.channel.type == 1)
    return
  end

  output = []

  if args.size == 0
    output << "```"
    output << "Sets how long before a timer expires, should it send an warning alert. -1 will disable warning alert."
    output << ""
    output << "!set_warn_time [mob name]|[interval]"
    output << ""
    output << "Examples:"
    output << ""
    output << "!set_warn_time Faydedar|20 minutes"
    output << "```"
    event.respond(output.join("\n"))
    return
  end

  mob = args.join(" ")
  mob.strip!
  mob.gsub!("`", "'")

  mob, warn_time = mob.squeeze(" ").split("|")

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    multiple_result_response(event, timers)
  elsif found_timer || timers.size == 1
    found_timer.warn_time = warn_time
    found_timer.save

    event.user.pm "Alert warn time updated for **#{found_timer.name}**."
    event.message.create_reaction("✅")
  else
    event.user.pm "No timer registered for **#{mob}**."
    event.message.create_reaction("⚠️")
  end
end

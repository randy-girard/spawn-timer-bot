BOT.command(:autotod) do |event, *args|
  if event.channel.id != COMMAND_CHANNEL_ID
    return
  end

  output = []

  if args.size == 0
    output << "```"
    output << "!autotod [mob name]"
    output << ""
    output << "Examples:"
    output << ""
    output << "!autotod Faydedar"
    output << "```"
    event.respond(output.join("\n"))
    return
  end

  mob = args.join(" ")
  mob.strip!
  mob.gsub!("`", "'")

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    multiple_result_response(event, timers)
  elsif found_timer || timers.size == 1
    timer = found_timer || timers.first

    if timer.has_window?
      event.user.pm "Auto timer only allowed on timers that do not have a window or variance!"
      event.message.create_reaction("⚠️")
    else
      timer.auto_tod = !timer.auto_tod
      timer.save
      event.user.pm "Auto timer #{timer.auto_tod ? "enabled" : "disabled"} for **#{timer.name}**!"
      event.message.create_reaction("✅")
    end
  else
    event.respond "No timer registered for **#{mob}**."
  end
end

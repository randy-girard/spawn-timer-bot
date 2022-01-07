def command_register(event, *args)
  return if event.channel.id != COMMAND_CHANNEL_ID
  output = []

  if args.size == 0
    output << "```"
    output << "!register [mob name]|[window start or respawn Time](,[window end])(|[variance]) "
    output << ""
    output << "Examples:"
    output << ""
    output << "!register Faydedar|1 day"
    output << "!register Vox|1 week|8hours"
    output << "!register Vessel|2days,7days"
    output << "!register Test|1 hour, 2 hours|10 minutes"
    output << "```"
    event.respond(output.join("\n"))
  else
    mob, window, variance = args.join(" ").split("|")
    window_start, window_end = window.split(",") if window

    mob.strip!
    variance.strip! if variance
    window_start.strip! if window_start
    window_end.strip! if window_end

    if mob && mob.to_s.downcase =~ /@!?<>',?\[\]}{=\)\(*&^%$#`~{}/
      event.user.pm "Mob name [#{mob}] has invalid characters."
      event.message.create_reaction("⚠️")
      return
    end

    if window_start && !window_start.match?(/^[0-9]/)
      event.user.pm "Window Start/Spawn time [#{window_start}] is an invalid format. Please use something like '8 hours' or '6 minutes'."
      event.message.create_reaction("⚠️")
      return
    end

    if window_end && !window_end.match?(/^[0-9]/)
      event.user.pm "Window End [#{window_end}] is an invalid format. Please use something like '8 hours' or '6 minutes'."
      event.message.create_reaction("⚠️")
      return
    end

    if variance && !variance.match?(/^[0-9]/)
      event.user.pm "Variance [#{variance}] is an invalid format. Please use something like '8 hours' or '6 minutes'."
      event.message.create_reaction("⚠️")
      return
    end

    timer = Timer.where(Sequel.ilike(:name, mob.to_s)).first
    timer ||= Timer.new
    timer.name = mob.to_s.strip.gsub!("`", "'")
    timer.window_start = window_start
    timer.window_end = window_end
    timer.variance = variance
    timer.skip_count = 0
    timer.save

    update_timers_channel

    window = if window_end
               "with window between #{window_start} and #{window_end}"
             else
               "with respawn time of #{window_start}"
             end

    if variance
      window += " with variance of #{variance}"
    end

    window += " registered!"

    event.user.pm "Timer for **#{mob}** #{window}"
    event.message.create_reaction("✅")

    msg = build_show_message(timer)
    event.user.pm(msg)
  end
end

BOT.command(:register) do |event, *args|
  command_register(event, *args)
end

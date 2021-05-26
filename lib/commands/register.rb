BOT.command(:register) do |event, *args|
  return if event.channel.id != COMMAND_CHANNEL_ID

  if args.size == 0
    event << "```"
    event << "!register [mob name]|[window start or respawn Time](,[window end])(|[variance]) "
    event << ""
    event << "Examples:"
    event << ""
    event << "!register Faydedar|1 day"
    event << "!register Vox|1 week|8hours"
    event << "!register Vessel|2days,7days"
    event << "!register Test|1 hour, 2 hours|10 minutes"
    event << "```"
  else
    mob, window, variance = args.join(" ").split("|")
    window_start, window_end = window.split(",") if window

    mob.strip!
    variance.strip! if variance
    window_start.strip! if window_start
    window_end.strip! if window_end

    special = "@!?<>',?[]}{=)(*&^%$#`~{}"
    regex = /[#{special.gsub(/./){|char| "\\#{char}"}}]/
    if mob && mob.to_s.downcase =~ regex
      event.respond "Mob name [#{mob}] has invalid characters."
      return
    end

    if window_start && window_start.count("^0-9").zero?
      event.respond "Window Start/Spawn time [#{window_start}] is an invalid format. Please use something like '8 hours' or '6 minutes'."
      return
    end

    if window_end && window_end.count("^0-9").zero?
      event.respond "Window End [#{window_end}] is an invalid format. Please use something like '8 hours' or '6 minutes'."
      return
    end

    if variance && variance.count("^0-9").zero?
      event.respond "Variance [#{variance}] is an invalid format. Please use something like '8 hours' or '6 minutes'."
      return
    end

    timer = Timer.where(Sequel.ilike(:name, mob.to_s)).first
    timer ||= Timer.new
    timer.name = mob.to_s
    timer.window_start = window_start
    timer.window_end = window_end
    timer.variance = variance
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

    event.respond "Timer for **#{mob}** #{window}"

    show_message(event, timer)
  end
end

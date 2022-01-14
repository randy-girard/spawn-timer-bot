def command_tod(event, *args)
  return if event.channel.id != COMMAND_CHANNEL_ID

  if args.size == 0
    event << "```"
    event << "!tod [mob name] (|time of death) "
    event << ""
    event << "Examples:"
    event << ""
    event << "!tod Faydedar"
    event << "!tod Faydedar|10 hours ago"
    event << "!tod Faydedar 10 hours ago"
    event << "!tod Faydedar, 10 hours ago"
    event << "!tod Faydedar|last thursday at 9pm"
    event << "!tod Faydedar 2021-04-30 12:00:00pm"
    event << "!tod Faydedar, 2021-04-30 12:00:00pm"
    event << "```"
    return
  end

  mob, manual_tod = ArgumentParser.parse(args.join(" "))

  tod = if manual_tod.to_s.length > 0
    TimeParser.parse(manual_tod.to_s)
  else
    Time.now
  end

  if tod.to_s.length == 0
    event.user.pm "Unable to record that time of death. Please try again."
    event.message.create_reaction("⚠️")
    return
  end

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    event.user.pm "Request returned multiple results: #{timers.map {|timer| "`#{timer.name}`" }.join(", ")}. Please be more specific."
    event.message.create_reaction("⚠️")
  elsif found_timer || timers.size == 1
    timer = found_timer || timers[0]

    last_spawn = last_spawn_time_start(mob)

    next_spawn_start_with_tod = next_spawn_time_start(mob, last_tod: tod)
    next_spawn_end_with_tod = next_spawn_time_end(mob, last_tod: tod)

    if timer.has_window? && next_spawn_start_with_tod && next_spawn_end_with_tod && (Time.now < last_spawn || next_spawn_end_with_tod < Time.now)
      event.user.pm "Current time is outside of potential window and would have expired by now. Please try again."
      event.message.create_reaction("⚠️")
    elsif !timer.has_window? && last_spawn && manual_tod && tod < last_spawn
      event.user.pm "Time of death is older than potential spawn timer. Please try again."
      event.message.create_reaction("⚠️")
    elsif tod > Time.now
      event.user.pm "Time of death unable to be recorded due to time in the future."
      event.message.create_reaction("⚠️")
    else
      timer.last_tod = tod.to_f
      timer.alerted = nil
      timer.alerting_soon = false
      timer.skip_count = 0
      timer.save

      todrecord = Tod.new
      todrecord.timer_id = timer.id
      todrecord.user_id = event.user.id
      todrecord.username = event.user.name
      todrecord.display_name = event.user.display_name
      todrecord.tod = tod.to_f
      todrecord.created_at = Time.now
      todrecord.save

      update_timers_channel
      event.user.pm "Time of death for **#{timer.name}** recorded as #{tod.in_time_zone(ENV["TZ"]).strftime("%A, %B %d at %I:%M:%S %p %Z")}!"
      event.message.create_reaction("✅")
    end
  else
    event.user.pm "No timer registered for **#{mob}**."
    event.message.create_reaction("⚠️")
  end
end

BOT.command(:tod) do |event, *args|
  command_tod(event, *args)
end

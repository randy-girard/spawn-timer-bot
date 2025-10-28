def command_tod(event, *args)
  return if event.channel.id != COMMAND_CHANNEL_ID

  if args.size == 0
    event << "```"
    event << "!tod [mob name] (|time of death or minutes ago(#skip count)) "
    event << ""
    event << "Examples:"
    event << ""
    event << "!tod Faydedar"
    event << "!tod Faydedar -20"
    event << "!tod Faydedar|10 hours ago"
    event << "!tod Faydedar|30 hours ago#2"
    event << "!tod Faydedar 10 hours ago"
    event << "!tod Faydedar, 10 hours ago"
    event << "!tod Faydedar|last thursday at 9pm"
    event << "!tod Faydedar 2021-04-30 12:00:00pm"
    event << "!tod Faydedar, 2021-04-30 12:00:00pm"
    event << "!tod Faydedar Fri Jul 26 10:13:01 2024"
    event << "!tod Faydedar|Fri Jul 26 10:13:01 2024"
    event << "```"
    return
  end

  mob, manual_tod = ArgumentParser.parse(args.join(" "))
  manual_tod, skip_count = manual_tod.to_s.split("#")

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
    multiple_result_response(event, timers)
  elsif found_timer || timers.size == 1
    timer = found_timer || timers[0]

    if skip_count.to_i > 0
      timer.skip_count = skip_count.to_i
      timer.save
    else
      timer.skip_count = 0
    end

    last_spawn = last_spawn_time_start(mob, last_tod: tod)

    next_spawn_start_with_tod = next_spawn_time_start(mob, last_tod: tod)
    next_spawn_end_with_tod = next_spawn_time_end(mob, last_tod: tod)

    if timer.has_window? && next_spawn_start_with_tod && next_spawn_end_with_tod && (Time.now < last_spawn || next_spawn_end_with_tod < Time.now)
      event.user.pm "Current time is outside of potential window and would have expired by now. Please try again."
      event.message.create_reaction("⚠️")
    elsif !timer.has_window? && next_spawn_start_with_tod && manual_tod && tod < next_spawn_start_with_tod
      event.user.pm "Time of death is older than potential spawn timer. Please try again."
      event.message.create_reaction("⚠️")
    elsif tod > Time.now
      event.user.pm "Time of death unable to be recorded due to time in the future."
      event.message.create_reaction("⚠️")
    else
      timer.last_tod = tod.to_f
      timer.alerted = nil
      timer.alerting_soon = false
      timer.save

      todrecord = Tod.new
      todrecord.timer_id = timer.id
      todrecord.user_id = event.user.id
      todrecord.username = event.user.name
      todrecord.display_name = event.user.display_name
      todrecord.tod = tod.to_f
      todrecord.created_at = Time.now
      todrecord.save

      tod_timers = [timer]
      linked_timers = Timer.where(linked_timer_id: timer.id).all
      linked_timers.each do |linked_timer|
        tod_timers << linked_timer

        linked_timer.last_tod = tod.to_f
        linked_timer.alerted = nil
        linked_timer.alerting_soon = false
        linked_timer.save

        linkedtodrecord = Tod.new
        linkedtodrecord.timer_id = linked_timer.id
        linkedtodrecord.user_id = event.user.id
        linkedtodrecord.username = event.user.name
        linkedtodrecord.display_name = event.user.display_name
        linkedtodrecord.tod = tod.to_f
        linkedtodrecord.created_at = Time.now
        linkedtodrecord.save
      end

      clear_timers = Timer.where(clear_parent_timer_id: timer.id).all
      clear_timers.each do |clear_timer|
        clear_timer.last_tod = nil
        clear_timer.alerted = nil
        clear_timer.alerting_soon = false
        clear_timer.save
      end

      update_timers_channel

      if SEND_DM_UPDATES
        event.user.pm "Time of death for **#{tod_timers.map(&:name).join(", ")}** recorded as #{tod.in_time_zone(ENV["TZ"]).strftime("%A, %B %d at %I:%M:%S %p %Z")}!"
      end
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

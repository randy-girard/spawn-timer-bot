def command_skip(event, *args)
  return if event.channel.id != COMMAND_CHANNEL_ID

  if args.size == 0
    event << "```"
    event << "!skip [mob name]"
    event << ""
    event << "Examples:"
    event << ""
    event << "!skip Lodizal"
    event << "```"
    return
  end

  mob = args.join(" ")
  mob.strip!
  mob.gsub!("`", "'")

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    multiple_result_response(event, timers)
  elsif found_timer || timers.size == 1
    timer = found_timer || timers[0]

    if timer.last_tod.to_s.length > 0
      ends_at = next_spawn_time_end(timer.name, last_tod: timer.last_tod, timer: timer)

      if Time.now >= ends_at
        timer.skip_count ||= 0
        timer.skip_count += 1
        timer.save
        update_timers_channel
        event.user.pm "Skip recorded for **#{timer.name}**! Updating window."
        event.message.create_reaction("✅")
      else
        event.user.pm "Timer **#{timer.name}** has not expired yet. Unable to skip."
        event.message.create_reaction("⚠️")
      end
    else
      event.user.pm "Timer **#{timer.name}** has no TOD recorded to skip!"
      event.message.create_reaction("⚠️")
    end
  else
    event.user.pm "No timer registered for **#{mob}**."
    event.message.create_reaction("⚠️")
  end
end

BOT.command(:skip) do |event, *args|
  command_skip(event, *args)
end

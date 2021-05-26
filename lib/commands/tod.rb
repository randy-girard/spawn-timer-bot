TIMEZONES = {
  "PST" => "Pacific Time (US & Canada)",
  "MST" => "Mountain Time (US & Canada)",
  "CST" => "Central Time (US & Canada)",
  "EST" => "Eastern Time (US & Canada)",

  "PDT" => "Pacific Time (US & Canada)",
  "MDT" => "Mountain Time (US & Canada)",
  "CDT" => "Central Time (US & Canada)",
  "EDT" => "Eastern Time (US & Canada)",
}

BOT.command(:tod) do |event, *args|
  return if event.channel.id != COMMAND_CHANNEL_ID

  if args.size == 0
    event << "```"
    event << "!tod [mob name] (|time of death) "
    event << ""
    event << "Examples:"
    event << ""
    event << "!tod Faydedar"
    event << "!tod Faydedar|10 hours ago"
    event << "!tod Faydedar|last thursday at 9pm"
    event << "!tod Faydedar|2021-04-30 12:00:00pm"
    event << "```"
    return
  end

  mob, manual_tod = args.join(" ").split(/[\|\,]/)
  mob.strip!
  manual_tod.strip! if manual_tod

  tod = if manual_tod.to_s.length > 0
          time = nil
          selected_timezone = nil
          begin
            has_timezone = false
            manual_tod.upcase!
            TIMEZONES.each do |key , value|
              if manual_tod.match?(key)
                selected_timezone = value
                manual_tod.gsub!(/#{key}/, value)
                has_timezone = true
              end
            end

            if has_timezone == false
              time = Chronic.parse(manual_tod, :context => :past)
            end
          rescue => ex
            puts "Chronic parse error: [#{manual_tod}]: #{ex.message}"
          end

          if time
            parsed_time = time
          elsif selected_timezone
            parsed_time = Time.find_zone!(selected_timezone).parse(manual_tod)
          else
            parsed_time = Time.parse(manual_tod)
          end

          if parsed_time && has_timezone
            parsed_time = parsed_time - 1.hour if parsed_time.dst?
          end

          parsed_time
        else
          Time.now
        end

  if tod.to_s.length == 0
    event.respond "Unable to record that time of death. Please try again."
    return
  end

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    event.respond "Request returned multiple results: #{timers.map {|timer| "`#{timer.name}`" }.join(", ")}. Please be more specific."
  elsif found_timer || timers.size == 1
    timer = found_timer || timers[0]

    last_spawn = last_spawn_time_start(mob)

    if last_spawn && manual_tod && tod < last_spawn
      event.respond "Time of death is older than potential spawn timer. Please try again."
    else
      timer.last_tod = tod.to_f
      timer.alerted = nil
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
      event.respond "Time of death for **#{timer.name}** recorded as #{tod.in_time_zone(ENV["TZ"]).strftime("%A, %B %d at %I:%M:%S %p %Z")}!"
    end
  else
    event.respond "No timer registered for **#{mob}**."
  end
end

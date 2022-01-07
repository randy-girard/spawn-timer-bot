BOT.command(:todhistory) do |event, *args|
  return if event.channel.id != COMMAND_CHANNEL_ID

  if args.size == 0
    event << "```"
    event << "!todhistory [mob name]"
    event << ""
    event << "Examples:"
    event << ""
    event << "!todhistory Faydedar"
    event << "```"
    return
  end

  mob = args.join(" ")
  mob.strip!
  mob.gsub!("`", "'")

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    event.user.pm "Request returned multiple results: #{timers.map {|timer| "`#{timer.name}`" }.join(", ")}. Please be more specific."
    event.message.create_reaction("⚠️")
  elsif found_timer || timers.size == 1
    output = []
    timer = found_timer || timers[0]
    tods = Tod.where(timer_id: timer.id).order(Sequel.lit("tod DESC")).limit(10)

    output << "```"
    output << "Last 10 TODs for #{timer.name}:"
    output << ""
    tods.sort_by {|t| t.tod }.reverse.each do |tod|
      tod = Time.at(tod.tod)

      output << tod.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z")
    end
    output << "```"

    event.respond(output.join("\n"))
  else
    event.user.pm "No timer registered for **#{mob}**."
    event.message.create_reaction("⚠️")
  end
end

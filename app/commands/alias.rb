BOT.command(:alias) do |event, *args|
  if event.channel.id != COMMAND_CHANNEL_ID
    return
  end

  output = []

  if args.size == 0
    output << "```"
    output << "Adds an alias to an existing timer, or removes an alias if it already exists."
    output << ""
    output << "!alias [timer]|[alias]"
    output << ""
    output << "Examples:"
    output << ""
    output << "!alias Vessel Drozlin|VD"
    output << "!alias Derakor The Vindicator|Vindi"
    output << "```"
    event.respond(output.join("\n"))
    return
  end

  mob, alias_value = args.join(" ").split("|")
  mob.strip!
  mob.gsub!("`", "'")

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    multiple_result_response(event, timers)
  elsif found_timer || timers.size == 1
    timer = found_timer || timers.first
    alias_record = Alias.where(timer_id: timer.id, name: alias_value).first

    if alias_record
      Alias.where(id: alias_record.id).delete
      event.user.pm "Alias of **#{alias_value}** removed from timer **#{timer.name}**!"
      event.message.create_reaction("✅")
    else
      Alias.create(
        timer_id: timer.id,
        name: alias_value,
        created_at: Time.now
      )
      event.user.pm "Alias of **#{alias_value}** added to timer **#{timer.name}**!"
      event.message.create_reaction("✅")
    end
  else
    event.respond "No timer registered for **#{mob}**."
  end
end

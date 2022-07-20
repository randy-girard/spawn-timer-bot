BOT.command(:register_clear) do |event, *args|
  if event.channel.id != COMMAND_CHANNEL_ID
    return
  end

  output = []

  if args.size == 0
    output << "```"
    output << "Register/unregister a timer to be cleared when another timer's tod is registered."
    output << ""
    output << "!register_clear [timer_to_clear]|[timer_that_triggers_clear]"
    output << ""
    output << "Examples:"
    output << ""
    output << "!register_clear Terror|Cazic"
    output << "!register_clear Ragefire - Naggy|Ragefire"
    output << "```"
    event.respond(output.join("\n"))
    return
  end

  mob, parent_mob = args.join(" ").split(/[\|\,]/)
  mob.strip!
  mob.gsub!("`", "'")

  parent_mob.strip!
  parent_mob.gsub!("`", "'")

  timers, found_timer = find_timer_by_mob(mob)
  parent_timers, parent_timer = find_timer_by_mob(parent_mob)

  if found_timer && parent_timer
    if found_timer.clear_parent_timer_id == nil
      found_timer.clear_parent_timer_id = parent_timer.id
      found_timer.save
      event.user.pm "**#{found_timer.name}** will be cleared on tod of **#{parent_timer.name}**."
    else
      found_timer.clear_parent_timer_id = nil
      found_timer.save
      event.user.pm "**#{found_timer.name}** will no longer be cleared on tod of **#{parent_timer.name}**."
    end
    event.message.create_reaction("✅")
  else
    event.user.pm "**#{found_timer}** or **#{parent_timer}** is not a registered timer."
    event.message.create_reaction("⚠️")
  end
end

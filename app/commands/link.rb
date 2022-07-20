BOT.command(:register_link) do |event, *args|
  return if event.channel.id != COMMAND_CHANNEL_ID

  if args.size == 0
    event << "```"
    event << "Register/unregister a timer to automatically set TOD when another timer TOD is set."
    event << ""
    event << "!register_link [timer name]|[timer to link to]"
    event << ""
    event << "Examples:"
    event << ""
    event << "!register_link Ragefire | Nagafen"
    event << "```"
    return
  end

  linked_mob, mob = args.join(" ").split(/[\|\,]/)
  mob.strip!
  mob.gsub!("`", "'")

  linked_mob.strip!
  linked_mob.gsub!("`", "'")

  timers, found_timer = find_timer_by_mob(mob)
  linked_timers, found_linked_timer = find_timer_by_mob(linked_mob)

  if found_timer && found_linked_timer
    if found_linked_timer.linked_timer_id == nil
      found_linked_timer.linked_timer_id = found_timer.id
      found_linked_timer.save
      event.user.pm "**#{found_linked_timer.name}** has been linked to **#{found_timer.name}**."
    else
      found_linked_timer.linked_timer_id = nil
      found_linked_timer.save
      event.user.pm "**#{found_linked_timer.name}** has been unlinked from **#{found_timer.name}**."
    end
    update_timers_channel
    event.message.create_reaction("✅")
  else
    event.user.pm "**#{found_timer}** or **#{linked_mob}** is not a registered timer."
    event.message.create_reaction("⚠️")
  end
end

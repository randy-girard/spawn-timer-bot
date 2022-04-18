BOT.command(:link) do |event, *args|
  return if event.channel.id != COMMAND_CHANNEL_ID

  if args.size == 0
    event << "```"
    event << "!link [timer name]|[timer to link to]"
    event << ""
    event << "Examples:"
    event << ""
    event << "!link Ragefire | Nagafen"
    event << "```"
    return
  end

  linked_mob, mob = args.join(" ").split(/[\|\,]/)
  mob.strip!
  mob.gsub!("`", "'")

  linked_mob.strip!
  linked_mob.gsub!("`", "'")

  timer = Timer.where(Sequel.ilike(:name, mob.to_s)).first
  linked_timer = Timer.where(Sequel.ilike(:name, linked_mob.to_s)).first
  if timer && linked_timer
    linked_timer.linked_timer_id = timer.id
    linked_timer.save
    update_timers_channel
    event.user.pm "**#{linked_mob}** has been linked to **#{mob}**."
    event.message.create_reaction("✅")
  else
    event.user.pm "**#{timer}** or **#{linked_mob}** is not a registered timer."
    event.message.create_reaction("⚠️")
  end
end

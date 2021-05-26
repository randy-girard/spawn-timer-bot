BOT.command(:rename) do |event, *args|
  return if event.channel.id != COMMAND_CHANNEL_ID

  if args.size == 0
    event << "```"
    event << "!rename [mob name]|[new mob name]"
    event << ""
    event << "Examples:"
    event << ""
    event << "!rename Faydedar|Master Faydedar"
    event << "```"
    return
  end

  mob, new_mob = args.join(" ").split(/[\|\,]/)
  mob.strip!
  new_mob.strip!

  timer = Timer.where(Sequel.ilike(:name, mob.to_s)).first
  if timer
    timer.name = new_mob.to_s
    timer.save
    update_timers_channel
    event.respond "Timer for **#{mob}** has been renamed to **#{new_mob}**."
  else
    event.respond "No timer registered for **#{mob}**."
  end
end

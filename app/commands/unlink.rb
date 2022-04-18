BOT.command(:unlink) do |event, *args|
  return if event.channel.id != COMMAND_CHANNEL_ID

  if args.size == 0
    event << "```"
    event << "!unlink [timer to remove link on]"
    event << ""
    event << "Examples:"
    event << ""
    event << "!unlink Ragefire"
    event << "```"
    return
  end

  mob = args.join(" ")
  mob.strip!
  mob.gsub!("`", "'")

  timer = Timer.where(Sequel.ilike(:name, mob.to_s)).first

  if timer
    linked_timer = Timer.where(id: timer.linked_timer_id).first
    if linked_timer
      timer.linked_timer_id = nil
      timer.save
      update_timers_channel
      event.user.pm "Link for **#{mob}** to ** #{linked_timer.name}** has been removed."
      event.message.create_reaction("✅")
    else
      event.user.pm "**#{timer.name}** does not have a linked timer."
      event.message.create_reaction("⚠️")
    end
  else
    event.user.pm "**#{timer}** is not a registered timer."
    event.message.create_reaction("⚠️")
  end
end

BOT.command(:earthquake) do |event|
  command_quake(event)
end

BOT.command(:quake) do |event|
  command_quake(event)
end

def command_quake(event)
  return if event.channel.id != COMMAND_CHANNEL_ID

  Timer.all.each do |timer|
    timer.last_tod = nil
    timer.alerted = false
    timer.alerting_soon = false
    timer.skip_count = 0
    timer.save
  end
  update_timers_channel
  event.respond "Quake has been registered!"
  BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**QUAKE**")
  if defined? (EARTHQUAKE_ALERT_CHANNEL_ID) && EARTHQUAKE_ALERT_CHANNEL_ID.to_s.strip.length > 0
    # earthquake alert channel is defined, so send the EARTHQUAKE_ALERT_MESSAGE if defined, otherwise send the default alert message
    BOT.send_message(EARTHQUAKE_ALERT_CHANNEL_ID, EARTHQUAKE_ALERT_MESSAGE.empty? ? "QUAKE" : EARTHQUAKE_ALERT_MESSAGE)
  end
end

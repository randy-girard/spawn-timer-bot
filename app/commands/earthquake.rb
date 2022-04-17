BOT.command(:earthquake) do |event|
  return if event.channel.id != COMMAND_CHANNEL_ID

  Timer.all.each do |timer|
    timer.last_tod = nil
    timer.alerted = false
    timer.alerting_soon = false
    timer.skip_count = 0
    timer.save
  end
  update_timers_channel
  event.respond "Earthquake has been registered!"
  BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**EARTHQUAKE**")
  if defined? EARTHQUAKE_ALERT_CHANNEL_ID
    BOT.send_message(EARTHQUAKE_ALERT_CHANNEL_ID, "@raiders **EARTHQUAKE** **EARTHQUAKE** **EARTHQUAKE**")
  end
end

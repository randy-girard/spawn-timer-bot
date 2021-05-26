BOT.command(:help) do |event|
  return if event.channel.id != COMMAND_CHANNEL_ID

  event << "Spawn Timer Bot Help Menu"
  event << ""
  event << "To see how to use a specific command, run the command without any options."
  event << ""
  event << "List of available commands:"
  event << "```"
  event << "!register    - Register a new timer that you want to start tracking."
  event << "!unregister  - Removes a previously registered timer."
  event << "!show        - Displays configuration about a timer."
  event << "!rename      - Renames an existing timer."
  event << "!tod         - Record a time of death for a registered timer."
  event << "!todremove   - Remove a time of death for a registered timer."
  event << "!timers      - See the list of timers that have been registered."
  event << "!earthquake  - Resets the TOD for all timers. Warning!!! Know what you are doing."
  event << "!leaderboard - Displays leaderboard of TOD by user"
  event << "```"
end

BOT.command(:help) do |event|
  if event.channel.id != COMMAND_CHANNEL_ID
    return
  end

  output = []

  output << "Spawn Timer Bot Help Menu"
  output << ""
  output << "To see how to use a specific command, run the command without any options."
  output << ""
  output << "List of available commands:"
  output << "```"
  output << "!register    - Register a new timer that you want to start tracking."
  output << "!unregister  - Removes a previously registered timer."
  output << "!show        - Displays configuration about a timer."
  output << "!rename      - Renames an existing timer."
  output << "!tod         - Record a time of death for a registered timer."
  output << "!todremove   - Remove a time of death for a registered timer."
  #output << "!link        - Links timer to another timer to auto TOD on the other timers TOD."
  #output << "!unlink      - Removes the timer that this timer is linked to."
  output << "!todhistory  - Show last 10 TODs recorded for a registered timer."
  output << "!skip        - Record a skipped spawn for a registered timer."
  output << "!unskip      - Removes the last skip for a registered timer."
  output << "!timers      - See the list of timers that have been registered."
  output << "!earthquake  - Resets the TOD for all timers. Warning!!! Know what you are doing."
  output << "!leaderboard - Displays leaderboard of TOD by user"
  output << "```"

  event.respond(output.join("\n"))
end

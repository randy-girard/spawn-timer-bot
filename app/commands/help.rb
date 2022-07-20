BOT.command(:help) do |event|
  if !(event.channel.id == COMMAND_CHANNEL_ID || event.channel.type == 1)
    return
  end

  output = []

  output << "Spawn Timer Bot Help Menu"
  output << ""
  output << "To see how to use a specific command, run the command without any options."
  output << ""
  output << "List of available commands:"
  output << "```"
  output << "!register       - Register a new timer that you want to start tracking."
  output << "!unregister     - Removes a previously registered timer."
  output << "!alias          - Adds or removes an alias on a timer."
  output << "!show           - Displays configuration about a timer."
  output << "!rename         - Renames an existing timer."
  output << "!tod            - Record a time of death for a registered timer."
  output << "!todremove      - Remove a time of death for a registered timer."
  output << "!register_link  - Register/unregister a timer to automatically set TOD when another timer TOD is set."
  output << "!register_clear - Register/unregister a timer to be cleared when another timer's tod is registered."
  output << "!todhistory     - Show last 10 TODs recorded for a registered timer."
  output << "!autotod        - Enables/Disables automatic tod when a timer expires. Only works on timers with no window."
  output << "!skip           - Record a skipped spawn for a registered timer."
  output << "!unskip         - Removes the last skip for a registered timer."
  output << "!timers         - See the list of timers that have been registered."
  output << "!schedule       - Outputs a human readable schedule for the 7 days."
  output << "!leaderboard    - Displays leaderboard of TOD by user"
  output << "!quake          - Resets the TOD for all timers. Warning!!! Know what you are doing. This will also post an QUAKE message"
  output << "                  to an quake alert channel, if defined"
  output << "```"

  event.respond(output.join("\n"))
end

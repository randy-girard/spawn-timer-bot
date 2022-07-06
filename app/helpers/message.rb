require_relative "message_one"
require_relative "message_two"

def build_show_message(timer)
  event = []
  event << "```"
  event << "Configuration for #{timer.name}."
  event << ""
  event << "Start: #{timer.window_start}"
  event << "End: #{timer.window_end}"
  event << "Variance: #{timer.variance}"
  event << "Skip Count: #{timer.skip_count}"
  if timer.last_tod
    event << "Last TOD: #{Time.at(timer.last_tod)} (#{display_time_ago(Time.at(timer.last_tod))})"
    event << "In Window: #{in_window(timer.name)}"
    event << "Next Spawn Start: #{next_spawn_time_start(timer.name)} (#{display_time_distance(next_spawn_time_start(timer.name))})"
    event << "Next Spawn End: #{next_spawn_time_end(timer.name)} (#{display_time_distance(next_spawn_time_end(timer.name))})"
  else
    event << "Last TOD: NEED TOD"
  end
  event << "Alerted: #{timer.alerted}"
  event << "Alerting Soon: #{timer.alerting_soon}"
  event << "Autotod: #{timer.auto_tod ? "Enabled" : "Disabled"}"

  aliases = Alias.where(timer_id: timer.id).all
  if aliases.size > 0
    event << "Aliases: #{aliases.map(&:name).join(", ")}"
  end

  event << "```"
  event.join("\n")
end

def multiple_result_response(event, timers)
  timers_message = []
  timers.each do |timer|
    timers_message << "`timer.name`"
  end

  out_message = ["Request returned multiple results, please be more specific:"]
  out_message << ""
  timers.each do |timer|
    out_message << "`#{timer.name}`"
  end

  event.user.pm(out_message.join("\n"))
  event.message.create_reaction("⚠️")
end

require_relative "message_one"
require_relative "message_two"

def show_message(event, timer)
  event << "```"
  event << "Configuration for #{timer.name}."
  event << ""
  event << "Start: #{timer.window_start}"
  event << "End: #{timer.window_end}"
  event << "Variance: #{timer.variance}"
  if timer.last_tod
    event << "Last TOD: #{Time.at(timer.last_tod)} (#{display_time_ago(Time.at(timer.last_tod))})"
    event << "In Window: #{in_window(timer.name)}"
    event << "Next Spawn Start: #{next_spawn_time_start(timer.name)} (#{display_time_distance(next_spawn_time_start(timer.name))})"
    event << "Next Spawn End: #{next_spawn_time_end(timer.name)} (#{display_time_distance(next_spawn_time_end(timer.name))})"
  else
    event << "Last TOD: NEED TOD"
  end
  event << "Alerted: #{timer.alerted}"
  event << "```"
end

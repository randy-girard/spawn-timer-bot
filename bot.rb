ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)
require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

Bundler.require

require 'date'

ENV['TZ'] ||= 'EDT'
ENV["RACK_ENV"] ||= "development"

Dotenv.load(".env.local", ".env.#{ENV["RACK_ENV"]}", ".env")

include DOTIW::Methods

DATABASE_URL = ENV["DATABASE_URL"]

TOKEN = ENV["TOKEN"]
CLIENT_ID = ENV["CLIENT_ID"]

COMMAND_CHANNEL = ENV["COMMAND_CHANNEL"]
TIMER_CHANNEL_ID = ENV["TIMER_CHANNEL_ID"]
TIMER_ALERT_CHANNEL_ID = ENV["TIMER_ALERT_CHANNEL_ID"]
TIMER_CHANNEL_REFRESH_RATE = (ENV["TIMER_CHANNEL_REFRESH_RATE"] || 10).to_i
TIMER_ALERT_CHANNEL_REFRESH_RATE = (ENV["TIMER_ALERT_CHANNEL_REFRESH_RATE"] || 1).to_i
UPDATE_TIMERS_CHANNEL = true
UPDATE_TIMERS_ALERT_CHANNEL = true

@last_timer_channel_update = nil
@last_timer_channel_alert_update = nil

DB = Sequel.connect(DATABASE_URL)

Sequel.extension :migration
Sequel::Migrator.run(DB, 'db/migrate', :use_transactions=>true)

class Timer < Sequel::Model
end

@timer_updates = {
  :timer => { last: nil, refresh: TIMER_CHANNEL_REFRESH_RATE },
  :timer_alert => { last: nil, refresh: TIMER_ALERT_CHANNEL_REFRESH_RATE }
}

BOT = Discordrb::Commands::CommandBot.new token: TOKEN,
                                          client_id: CLIENT_ID,
                                          prefix: '!'
puts "Starting up"
sleep 2


def in_window(mob)
  timer = Timer.where(Sequel.ilike(:name, mob.to_s)).first
  next_spawn = next_spawn_time_start(mob)

  if next_spawn
    Time.now > next_spawn
  else
    false
  end
end


def next_spawn_time_start(mob, last_tod = nil)
  timer = Timer.where(Sequel.ilike(:name, mob.to_s)).first

  if last_tod || timer.last_tod
    tod = Time.at(last_tod || timer.last_tod)

    if timer.variance
      tod + ChronicDuration.parse(timer.window_start) - ChronicDuration.parse(timer.variance)
    else
      tod + ChronicDuration.parse(timer.window_start)
    end
  else
    false
  end
end


def last_spawn_time_start(mob)
  timer = Timer.where(Sequel.ilike(:name, mob.to_s)).first

  if timer.variance
    Time.now - ChronicDuration.parse(timer.window_start) - ChronicDuration.parse(timer.variance)
  else
    Time.now - ChronicDuration.parse(timer.window_start)
  end
end


def next_spawn_time_end(mob)
  timer = Timer.where(Sequel.ilike(:name, mob.to_s)).first

  if timer.last_tod
    tod = Time.at(timer.last_tod)

    if timer.window_end && timer.variance
      tod + ChronicDuration.parse(timer.window_end) + ChronicDuration.parse(timer.variance)
    elsif timer.window_end
      tod + ChronicDuration.parse(timer.window_end)
    elsif timer.variance
      tod + ChronicDuration.parse(timer.window_start) + ChronicDuration.parse(timer.variance)
    else
      tod + ChronicDuration.parse(timer.window_start)
    end
  else
    false
  end
end


def past_possible_spawn_time(mob)
  next_spawn = next_spawn_time_end(mob)

  if next_spawn
    Time.now > next_spawn + (10 * 60)
  else
    false
  end
end

def find_timer_by_mob(mob)
  timers = Timer.where(Sequel.ilike(:name, "#{mob.to_s}%")).all
  found_timer = timers.find {|timer| timer.name.to_s.downcase == mob.to_s.downcase }

  return timers, found_timer
end

def display_time_ago(time)
  time_ago_in_words(
    time
  ) + " ago"
end

def display_time_distance(time)
  distance_of_time_in_words(
    Time.now,
    time
  )
end


def build_timer_message
  any_in_window = false
  any_need_tod = false
  any_mobs = false
  message = []

  upcoming_message = []
  in_window_message = []
  need_tod_message = []

  Timer.all.sort_by {|timer| next_spawn_time_start(timer.name) || Chronic.parse("100 years from now") }.reverse.each do |timer|
    window_start = ""
    starts_at = ""
    ends_at = ""
    window_end = ""
    last_tod = ""

    if timer.last_tod
      tod = Time.at(timer.last_tod)
      last_tod = display_time_ago(tod)
      starts_at = next_spawn_time_start(timer.name)
      ends_at = next_spawn_time_end(timer.name)
      window_start = display_time_distance(starts_at)

      if timer.window_end || timer.variance
        window_end = display_time_distance(ends_at)
      end
    else
      last_tod = false
    end

    begin
      if !last_tod
        any_need_tod = true
        need_tod_message << timer.name
      elsif in_window(timer.name)
        any_in_window = true
        in_window_message << "**#{timer.name}**"
        in_window_message << "• Started #{window_start} ago"
        if ends_at < Time.now
          in_window_message << "• Ended #{window_end} ago"
        else
          in_window_message << "• Ends In  #{window_end}"
        end
        in_window_message << ""
      else
        any_mobs = true
        upcoming_message << "**#{timer.name}**"
        if window_end.to_s.length == 0
          if Time.now >= starts_at - (4 * 60 * 60)
            upcoming_message << "• Spawns in #{window_start}"
          else
            upcoming_message << "• Spawns #{starts_at.in_time_zone("EST").strftime("%A, %B %d at %I:%M:%S %p %Z")}"
          end
        else
          if Time.now >= starts_at - (4 * 60 * 60)
            upcoming_message << "• Starts in #{window_start}"
            upcoming_message << "• Ends in #{window_end}"
          else
            upcoming_message << "• Starts at #{starts_at.in_time_zone("EST").strftime("%A, %B %d at %I:%M:%S %p %Z")}"
          end
        end
        upcoming_message << ""
      end
    rescue => ex
      puts ex
      puts ex.backtrace
    end
  end

  if any_mobs
    message << "\:dragon: __**Mobs**__ \:dragon:"
    message << ""
    message << upcoming_message
  end

  if any_in_window
    message << ""
    message << "\:window: __**Mobs In Window**__ \:window:"
    message << ""
    message << in_window_message
  end

  if any_need_tod
    message << ""
    message << "\:warning: __**Mobs needing TOD**__ \:warning:"
    message << ""
    message << need_tod_message.join(", ")
  end

  message.join("\n")
end


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


def update_timers_channel
  message = build_timer_message

  if @timers_message
    @timers_message.edit(message.to_s)
  else
    @timers_message = BOT.send_message(TIMER_CHANNEL_ID, message.to_s)
  end
end


def timer_update?(timer)
  timer_update = @timer_updates[timer]

  should_alert = !timer_update[:last] ||
                   Time.now >= timer_update[:last] + timer_update[:refresh]

  if should_alert
    @timer_updates[timer][:last] = Time.now
    true
  else
    false
  end
end


BOT.command(:help) do |event|
  return if event.channel.name != "timer-commands"

  event << "Spawn Timer Bot Help Menu"
  event << ""
  event << "To see how to use a specific command, run the command without any options."
  event << ""
  event << "List of available commands:"
  event << "```"
  event << "!register   - Register a new timer that you want to start tracking."
  event << "!show       - Displays configuration about a timer."
  event << "!rename     - Renames an existing timer."
  event << "!tod        - Record a time of death for a registered timer."
  event << "!todremove  - Remove a time of death for a registered timer."
  event << "!timers     - See the list of timers that have been registered."
  event << "!earthquake - Resets the TOD for all timers. Warning!!! Know what you are doing."
  event << "!remove     - Remove a timer."
  event << "```"
end

BOT.command(:register) do |event, *args|
  return if event.channel.name != COMMAND_CHANNEL

  if args.size == 0
    event << "```"
    event << "!register [mob name]|[window start or respawn Time](,[window end])(|[variance]) "
    event << ""
    event << "Examples:"
    event << ""
    event << "!register Faydedar|1 day"
    event << "!register Vox|1 week|8hours"
    event << "!register Vessel|2days,7days"
    event << "!register Test|1 hour, 2 hours|10 minutes"
    event << "```"
  else
    mob, window, variance = args.join(" ").split("|")
    window_start, window_end = window.split(",") if window

    mob.strip!
    variance.strip! if variance
    window_start.strip! if window_start
    window_end.strip! if window_end

    special = "@!?<>',?[]}{=)(*&^%$#`~{}"
    regex = /[#{special.gsub(/./){|char| "\\#{char}"}}]/
    if mob && mob.to_s.downcase =~ regex
      event.respond "Mob name [#{mob}] has invalid characters."
      return
    end

    if window_start && window_start.count("^0-9").zero?
      event.respond "Window Start/Spawn time [#{window_start}] is an invalid format. Please use something like '8 hours' or '6 minutes'."
      return
    end

    if window_end && window_end.count("^0-9").zero?
      event.respond "Window End [#{window_end}] is an invalid format. Please use something like '8 hours' or '6 minutes'."
      return
    end

    if variance && variance.count("^0-9").zero?
      event.respond "Variance [#{variance}] is an invalid format. Please use something like '8 hours' or '6 minutes'."
      return
    end

    timer = Timer.where(Sequel.ilike(:name, mob.to_s)).first
    timer ||= Timer.new
    timer.name = mob.to_s
    timer.window_start = window_start
    timer.window_end = window_end
    timer.variance = variance
    timer.save

    update_timers_channel

    window = if window_end
               "with window between #{window_start} and #{window_end}"
             else
               "with respawn time of #{window_start}"
             end

    if variance
      window += " with variance of #{variance}"
    end

    window += " registered!"

    event.respond "Timer for **#{mob}** #{window}"

    show_message(event, timer)
  end
end


BOT.command(:show) do |event, *args|
  return if event.channel.name != COMMAND_CHANNEL

  if args.size == 0
    event << "```"
    event << "!show [mob name]"
    event << ""
    event << "Examples:"
    event << ""
    event << "!show Faydedar"
    event << "```"
    return
  end

  mob = args.join(" ")
  mob.strip!

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    event.respond "Request returned multiple results: #{timers.map {|timer| "`#{timer.name}`" }.join(", ")}. Please be more specific."
  elsif found_timer || timers.size == 1
    show_message(event, found_timer || timers[0])
  else
    event.respond "No timer registered for **#{mob}**."
  end
end


BOT.command(:todremove) do |event, *args|
  return if event.channel.name != COMMAND_CHANNEL

  if args.size == 0
    event << "```"
    event << "!todremove [mob name]"
    event << ""
    event << "Examples:"
    event << ""
    event << "!todremove Faydedar"
    event << "```"
    return
  end

  mob = args.join(" ")
  mob.strip!

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    event.respond "Request returned multiple results: #{timers.map {|timer| "`#{timer.name}`" }.join(", ")}. Please be more specific."
  elsif found_timer || timers.size == 1
    timer = found_timer || timers[0]
    timer.last_tod = nil
    timer.save
    update_timers_channel
    event.respond "Time of death removed for **#{timer.name}**!"
  else
    event.respond "No timer registered for **#{mob}**."
  end
end

BOT.command(:rename) do |event, *args|
  return if event.channel.name != COMMAND_CHANNEL

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

  mob, new_mob = args.join(" ").split("|")
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

BOT.command(:earthquake) do |event|
  Timer.all.each do |timer|
    timer.last_tod = nil
    timer.alerted = false
    timer.save
  end
  update_timers_channel
  event.respond "Earthquake has been registered!"
  BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**EARTHQUAKE**")
end

BOT.command(:tod) do |event, *args|
  return if event.channel.name != COMMAND_CHANNEL

  if args.size == 0
    event << "```"
    event << "!tod [mob name] (|time of death) "
    event << ""
    event << "Examples:"
    event << ""
    event << "!tod Faydedar"
    event << "!tod Faydedar|10 hours ago"
    event << "!tod Faydedar|last thursday at 9pm"
    event << "!tod Faydedar|2021-04-30 12:00:00pm"
    event << "```"
    return
  end

  mob, manual_tod = args.join(" ").split(/[\|\,]/)
  mob.strip!
  manual_tod.strip! if manual_tod

  tod = if manual_tod.to_s.length > 0
          begin
            Time.zone = 'Eastern Time (US & Canada)'
            Chronic.parse(manual_tod, :context => :past, :time_class => Time.zone)
          rescue => ex
            DateTime.parse(manual_tod)
          end
        else
          Time.now
        end

  if tod.to_s.length == 0
    event.respond "Unable to record that time of death. Please try again."
    return
  end

  timers, found_timer = find_timer_by_mob(mob)

  if timers.size > 1 && !found_timer
    event.respond "Request returned multiple results: #{timers.map {|timer| "`#{timer.name}`" }.join(", ")}. Please be more specific."
  elsif found_timer || timers.size == 1
    timer = found_timer || timers[0]

    last_spawn = last_spawn_time_start(mob)

    if manual_tod && tod < last_spawn
      event.respond "Time of death is older than potential spawn timer. Please try again."
    else
      timer.last_tod = tod.to_f
      timer.alerted = nil
      timer.save
      update_timers_channel
      event.respond "Time of death for **#{timer.name}** recorded as #{tod.strftime("%A, %B %d at %I:%M:%S %p %Z")}!"
    end
  else
    event.respond "No timer registered for **#{mob}**."
  end
end


BOT.command(:timers) do |event|
  return if event.channel.name != COMMAND_CHANNEL

  timers = Timer.all

  event << "```"
  event << "Currently registered timers:"
  event << ""
  event << timers.map(&:name).sort.join(", ")
  event << "```"
end

BOT.command(:remove) do |event, *args|
  return if event.channel.name != COMMAND_CHANNEL

  if args.size == 0
    event << "```"
    event << "!remove [mob name]"
    event << ""
    event << "Examples:"
    event << ""
    event << "!remove faydedar"
    event << "```"
    return
  end

  mob = args.join(" ")
  mob.strip!

  timer = Timer.where(Sequel.ilike(:name, mob.to_s)).first
  if timer
    timer.delete
    update_timers_channel
    event.respond "Timer for **#{timer.name}** removed."
  else
    event.respond "No such timer for **#{mob}** registered."
  end
end

BOT.command(:test) do |event|
  message = build_timer_message
  event.respond(message)
end

threads = []
threads << Thread.new {
  channel = BOT.channel(TIMER_CHANNEL_ID)
  @timers_message = channel.history(1).first
  update_timers_channel

  while true
    begin
      if UPDATE_TIMERS_CHANNEL && timer_update?(:timer)
        update_timers_channel
      end


      if UPDATE_TIMERS_ALERT_CHANNEL && timer_update?(:timer_alert)
        Timer.all.each do |timer|
          if in_window(timer.name) && !timer.alerted
            if timer.window_end || timer.variance
              next_spawn = next_spawn_time_end(timer.name)
              BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**#{timer.name}** is in window for #{display_time_distance(next_spawn)}!")
            else
              BOT.send_message(TIMER_ALERT_CHANNEL_ID, "**#{timer.name}** timer is up!")
            end
            timer.alerted = true

            update_timers_channel
          end

          if past_possible_spawn_time(timer.name)
            timer.alerted = nil
            timer.last_tod = nil
          end

          timer.save
        end
      end
    rescue => ex
      puts ex.message
      puts ex.backtrace
    end

    sleep 1
  end
}

threads << Thread.new {
  BOT.run
}

threads.each(&:join)

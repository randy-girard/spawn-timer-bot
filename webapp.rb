ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)
require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

Bundler.require

require 'date'
require 'active_support/time'

Dotenv.load(".env.local", ".env.#{ENV["RACK_ENV"]}", ".env")

ENV['TZ'] ||= 'Eastern Time (US & Canada)'
ENV["RACK_ENV"] ||= "development"

include DOTIW::Methods

require_relative 'config/initializers/constants'
require_all 'config/initializers'
require_all 'app/models'
require_relative 'app/helpers/time'
require_relative 'app/helpers/timer'

set :views, Proc.new { File.join(root, "app", "views") }

get "/schedule" do
  events = Timer.all.map {|timer|
    hash = {
      title: timer.name,
      start: next_spawn_time_start(timer.name)
    }
    hash[:end] = next_spawn_time_end(timer.name)

    if timer.auto_tod
      hash[:groupId] = timer.id
    end

    hash
  }
  #
  #   }[
  #   {
  #     title: 'All Day Event',
  #     start: '2020-09-01'
  #   },
  #   {
  #     title: 'Long Event',
  #     start: '2020-09-07',
  #     end: '2020-09-10'
  #   },
  #   {
  #     groupId: 999,
  #     title: 'Repeating Event',
  #     start: '2020-09-09T16:00:00'
  #   },
  #   {
  #     groupId: 999,
  #     title: 'Repeating Event',
  #     start: '2020-09-16T16:00:00'
  #   },
  #   {
  #     title: 'Conference',
  #     start: '2020-09-11',
  #     end: '2020-09-13'
  #   },
  #   {
  #     title: 'Meeting',
  #     start: '2020-09-12T10:30:00',
  #     end: '2020-09-12T12:30:00'
  #   },
  #   {
  #     title: 'Lunch',
  #     start: '2020-09-12T12:00:00'
  #   },
  #   {
  #     title: 'Meeting',
  #     start: '2020-09-12T14:30:00'
  #   },
  #   {
  #     title: 'Happy Hour',
  #     start: '2020-09-12T17:30:00'
  #   },
  #   {
  #     title: 'Dinner',
  #     start: '2020-09-12T20:00:00'
  #   },
  #   {
  #     title: 'Birthday Party',
  #     start: '2020-09-13T07:00:00'
  #   },
  #   {
  #     title: 'Click for Google',
  #     url: 'http://google.com/',
  #     start: '2020-09-28'
  #   }
  # ]
  erb :"schedule/index", { :locals => { events_json: events.to_json } }
end

get "/timers" do
  any_in_window = false
  any_need_tod = false
  any_mobs = false
  any_ended_recently = false
  message = []

  any_in_window = false
  any_need_tod = false
  any_mobs = false
  message = []

  upcoming_message = [
    [
      "Timer".ljust(60, ' '),
      "In".ljust(COLUMN_2, ' '),
      "Window".ljust(COLUMN_3, ' '),
      "At".ljust(COLUMN_4, ' '),
    ].join("")
  ]
  in_window_message = [
    [
      "Timer".ljust(60, ' '),
      "Ends In".ljust(COLUMN_2, ' '),
      "Percent".ljust(COLUMN_3, ' '),
      "Ends At".ljust(COLUMN_4, ' '),
    ].join("")
  ]

  ended_recently_message = [
    [
      "Timer".ljust(60, ' '),
      "Ended At".ljust(COLUMN_2, ' '),
      "".ljust(COLUMN_3, ' '),
      "Ended".ljust(COLUMN_4, ' '),
    ].join("")
  ]
  need_tod_message = []

  timers = Timer.all
  timers.sort_by {|timer| next_spawn_time_start(timer.name, timer: timer) || Chronic.parse("100 years from now") }.reverse.each do |timer|
    window_start = ""
    starts_at = ""
    ends_at = ""
    window_end = ""
    no_window_end = false
    last_tod = ""

    if timer.last_tod
      tod = Time.at(timer.last_tod)
      last_tod = display_time_ago(tod)
      starts_at = next_spawn_time_start(timer.name, timer: timer)
      ends_at = next_spawn_time_end(timer.name, timer: timer)
      window_start = display_time_distance(starts_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)

      if timer.window_end || timer.variance
        window_end = display_time_distance(ends_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)
      else
        no_window_end = true
        window_end = window_start
      end
    else
      last_tod = false
    end

    begin
      truncated_timer_name = timer.name.to_s.truncate(50 - 1)
      truncated_timer_name = truncated_timer_name.gsub("`", "'")

      if timer.skip_count.to_i > 0
        truncated_timer_name = truncated_timer_name + ("*" * timer.skip_count.to_i)
      end

      if !last_tod
        any_need_tod = true
        need_tod_message << timer.name
      elsif in_window(timer.name, timer: timer)
        line = ""

        if ends_at > Time.now
          percentage = "#{(((Time.now - starts_at) / (ends_at - starts_at)) * 100).round(2)}%"
        else
          percentage = "N/A"
        end
        #COLUMN_1 = 30
        #COLUMN_2 = 20
        #COLUMN_3 = 15
        #COLUMN_4 = 22
        if ends_at > Time.now
          any_in_window = true
          line += "#{truncated_timer_name}".ljust(50, ' ')
          line += "#{window_end}".ljust(COLUMN_2, ' ')
          line += percentage.to_s.ljust(COLUMN_3, ' ')
          line += ends_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z").ljust(COLUMN_4, ' ')
          in_window_message << "#{line}"
        else
          any_ended_recently = true
          line += "#{truncated_timer_name}".ljust(50, ' ')
          line += "#{window_end} ago".ljust(COLUMN_2, ' ')
          line += "".ljust(COLUMN_3, ' ')
          line += ends_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z").ljust(COLUMN_4, ' ')
          ended_recently_message << "#{line}"
        end
      else
        line = ""
        any_mobs = true
        line += "#{truncated_timer_name}".ljust(50, ' ')
        line += "#{window_start}".ljust(COLUMN_2, ' ')
        if !no_window_end && timer.display_window
          line += timer.display_window.ljust(COLUMN_3, ' ')
        else
          line += "".ljust(COLUMN_3, ' ')
        end
        line += starts_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z").ljust(COLUMN_4, ' ')
        upcoming_message << "#{line}"
      end
    rescue => ex
      puts ex
      puts ex.backtrace
    end
  end

  any_message = false
  if any_mobs
    message << "Timers"
    message << upcoming_message
    message << "\n"
    any_message = true
  end

  if any_in_window
    message << "\n"
    message << "In Window"
    message << in_window_message
    message << "\n"
    any_message = true
  end

  if any_ended_recently
    message << "\n"
    message << "Ended Recently"
    message << ended_recently_message
    message << "\n"
    any_message = true
  end

  #if any_need_tod
  #  message << ""
  #  message << "\:warning: __**Missing Timers**__"
  #  message << ""
  #  message << need_tod_message.sort.join(", ")
  #end

  if !any_message
    message << "There are no timers currently running."
  end

  message.flatten


  erb :"timers/index", { :locals => { message: message } }
end

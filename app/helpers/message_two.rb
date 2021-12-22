def build_timer_message_two(timers: nil)
  any_in_window = false
  any_need_tod = false
  any_mobs = false
  any_ended_recently = false
  message = []

  upcoming_message = [
    [
      "Timer".ljust(25, ' '),
      "In".ljust(20, ' '),
      "Window".ljust(12, ' '),
      "At"
    ].join("")
  ]
  in_window_message = [
    [
      "Timer".ljust(25, ' '),
      "Ends In".ljust(20, ' '),
      "Percent".ljust(12, ' '),
      "Ends At"
    ].join("")
  ]

  ended_recently_message = [
    [
      "Timer".ljust(25, ' '),
      "Ended At".ljust(20, ' '),
      "Ended"
    ].join("")
  ]

  need_tod_message = []

  timers ||= Timer.all
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
      truncated_timer_name = timer.name.to_s.truncate(29)

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

        if ends_at > Time.now
          any_in_window = true
          line += "#{truncated_timer_name}".ljust(25, ' ')
          line += "#{window_end}".ljust(20, ' ')
          line += percentage.to_s.ljust(12, ' ')
          line += ends_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z")
          in_window_message << line
        else
          any_ended_recently = true
          line += "#{truncated_timer_name}".ljust(25, ' ')
          line += "#{window_end} ago".ljust(20, ' ')
          line += ends_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z")
          ended_recently_message << line
        end
      else
        line = ""
        any_mobs = true
        line += "#{truncated_timer_name}".ljust(25, ' ')
        line += "#{window_start}".ljust(20, ' ')
        if !no_window_end && timer.display_window
          line += timer.display_window.ljust(12, ' ')
        else
          line += "".ljust(12, ' ')
        end
        line += starts_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z")
        upcoming_message << line
      end
    rescue => ex
      puts ex
      puts ex.backtrace
    end
  end

  # tods = Tod.group_and_count(:user_id)
  #           .all
  #           .sort_by {|tod| tod[:count] }
  #           .reverse[0..4]
  # if tods.size > 0
  #   users = Tod.order(Sequel.lit("created_at DESC"))
  #              .select_hash(:user_id, :display_name)
  #   message << "\:trophy: __**Leaderboard (Top 5)**__"
  #   message << '```'
  #   message << "Rank  #{"Name".ljust(30, ' ')}Count"
  #   tods.each_with_index do |tod, index|
  #     username = users[tod[:user_id]].to_s.truncate(29)
  #     username = clean_username(username)
  #     message << "#{(index + 1).to_s.rjust(4, ' ')}  #{username.ljust(30, ' ')}#{tod[:count]}"
  #   end
  #   message << '```'
  #   message << ""
  # end

  any_message = false
  if any_mobs
    message << "\:dragon: __**Timers**__"
    message << "```"
    message << upcoming_message
    message << "```"
    any_message = true
  end

  if any_in_window
    message << ""
    message << "\:window: __**In Window**__"
    message << "```"
    message << in_window_message
    message << "```"
    any_message = true
  end

  if any_ended_recently
    message << ""
    message << "\:clock: __**Ended Recently**__"
    message << "```"
    message << ended_recently_message
    message << "```"
    any_message = true
  end

  #if any_need_tod
  #  message << ""
  #  message << "\:warning: __**Missing Timers**__"
  #  message << ""
  #  message << need_tod_message.sort.join(", ")
  #end

  if !any_message
    message << "```"
    message << "There are no timers currently running."
    message << "```"
  end

  message.join("\n")
end

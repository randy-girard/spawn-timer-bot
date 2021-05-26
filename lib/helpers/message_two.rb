def build_timer_message_two
  any_in_window = false
  any_need_tod = false
  any_mobs = false
  any_ended_recently = false
  message = []

  upcoming_message = [
    [
      "Timer".ljust(30, ' '),
      "At".ljust(25, ' '),
      "In".ljust(20, ' '),
      "Window"
    ].join("")
  ]
  in_window_message = [
    [
      "Timer".ljust(30, ' '),
      "Ends At".ljust(25, ' '),
      "Ends In".ljust(20, ' '),
      "Percent"
    ].join("")
  ]

  ended_recently_message = [
    [
      "Timer".ljust(30, ' '),
      "Ended At".ljust(25, ' '),
      "Ended".ljust(20, ' ')
    ].join("")
  ]

  need_tod_message = []

  Timer.all.sort_by {|timer| next_spawn_time_start(timer.name) || Chronic.parse("100 years from now") }.reverse.each do |timer|
    window_start = ""
    starts_at = ""
    ends_at = ""
    window_end = ""
    no_window_end = false
    last_tod = ""

    if timer.last_tod
      tod = Time.at(timer.last_tod)
      last_tod = display_time_ago(tod)
      starts_at = next_spawn_time_start(timer.name)
      ends_at = next_spawn_time_end(timer.name)
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

      if !last_tod
        any_need_tod = true
        need_tod_message << timer.name
      elsif in_window(timer.name)
        line = ""

        if ends_at > Time.now
          percentage = "#{(((Time.now - starts_at) / (ends_at - starts_at)) * 100).round(2)}%"
        else
          percentage = "N/A"
        end

        if ends_at > Time.now
          any_in_window = true
          line += "#{truncated_timer_name}".ljust(30, ' ')
          line += ends_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z").ljust(25, ' ')
          line += "#{window_end}".ljust(20, ' ')
          line += percentage
          in_window_message << line
        else
          any_ended_recently = true
          line += "#{truncated_timer_name}".ljust(30, ' ')
          line += ends_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z").ljust(25, ' ')
          line += "#{window_end} ago".ljust(20, ' ')
          ended_recently_message << line
        end
      else
        line = ""
        any_mobs = true
        line += "#{truncated_timer_name}".ljust(30, ' ')
        line += starts_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z").ljust(25, ' ')
        line += "#{window_start}".ljust(20, ' ')
        if !no_window_end
          line += "  ✅"
        end
        upcoming_message << line
      end
    rescue => ex
      puts ex
      puts ex.backtrace
    end
  end

  tods = Tod.group_and_count(:user_id)
            .all
            .sort_by {|tod| tod[:count] }
            .reverse[0..4]
  if tods.size > 0
    users = Tod.order("created_at DESC")
               .select_hash(:user_id, :display_name)
    message << "\:trophy: __**Leaderboard (Top 5)**__"
    message << '```'
    message << "Rank  #{"Name".ljust(30, ' ')}Count"
    tods.each_with_index do |tod, index|
      str = ""
      if index == 0
        str += "🥇"
      elsif index == 1
        str += "🥈"
      elsif index == 2
        str += "🥉"
      else
        str += (index + 1).to_s
      end
      username = users[tod[:user_id]].to_s.truncate(29)
      message << "#{str.rjust(3, ' ')}  #{username.ljust(30, ' ')}#{tod[:count]}"
    end
    message << '```'
    message << ""
  end

  if any_mobs
    message << "\:dragon: __**Timers**__"
    message << "```"
    message << upcoming_message
    message << "```"
  end

  if any_in_window
    message << ""
    message << "\:window: __**In Window**__"
    message << "```"
    message << in_window_message
    message << "```"
  end

  if any_ended_recently
    message << ""
    message << "\:clock: __**Ended Recently**__"
    message << "```"
    message << ended_recently_message
    message << "```"
  end

  if any_need_tod
    message << ""
    message << "\:warning: __**Missing Timers**__"
    message << ""
    message << need_tod_message.sort.join(", ")
  end

  message.join("\n")
end

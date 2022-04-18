def build_timer_message_two(timers: nil)
  any_in_window = false
  any_need_tod = false
  any_mobs = false
  any_ended_recently = false
  message = []

  upcoming_message = [
    [
      "`",
      "Timer".ljust(COLUMN_1, ' '),
      "In".ljust(COLUMN_2, ' '),
      "Window".ljust(COLUMN_3, ' '),
      "At".ljust(COLUMN_4, ' '),
      "`"
    ].join("")
  ]
  in_window_message = [
    [
      "`",
      "Timer".ljust(COLUMN_1, ' '),
      "Ends In".ljust(COLUMN_2, ' '),
      "Percent".ljust(COLUMN_3, ' '),
      "Ends At".ljust(COLUMN_4, ' '),
      "`"
    ].join("")
  ]

  ended_recently_message = [
    [
      "`",
      "Timer".ljust(COLUMN_1, ' '),
      "Ended At".ljust(COLUMN_2, ' '),
      "".ljust(COLUMN_3, ' '),
      "Ended".ljust(COLUMN_4, ' '),
      "`"
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
      truncated_timer_name = timer.name.to_s.truncate(COLUMN_1 - 1)
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

        if ends_at > Time.now
          any_in_window = true
          line += "#{truncated_timer_name}".ljust(COLUMN_1, ' ')
          line += "#{window_end}".ljust(COLUMN_2, ' ')
          line += percentage.to_s.ljust(COLUMN_3, ' ')
          line += ends_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z").ljust(COLUMN_4, ' ')
          in_window_message << "`#{line}`"
        else
          any_ended_recently = true
          line += "#{truncated_timer_name}".ljust(COLUMN_1, ' ')
          line += "#{window_end} ago".ljust(COLUMN_2, ' ')
          line += "".ljust(COLUMN_3, ' ')
          line += ends_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z").ljust(COLUMN_4, ' ')
          ended_recently_message << "`#{line}`"
        end
      else
        line = ""
        any_mobs = true
        line += "#{truncated_timer_name}".ljust(COLUMN_1, ' ')
        line += "#{window_start}".ljust(COLUMN_2, ' ')
        if !no_window_end && timer.display_window
          line += timer.display_window.ljust(COLUMN_3, ' ')
        else
          line += "".ljust(COLUMN_3, ' ')
        end
        line += starts_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z").ljust(COLUMN_4, ' ')
        upcoming_message << "`#{line}`"
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
    message << "\:dragon: __**Timers**__ (##CURRENT_CHAR_COUNT## / ##MAX_CHAR_COUNT##)"
    message << upcoming_message
    message << "\n"
    any_message = true
  end

  if any_in_window
    message << "##SPLITPOINT##"
    message << "\:window: __**In Window**__"
    message << in_window_message
    message << "\n"
    any_message = true
  end

  if any_ended_recently
    message << "##SPLITPOINT##"
    message << "\:clock: __**Ended Recently**__"
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
    message << "` `"
    message << "`There are no timers currently running.`"
    message << "` `"
  end

  messages = message.flatten

  num_updated = 0
  char_count = 0
  current_char_count = messages.flatten.join("\n").length

  messages_count = MESSAGES_COUNT
  if current_char_count < 1800
    messages_count = 1
  end

  message_parts = messages.flatten.join("\n").split("##SPLITPOINT##")
  use_parts = message_parts.all? {|part| part.to_s.length < 2000 }

  message_groups = if use_parts
                     message_parts.map {|m| m.split("\n") }
                   else
                     messages.in_groups(messages_count)
                   end


  message_groups.each_with_index do |message_array, index|
    timer_message = @timer_messages[index]

    message = message_array.reject {|m| m == "##SPLITPOINT##" }.join("\n")

    message = "` `\n" + message

    message.gsub!("##CURRENT_CHAR_COUNT##", current_char_count.to_s)
    message.gsub!("##MAX_CHAR_COUNT##", "#{MESSAGES_COUNT * 2_000}")

    if message.to_s.length > 0
      if timer_message
        begin
          timer_message.edit(message.to_s)
        rescue => ex
          puts ex.message
          puts ex.backtrace.join("\n")
        end
      end
    else
      timer_message.edit("` `")
    end
    num_updated += 1
  end

  (num_updated..(MESSAGES_COUNT - 1)).each do |index|
    timer_message = @timer_messages[index]
    timer_message.edit("` `")
  end
end

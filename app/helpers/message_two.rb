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
      "`"
    ].join("")
  ]
  in_window_message = [
    [
      "`",
      "Timer".ljust(COLUMN_1, ' '),
      "Ends In".ljust(COLUMN_2, ' '),
      "Percent".ljust(COLUMN_3, ' '),
      "`"
    ].join("")
  ]

  ended_recently_message = [
    [
      "`",
      "Timer".ljust(COLUMN_1, ' '),
      "Ended".ljust(COLUMN_2, ' '),
      "".ljust(COLUMN_3, ' '),
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
      truncated_timer_name = timer.name_with_skips.to_s.truncate(COLUMN_1 - 1)
      truncated_timer_name = truncated_timer_name.gsub("`", "'")

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
          in_window_message << "`#{line}`"
        else
          any_ended_recently = true
          line += "#{truncated_timer_name}".ljust(COLUMN_1, ' ')
          line += "#{window_end} ago".ljust(COLUMN_2, ' ')
          line += "".ljust(COLUMN_3, ' ')
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
        upcoming_message << "`#{line}`"
      end
    rescue => ex
      puts ex
      puts ex.backtrace
    end
  end

  client = Discordrb::Webhooks::Client.new(url: TIMER_CHANNEL_WEBHOOK_URL)
  builder = Discordrb::Webhooks::Builder.new
  builder.content = ""

  any_message = false
  if any_mobs
    message << "\:dragon: __**Timers**__ (##CURRENT_CHAR_COUNT## / ##MAX_CHAR_COUNT##)"
    message << upcoming_message
    message << "\n"
    any_message = true

    builder.add_embed do |embed|
      embed.color = 3447003
      embed.title = "\:dragon: __**Timers**__"
      embed.description = upcoming_message.join("\n")
    end
  end

  if any_in_window
    message << "##SPLITPOINT##"
    message << "\:window: __**In Window**__"
    message << in_window_message
    message << "\n"
    any_message = true
    builder.add_embed do |embed|
      embed.color = 15105570
      embed.title = "\:window: __**In Window**__"
      embed.description = in_window_message.join("\n")
      embed.footer =  Discordrb::Webhooks::EmbedFooter.new(text: "Last updated today at #{Time.now.strftime("%I:%M:%S %p")}")
    end
  end

  if any_ended_recently
    message << "##SPLITPOINT##"
    message << "\:clock: __**Ended Recently**__"
    message << ended_recently_message
    message << "\n"
    any_message = true
    builder.add_embed do |embed|
      embed.color = 3066993
      embed.title = "\:clock: __**Ended Recently**__"
      embed.description = ended_recently_message.join("\n")
    end
  end

  if !any_message
    message << "` `"
    message << "`There are no timers currently running.`"
    message << "` `"
    builder.add_embed do |embed|
      embed.title = "`There are no timers currently running.`"
    end
  end

  webhook_message_id = Setting.find_by_key("webhook_message_id")
  if webhook_message_id == nil
    result = client.execute(builder, true)
    response = JSON.parse(result.body)
    webhook_message_id = response["id"]
    Setting.save_by_key("webhook_message_id", webhook_message_id)
  else
    begin
      client.edit_message(webhook_message_id, builder: builder)
    rescue => ex
      puts ex.inspect
      puts ex.backtrace.inspect
      if ex.message =~ /404 Not Found/
        result = client.execute(builder, true)
        response = JSON.parse(result.body)
        webhook_message_id = response["id"]
        Setting.save_by_key("webhook_message_id", webhook_message_id)
      end
    end
  end
end

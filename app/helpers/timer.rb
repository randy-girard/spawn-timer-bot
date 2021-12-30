MAX_MESSAGE_SIZE = 1900

def update_timers_channel(timers: nil)
  num_updated = 0
  char_count = 0

  messages = build_timer_message_two(timers: timers)

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

def find_timer_by_mob(mob, timer: nil)
  if timer
    return [timer], timer
  else
    timers = Timer.where(Sequel.ilike(:name, "%#{mob.to_s}%")).all
    found_timer = timers.find {|timer| timer.name.to_s.downcase == mob.to_s.downcase }

    return timers, found_timer
  end
end

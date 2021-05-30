def update_timers_channel
  message = build_timer_message

  if message.to_s.length > 0
    if @timers_message
      begin
        @timers_message.edit(message.to_s)
      rescue => ex
        puts ex.message
        puts ex.backtrace.join("\n")
      end
    else
      @timers_message = BOT.send_message(TIMER_CHANNEL_ID, message.to_s)
      Setting.save_by_key("timer_message_id", @timers_message.id)
    end
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

def find_timer_by_mob(mob)
  timers = Timer.where(Sequel.ilike(:name, "%#{mob.to_s}%")).all
  found_timer = timers.find {|timer| timer.name.to_s.downcase == mob.to_s.downcase }

  return timers, found_timer
end

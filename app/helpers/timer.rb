MAX_MESSAGE_SIZE = 1900

def update_timers_channel(timers: nil)
  if USE_MESSAGE_THREE
    build_timer_message_three(timers: timers)
  else
    build_timer_message_two(timers: timers)
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

    if found_timer == nil && timers.size == 1
      found_timer = timers[0]
    end

    # If we can't find a timer by the name, look by aliases
    if found_timer == nil
      aliases = Alias.where(Sequel.ilike(:name, "%#{mob.to_s}%")).all
      found_alias = aliases.find {|alias_record| alias_record.name.to_s.downcase == mob.to_s.downcase }

      if found_alias
        timers = [Timer.where(id: found_alias.timer_id).first]
        found_timer = timers[0]
      end
    end

    return timers, found_timer
  end
end

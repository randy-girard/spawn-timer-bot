def in_window(mob, timer: nil)
  timers, found_timer = find_timer_by_mob(mob, timer: timer)
  timer = found_timer || timers[0]

  if timer && !past_possible_spawn_time(mob, timer: timer)
    next_spawn = next_spawn_time_start(mob, timer: timer)

    if next_spawn
      Time.now > next_spawn
    else
      false
    end
  else
    false
  end
end

def alerting_soon(mob, timer: nil)
  timers, found_timer = find_timer_by_mob(mob, timer: timer)
  timer = found_timer || timers[0]

  if timer
    next_spawn = next_spawn_time_start(mob, timer: timer)

    if next_spawn
      warning_time = (1 * 60 * 60)

      if timer.warn_time.to_s.length > 0
        warning_time = ChronicDuration.parse(timer.warn_time)
      end

      Time.now >= next_spawn - warning_time
    else
      false
    end
  else
    false
  end
end


def next_spawn_time_start(mob, last_tod: nil, timer: nil)
  timers, found_timer = find_timer_by_mob(mob, timer: timer)
  timer = found_timer || timers[0]

  if timer && (last_tod || timer.last_tod)
    tod = Time.at(last_tod || timer.last_tod)

    variance = if timer.variance
      ChronicDuration.parse(timer.variance)
    end

    if variance
      tod + ChronicDuration.parse(timer.window_start) - variance
    elsif timer.window_start.to_i == 0
      tod
    else
      tod + ChronicDuration.parse(timer.window_start)
    end
  else
    false
  end
end


def last_spawn_time_start(mob, last_tod: nil, timer: nil)
  timers, found_timer = find_timer_by_mob(mob, timer: timer)
  timer = found_timer || timers[0]

  if timer
    tod = Time.at(last_tod || timer.last_tod)

    variance = if timer.variance
      ChronicDuration.parse(timer.variance)
    end

    if variance
      tod - ChronicDuration.parse(timer.window_start) - variance
    elsif timer.window_start.to_i == 0
      tod
    else
      tod - ChronicDuration.parse(timer.window_start)
    end
  end
end


def next_spawn_time_end(mob, last_tod: nil, timer: nil)
  timers, found_timer = find_timer_by_mob(mob, timer: timer)
  timer = found_timer || timers[0]

  if timer && (last_tod || timer.last_tod)
    tod = Time.at(last_tod || timer.last_tod)

    variance = if timer.variance
      ChronicDuration.parse(timer.variance)
    end

    if timer.window_end && variance
      tod + ChronicDuration.parse(timer.window_end) + variance
    elsif timer.window_end
      tod + ChronicDuration.parse(timer.window_end)
    elsif variance
      tod + ChronicDuration.parse(timer.window_start) + variance
    else
      tod + ChronicDuration.parse(timer.window_start)
    end
  else
    false
  end
end

def past_possible_spawn_time(mob, timer: nil)
  next_spawn = next_spawn_time_end(mob, timer: timer)

  if next_spawn
    Time.now > next_spawn + (10 * 60)
  else
    false
  end
end


def display_time_ago(time)
  time_ago_in_words(
    time
  ) + " ago"
end

def display_time_distance(time, *args)
  distance_of_time_in_words(
    Time.now,
    time,
    *args
  )
end

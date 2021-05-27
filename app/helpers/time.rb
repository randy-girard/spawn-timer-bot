def in_window(mob)
  timers, found_timer = find_timer_by_mob(mob)
  timer = found_timer || timers[0]

  if timer && !past_possible_spawn_time(mob)
    next_spawn = next_spawn_time_start(mob)

    if next_spawn
      Time.now > next_spawn
    else
      false
    end
  else
    false
  end
end

def alerting_soon(mob)
  timers, found_timer = find_timer_by_mob(mob)
  timer = found_timer || timers[0]

  if timer
    next_spawn = next_spawn_time_start(mob)

    if next_spawn
      Time.now > next_spawn - (1 * 60 * 60)
    else
      false
    end
  else
    false
  end
end


def next_spawn_time_start(mob, last_tod = nil)
  timers, found_timer = find_timer_by_mob(mob)
  timer = found_timer || timers[0]

  if timer && (last_tod || timer.last_tod)
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
  timers, found_timer = find_timer_by_mob(mob)
  timer = found_timer || timers[0]

  if timer
    if timer.variance
      Time.now - ChronicDuration.parse(timer.window_start) - ChronicDuration.parse(timer.variance)
    else
      Time.now - ChronicDuration.parse(timer.window_start)
    end
  end
end


def next_spawn_time_end(mob)
  timers, timer = find_timer_by_mob(mob)

  if timer && timer.last_tod
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

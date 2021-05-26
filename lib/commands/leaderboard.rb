BOT.command(:leaderboard) do |event, *args|
  return if event.channel.id != COMMAND_CHANNEL_ID

  timerange = args.join(" ")
  timerange.strip!

  start_at = nil
  end_at = nil

  if timerange.to_s.length > 0
    start_at, end_at = timerange.split(",")
    start_at.strip!
    end_at.strip! if end_at
  end

  if start_at.to_s.length > 0
    start_at = Chronic.parse(start_at, :context => :past)
    if start_at == nil
      event << "Unable to parse start date."
      return
    end
  end

  if end_at.to_s.length > 0
    end_at = Chronic.parse(end_at, :context => :past)
    if end_at == nil
      event << "Unable to parse end date."
      return
    end
  end

  if start_at && end_at
    event << "Showing leaderboard from #{start_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z")} to #{end_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z")}"
  elsif start_at
    event << "Showing leaderboard since #{start_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z")}"
  elsif end_at
    event << "Showing leaderboard ending #{end_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z")}"
  else
    event << "Showing All-time leaderboard"
  end

  event << ""

  num_tods = 0

  if false
    Timer.order(:name).all.each do |timer|
      tods = Tod.where(timer_id: timer.id)
                .group_and_count(:display_name)

      if start_at
        tods = tods.where(Sequel.lit("created_at >= ?", start_at))
      end

      if end_at
        tods = tods.where(Sequel.lit("created_at <= ?", end_at))
      end

      tods = tods.all.sort_by {|tod| tod[:count] }.reverse

      if tods.size > 0
        num_tods += tods.size
        event << "**#{timer.name}**"
        event << '```'
        event << "#{"Name".ljust(30, ' ')}Count"
        tods.each do |tod|
          event << "#{tod[:display_name].ljust(30, ' ')}#{tod[:count]}"
        end
        event << '```'
      end
    end
  else
    tods = Tod.group_and_count(:user_id)

    if start_at
      tods = tods.where(Sequel.lit("created_at >= ?", start_at))
    end

    if end_at
      tods = tods.where(Sequel.lit("created_at <= ?", end_at))
    end

    tods = tods.all.sort_by {|tod| tod[:count] }.reverse

    if tods.size > 0
      users = Tod.order("created_at DESC")
                 .select_hash(:user_id, :display_name)
      num_tods += tods.size
      event << '```'
      event << "Rank  #{"Name".ljust(30, ' ')}Count"
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
        event << "#{str.rjust(3, ' ')}  #{username.ljust(30, ' ')}#{tod[:count]}"
      end
      event << '```'
    end
  end

  if num_tods == 0
    event << "```"
    event << "There have been no TODs recorded during that time."
    event << "```"
  end

  ""
end

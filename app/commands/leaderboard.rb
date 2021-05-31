BOT.command(:leaderboard) do |event, *args|
  output = []

  if !(event.channel.id == COMMAND_CHANNEL_ID || event.channel.type == 1)
    return
  end

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
      output << "Unable to parse start date."
      return
    end
  end

  if end_at.to_s.length > 0
    end_at = Chronic.parse(end_at, :context => :past)
    if end_at == nil
      output << "Unable to parse end date."
      return
    end
  end

  if start_at && end_at
    output << "Showing leaderboard from #{start_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z")} to #{end_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z")}"
  elsif start_at
    output << "Showing leaderboard since #{start_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z")}"
  elsif end_at
    output << "Showing leaderboard ending #{end_at.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d %I:%M:%S %p %Z")}"
  else
    output << "Showing All-time leaderboard"
  end

  output << ""

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
        output << "**#{timer.name}**"
        output << '```'
        output << "#{"Name".ljust(30, ' ')}Count"
        tods.each do |tod|
          output << "#{tod[:display_name].ljust(30, ' ')}#{tod[:count]}"
        end
        output << '```'
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
      users = Tod.order(Sequel.lit("created_at DESC"))
                 .select_hash(:user_id, :display_name)
      num_tods += tods.size
      output << '```'
      output << "Rank  #{"Name".ljust(30, ' ')}Count"
      tods.each_with_index do |tod, index|
        username = users[tod[:user_id]].to_s.truncate(29)
        output << "#{(index + 1).to_s.rjust(4, ' ')}  #{username.ljust(30, ' ')}#{tod[:count]}"
      end
      output << '```'
    end
  end

  if num_tods == 0
    output << "```"
    output << "There have been no TODs recorded during that time."
    output << "```"
  end

  event.respond(output.join("\n"))
end

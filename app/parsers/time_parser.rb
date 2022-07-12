class TimeParser
  TIMEZONES = {
    "PST" => "Pacific Time (US & Canada)",
    "MST" => "Mountain Time (US & Canada)",
    "CST" => "Central Time (US & Canada)",
    "EST" => "Eastern Time (US & Canada)",
    "PDT" => "Pacific Time (US & Canada)",
    "MDT" => "Mountain Time (US & Canada)",
    "CDT" => "Central Time (US & Canada)",
    "EDT" => "Eastern Time (US & Canada)",
    "GMT" => "GMT",
    "UTC" => "UTC"
  }

  def self.parse(str)
    manual_tod = str.dup.upcase
    manual_tod.gsub!(".", ":")

    minutes = manual_tod.to_s.match(/^-(\d{,3})$/)
    if minutes
      manual_tod = "#{minutes[1].to_i} minutes ago"
    end

    begin
      time = nil
      selected_timezone = nil
      begin
        has_timezone = false
        TIMEZONES.each do |key , value|
          if manual_tod.to_s.match?(key.to_s.upcase)
            selected_timezone = value
            manual_tod.gsub!(/#{key}/, value)
            has_timezone = true
          end
        end

        if has_timezone == false
          time = Chronic.parse(manual_tod, :context => :past, ambiguous_time_range: :none)
        end
      rescue => ex
        puts "Chronic parse error: [#{manual_tod}]: #{ex.message}"
      end

      ampm = Chronic.parse(manual_tod, :context => :past, ambiguous_time_range: :none)
      has_ampm = manual_tod.match(/(AM|PM)/)

      if !time && ampm && !has_ampm
        ampm_str = ampm.strftime("%p")
        if selected_timezone
          manual_tod.sub!("#{selected_timezone}", "#{ampm_str} #{selected_timezone}")
        else
          manual_tod += " #{ampm_str}"
        end
      end

      if time
        parsed_time = time
      elsif selected_timezone
        parsed_time = Time.find_zone!(selected_timezone).parse(manual_tod.to_s)
      else
        parsed_time = Time.parse(manual_tod.to_s)
      end

      if parsed_time && has_timezone
        parsed_time = parsed_time - 1.hour if parsed_time.dst?
      end

      parsed_time
    rescue => ex
      puts "Time Parse Error [#{manual_tod}]: #{ex.message}"
      puts ex.backtrace.join("\n")
      nil
    end
  end
end

class TimeParser
  TIMEZONES = {
    "PST" => "Pacific Time (US & Canada)",
    "MST" => "Mountain Time (US & Canada)",
    "CST" => "Central Time (US & Canada)",
    "EST" => "Eastern Time (US & Canada)",
    "PDT" => "Pacific Time (US & Canada)",
    "MDT" => "Mountain Time (US & Canada)",
    "CDT" => "Central Time (US & Canada)",
    "EDT" => "Eastern Time (US & Canada)"
  }

  def self.parse(str)
    begin
      time = nil
      selected_timezone = nil
      begin
        has_timezone = false
        manual_tod = str.dup.upcase!
        TIMEZONES.each do |key , value|
          if manual_tod.match?(key)
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

      if time
        parsed_time = time
      elsif selected_timezone
        parsed_time = Time.find_zone!(selected_timezone).parse(manual_tod)
      else
        parsed_time = Time.parse(manual_tod)
      end

      if parsed_time && has_timezone
        parsed_time = parsed_time - 1.hour if parsed_time.dst?
      end

      parsed_time
    rescue => ex
      puts "Time Parse Error [#{manual_tod}]: #{ex.message}"
      nil
    end
  end
end

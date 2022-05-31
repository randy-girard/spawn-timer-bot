class ArgumentParser
  def self.parse(args)
    mob = ""
    manual_tod = ""

    # look for time
    arguments = args.dup.to_s

    key_words = []                                     # you can define special separator
    options = {
      date_format: :usa,                                            # year,day,month by default year,month,day
      ordinals: ['nd', 'st', 'th']                                  # a string list that might accompany a day, default none
    }
    dates_from_string = DatesFromString.new(key_words, options)     # define DatesFromString object
    dates = dates_from_string.find_date(arguments)

    mob, manual_tod = arguments.split(/[\|\,]/)
    if manual_tod == nil || dates.size > 0
      matches = arguments.to_s.downcase.match(/(.*?)\s+([0-9]|jan |feb |mar |march |apr |may |jun |jul |aug |sep |oct |nov |dec )(.*?)$/)

      if matches && matches[1] && matches[2]
        mob = matches[1]
        manual_tod = [matches[2], matches[3]].compact.join
      end
    end

    mob.strip!
    mob.gsub!("`", "'")

    manual_tod.strip! if manual_tod

    return mob, manual_tod
  end
end

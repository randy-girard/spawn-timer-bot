class ArgumentParser
  def self.parse(args)
    mob = ""
    manual_tod = ""

    # look for time
    arguments = args.dup.to_s
    mob, manual_tod = arguments.split(/[\|\,]/)
    if manual_tod == nil
      matches = arguments.to_s.downcase.match(/(.*?)\s+([0-9]|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)(.*?)$/)

      if matches && matches[1] && matches[2]
        mob = matches[1]
        manual_tod = [matches[2], matches[3]].compact.join
      end
    end

    mob.strip!
    manual_tod.strip! if manual_tod

    return mob, manual_tod
  end
end

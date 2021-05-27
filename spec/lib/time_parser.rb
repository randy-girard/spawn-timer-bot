require "spec_helper"

describe TimeParser do
  def expectation(key, value)
    t = Time.parse(TimeParser.parse(key).in_time_zone(ENV["TZ"]).to_s)
    expect(t).to eq(value)
  end

  context "morning" do
    before { Timecop.freeze(Time.local(2021, 5, 27, 1, 57, 0)) }
    after { Timecop.return }

    it "should parse time" do
      expectation("one day ago at noon", "2021-05-26 12:00:00 -0400")
      expectation("May 26 12 pm pst",    "2021-05-26 15:00:00 -0400")
      expectation("may 1st",             "2021-05-01 12:00:00 -0400")
      expectation("10:57 pst",           "2021-05-26 13:57:00 -0400")
      expectation("10:58 pm pst",        "2021-05-27 01:58:00 -0400")
      expectation("10:58 pm est",        "2021-05-27 22:58:00 -0400")
      expectation("5/3 10:58 pm est",    "2021-05-03 22:58:00 -0400")
    end
  end

  context "evening" do
    before { Timecop.freeze(Time.local(2021, 5, 27, 20, 0, 0)) }
    after { Timecop.return }

    it "should parse time" do
      expectation("one day ago at noon", "2021-05-26 12:00:00 -0400")
      expectation("May 26 12 pm pst",    "2021-05-26 15:00:00 -0400")
      expectation("may 1st",             "2021-05-01 12:00:00 -0400")
      expectation("10:57 pst",           "2021-05-27 13:57:00 -0400")
      expectation("10:58 pm pst",        "2021-05-28 01:58:00 -0400")
      expectation("10:58 pm est",        "2021-05-27 22:58:00 -0400")
      expectation("5/3 10:58 pm est",    "2021-05-03 22:58:00 -0400")
    end
  end
end

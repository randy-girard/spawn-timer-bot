require "spec_helper"

describe Timer do

  it "should calculate display window" do
    expect(
      Timer.new(window_start: "1 day", window_end: "2 days").display_window
    ).to eq("1d")

    expect(
      Timer.new(window_start: "1 day", variance: "2 hours").display_window
    ).to eq("4h")

    expect(
      Timer.new(window_start: "1 day", window_end: "2 days", variance: "1 hour").display_window
    ).to eq("1d 2h")

    expect(
      Timer.new(window_start: "1 day").display_window
    ).to eq(nil)
  end

end

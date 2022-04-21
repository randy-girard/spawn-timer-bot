require "spec_helper"

def update_timers_channel
  nil
end

describe "TodCommand" do
  before { Timecop.freeze(Time.local(2021, 5, 27, 1, 57, 0)) }
  after { Timecop.return }

  it "should record tod properly" do
    window_timer = Timer.create(name: "window", window_start: "2 days", window_end: "7 days")

    user = double("User")
    expect(user).to receive(:id) { 1 }
    expect(user).to receive(:name) { "Username" }
    expect(user).to receive(:display_name) { "Display Name" }
    expect(user).to receive(:pm).with("Time of death for **window** recorded as Thursday, May 27 at 01:57:00 AM EDT!")

    channel = double("Channel")
    expect(channel).to receive(:id) { COMMAND_CHANNEL_ID }

    message = double("Message")
    expect(message).to receive(:create_reaction).with("✅")

    event = double("Event")
    expect(event).to receive(:channel) { channel }
    allow(event).to receive(:user) { user }
    expect(event).to receive(:message) { message }

    command_tod(event, ["window"])
  end

  it "should not record dates in the future" do
    window_timer = Timer.create(name: "window", window_start: "2 days", window_end: "7 days")

    user = double("User")
    expect(user).to receive(:pm).with("Time of death unable to be recorded due to time in the future.")

    channel = double("Channel")
    expect(channel).to receive(:id) { COMMAND_CHANNEL_ID }

    message = double("Message")
    expect(message).to receive(:create_reaction).with("⚠️")

    event = double("Event")
    expect(event).to receive(:channel) { channel }
    allow(event).to receive(:user) { user }
    expect(event).to receive(:message) { message }

    command_tod(event, ["window 1:58 am"])
  end

  it "should be out of window" do
    window_timer = Timer.create(name: "window", window_start: "2 days", window_end: "7 days")

    user = double("User")
    expect(user).to receive(:pm).with("Current time is outside of potential window and would have expired by now. Please try again.")

    channel = double("Channel")
    expect(channel).to receive(:id) { COMMAND_CHANNEL_ID }

    message = double("Message")
    expect(message).to receive(:create_reaction).with("⚠️")

    event = double("Event")
    expect(event).to receive(:channel) { channel }
    allow(event).to receive(:user) { user }
    expect(event).to receive(:message) { message }

    command_tod(event, ["window 10 days ago"])
  end

  it "should be out of window with variance" do
    window_timer = Timer.create(name: "window", window_start: "2 days", variance: "1 days")

    user = double("User")
    expect(user).to receive(:pm).with("Current time is outside of potential window and would have expired by now. Please try again.")

    channel = double("Channel")
    expect(channel).to receive(:id) { COMMAND_CHANNEL_ID }

    message = double("Message")
    expect(message).to receive(:create_reaction).with("⚠️")

    event = double("Event")
    expect(event).to receive(:channel) { channel }
    allow(event).to receive(:user) { user }
    expect(event).to receive(:message) { message }

    command_tod(event, ["window 10 days ago"])
  end

  it "should be before timer" do
    window_timer = Timer.create(name: "window", window_start: "2 days")

    user = double("User")
    expect(user).to receive(:pm).with("Time of death is older than potential spawn timer. Please try again.")

    channel = double("Channel")
    expect(channel).to receive(:id) { COMMAND_CHANNEL_ID }

    message = double("Message")
    expect(message).to receive(:create_reaction).with("⚠️")

    event = double("Event")
    expect(event).to receive(:channel) { channel }
    allow(event).to receive(:user) { user }
    expect(event).to receive(:message) { message }

    command_tod(event, ["window 3 days ago"])
  end

  it "should record tod within window with manual tod" do
    window_timer = Timer.create(name: "window", window_start: "2 days", variance: "7 days")

    user = double("User")
    expect(user).to receive(:id) { 1 }
    expect(user).to receive(:name) { "Username" }
    expect(user).to receive(:display_name) { "Display Name" }
    expect(user).to receive(:pm).with("Time of death for **window** recorded as Saturday, May 22 at 01:57:00 AM EDT!")

    channel = double("Channel")
    expect(channel).to receive(:id) { COMMAND_CHANNEL_ID }

    message = double("Message")
    expect(message).to receive(:create_reaction).with("✅")

    event = double("Event")
    expect(event).to receive(:channel) { channel }
    allow(event).to receive(:user) { user }
    expect(event).to receive(:message) { message }

    command_tod(event, ["window 5 days ago"])
  end

  it "should record tod with 0 variance timer" do
    window_timer = Timer.create(name: "window", window_start: "2 days", variance: "0 hours")

    user = double("User")
    expect(user).to receive(:id) { 1 }
    expect(user).to receive(:name) { "Username" }
    expect(user).to receive(:display_name) { "Display Name" }
    expect(user).to receive(:pm).with("Time of death for **window** recorded as Wednesday, May 26 at 01:57:00 AM EDT!")

    channel = double("Channel")
    expect(channel).to receive(:id) { COMMAND_CHANNEL_ID }

    message = double("Message")
    expect(message).to receive(:create_reaction).with("✅")

    event = double("Event")
    expect(event).to receive(:channel) { channel }
    allow(event).to receive(:user) { user }
    expect(event).to receive(:message) { message }

    expect {
      command_tod(event, ["window 1 day ago"])
    }.to change {
      Tod.count
    }.by(1)
  end

  it "should record tod with skips" do
    window_timer = Timer.create(name: "window", last_tod: Time.now.to_i, window_start: "18 hours", variance: "1 hour", skip_count: 0)

    user = double("User")
    expect(user).to receive(:id) { 1 }
    expect(user).to receive(:name) { "Username" }
    expect(user).to receive(:display_name) { "Display Name" }
    expect(user).to receive(:pm).with("Time of death for **window** recorded as Wednesday, May 26 at 03:57:00 PM EDT!")

    channel = double("Channel")
    expect(channel).to receive(:id) { COMMAND_CHANNEL_ID }

    message = double("Message")
    expect(message).to receive(:create_reaction).with("✅")

    event = double("Event")
    expect(event).to receive(:channel) { channel }
    allow(event).to receive(:user) { user }
    expect(event).to receive(:message) { message }

    starts_at = next_spawn_time_start(Timer.last.name)
    ends_at = next_spawn_time_end(Timer.last.name)
    window_start = display_time_distance(starts_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)
    window_end = display_time_distance(ends_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)

    expect(window_start).to eq("17h")
    expect(window_end).to eq("19h")

    Timecop.travel(Time.local(2021, 5, 28, 15, 57, 0))

    expect {
      command_tod(event, ["window|2 days ago#2"])
    }.to change {
      Timer.last.display_window
    }.from("2h").to("6h")

    starts_at = next_spawn_time_start(Timer.last.name)
    ends_at = next_spawn_time_end(Timer.last.name)
    window_start = display_time_distance(starts_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)
    window_end = display_time_distance(ends_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)

    expect(window_start).to eq("2h 59m 59s")
    expect(window_end).to eq("8h 59m 59s")
  end

end

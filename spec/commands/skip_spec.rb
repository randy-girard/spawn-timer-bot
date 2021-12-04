require "spec_helper"

def update_timers_channel
  nil
end

describe "SkipCommand" do
  before { Timecop.freeze(Time.local(2021, 5, 27, 1, 57, 0)) }
  after { Timecop.return }

  it "should record first skip properly with variance" do
    window_timer = Timer.create(name: "window", last_tod: Time.now.to_i, window_start: "18 hours", variance: "1 hour")

    user = double("User")
    expect(user).to receive(:pm).with("Skip recorded for **window**! Updating window.")

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

    Timecop.travel(Time.local(2021, 5, 27, 20, 57, 0))

    expect {
      command_skip(event, ["window"])
    }.to change {
      Timer.last.display_window
    }.from("2h").to("4h")

    starts_at = next_spawn_time_start(Timer.last.name)
    ends_at = next_spawn_time_end(Timer.last.name)
    window_start = display_time_distance(starts_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)
    window_end = display_time_distance(ends_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)

    expect(window_start).to eq("14h 59m 59s")
    expect(window_end).to eq("18h 59m 59s")
  end

  it "should record first skip properly with window" do
    window_timer = Timer.create(name: "window", last_tod: Time.now.to_i, window_start: "17 hours", window_end: "19 hours")

    user = double("User")
    expect(user).to receive(:pm).with("Skip recorded for **window**! Updating window.")

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

    Timecop.travel(Time.local(2021, 5, 27, 20, 57, 0))

    expect {
      command_skip(event, ["window"])
    }.to change {
      Timer.last.display_window
    }.from("2h").to("4h")

    starts_at = next_spawn_time_start(Timer.last.name)
    ends_at = next_spawn_time_end(Timer.last.name)
    window_start = display_time_distance(starts_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)
    window_end = display_time_distance(ends_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)

    expect(window_start).to eq("14h 59m 59s")
    expect(window_end).to eq("18h 59m 59s")
  end

  it "should record second skip properly with variance" do
    window_timer = Timer.create(name: "window", last_tod: Time.now.to_i, window_start: "18 hours", variance: "1 hour", skip_count: 1)

    user = double("User")
    expect(user).to receive(:pm).with("Skip recorded for **window**! Updating window.")

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

    expect(window_start).to eq("1d 10h")
    expect(window_end).to eq("1d 14h")

    Timecop.travel(Time.local(2021, 5, 28, 15, 57, 0))

    expect {
      command_skip(event, ["window"])
    }.to change {
      Timer.last.display_window
    }.from("4h").to("6h")

    starts_at = next_spawn_time_start(Timer.last.name)
    ends_at = next_spawn_time_end(Timer.last.name)
    window_start = display_time_distance(starts_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)
    window_end = display_time_distance(ends_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)

    expect(window_start).to eq("12h 59m 59s")
    expect(window_end).to eq("18h 59m 59s")
  end

  it "should record second skip properly with window" do
    window_timer = Timer.create(name: "window", last_tod: Time.now.to_i, window_start: "17 hours", window_end: "19 hour", skip_count: 1)

    user = double("User")
    expect(user).to receive(:pm).with("Skip recorded for **window**! Updating window.")

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

    expect(window_start).to eq("1d 10h")
    expect(window_end).to eq("1d 14h")

    Timecop.travel(Time.local(2021, 5, 28, 15, 57, 0))

    expect {
      command_skip(event, ["window"])
    }.to change {
      Timer.last.display_window
    }.from("4h").to("6h")

    starts_at = next_spawn_time_start(Timer.last.name)
    ends_at = next_spawn_time_end(Timer.last.name)
    window_start = display_time_distance(starts_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)
    window_end = display_time_distance(ends_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)

    expect(window_start).to eq("12h 59m 59s")
    expect(window_end).to eq("18h 59m 59s")
  end

  it "should record skip properly with variance && window" do
    window_timer = Timer.create(name: "window", last_tod: Time.now.to_i, window_start: "17 hours", window_end: "19 hour", variance: "1 hour")

    user = double("User")
    expect(user).to receive(:pm).with("Skip recorded for **window**! Updating window.")

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

    expect(window_start).to eq("16h")
    expect(window_end).to eq("20h")

    Timecop.travel(Time.local(2021, 5, 27, 21, 57, 0))

    expect {
      command_skip(event, ["window"])
    }.to change {
      Timer.last.display_window
    }.from("4h").to("8h")

    starts_at = next_spawn_time_start(Timer.last.name)
    ends_at = next_spawn_time_end(Timer.last.name)
    window_start = display_time_distance(starts_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)
    window_end = display_time_distance(ends_at, true, words_connector: " ", last_word_connector: " ", two_words_connector: " ", compact: true)

    expect(window_start).to eq("11h 59m 59s")
    expect(window_end).to eq("19h 59m 59s")
  end
end

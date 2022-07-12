# require "spec_helper"
#
# describe "MessageTwo" do
#   before { Timecop.freeze(Time.local(2021, 5, 27, 1, 57, 0)) }
#   after { Timecop.return }
#
#   it "should build message two" do
#     timers = []
#     timers << Timer.create(name: "window1", last_tod: Time.now.to_i, window_start: "18 hours")
#     timers << Timer.create(name: "window2", last_tod: Time.now.to_i, window_start: "18 hours", window_end: "19 hours")
#     timers << Timer.create(name: "window3", last_tod: Time.now.to_i, window_start: "18 hours", variance: "1 hour")
#     timers << Timer.create(name: "window4", last_tod: Time.now.to_i, window_start: "18 hours", window_end: "19 hours", variance: "1 hour")
#     timers << Timer.create(name: "window5", last_tod: Time.now.to_i, window_start: "18 hours", variance: "0 hour")
#     timers << Timer.create(name: "window6", last_tod: Time.now.to_i, window_start: "18 hours", window_end: "19 hours", variance: "0 hour")
#
#     output = build_timer_message_two(timers: timers)
#
#     expect(output).to eq([
#       ":dragon: __**Timers**__ (##CURRENT_CHAR_COUNT## / ##MAX_CHAR_COUNT##)",
#       "`Timer                         In                  Window         At                    `",
#       "`window6                       18h                 1h             05/27 07:57:00 PM EDT `",
#       "`window5                       18h                                05/27 07:57:00 PM EDT `",
#       "`window2                       18h                 1h             05/27 07:57:00 PM EDT `",
#       "`window1                       18h                                05/27 07:57:00 PM EDT `",
#       "`window4                       17h                 3h             05/27 06:57:00 PM EDT `",
#       "`window3                       17h                 2h             05/27 06:57:00 PM EDT `",
#       "\n"
#     ])
#   end
# end

BOT = Discordrb::Commands::CommandBot.new token: TOKEN,
                                          client_id: CLIENT_ID,
                                          prefix: '!',
                                          name: ENV["BOT_NAME"].to_s

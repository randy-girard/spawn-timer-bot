BOT = Discordrb::Commands::CommandBot.new token: TOKEN,
                                          client_id: CLIENT_ID,
                                          prefix: '!',
                                          ignore_bots: false,
                                          name: ENV["BOT_NAME"].to_s

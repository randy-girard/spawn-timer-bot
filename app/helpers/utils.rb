def clean_username(username)
  username.gsub("＜", "<")
          .gsub("＞", ">")
end

def user_display_name(user)
  user.display_name
rescue NoMethodError
  user.name
end

def can_future_tod?
  !!CAN_FUTURE_TOD
end

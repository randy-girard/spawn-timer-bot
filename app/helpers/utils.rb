def clean_username(username)
  username.gsub("＜", "<")
          .gsub("＞", ">")
end

def can_future_tod?
  !!CAN_FUTURE_TOD
end

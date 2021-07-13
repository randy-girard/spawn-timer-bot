def clean_username(username)
  username.gsub("＜", "<")
          .gsub("＞", ">")
end

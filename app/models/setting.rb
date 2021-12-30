class Setting < Sequel::Model
  def self.find_by_key(key)
    s = Setting.find(key: key)
    if s
      s.value
    else
      nil
    end
  end

  def self.save_by_key(key, value)
    s = Setting.find(key: key) || Setting.new
    s.key = key
    s.value = value
    s.save
    s
  end

  def self.delete_by_key(key)
    s = Setting.find(key: key)
    if s
      s.delete
    end
  end
end

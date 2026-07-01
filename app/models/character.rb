class Character < Sequel::Model
  plugin :validation_helpers
  plugin :timestamps

  VALID_NAME = /\A[A-Za-z][A-Za-z0-9_-]*\z/.freeze
  RESOURCES = %w[inventory spellbook].freeze

  def validate
    super
    validates_presence :name
    validates_unique :name
    validates_format VALID_NAME, :name, message: "contains invalid characters"
  end

  def self.find_by_name(name)
    find(name: name)
  end

  def self.find_or_create_by_name!(name)
    find_by_name(name) || create(name: name)
  end

  def self.filename_for(name, resource)
    suffix = resource == "inventory" ? "-Inventory.txt" : "-Spellbook.txt"
    "#{name}#{suffix}"
  end

  def resource_data(resource)
    public_send("#{resource}_data")
  end

  def resource_present?(resource)
    data = resource_data(resource)
    data && !data.empty?
  end

  def update_resource!(resource, content)
    now = Time.now
    update(
      "#{resource}_data": content,
      "#{resource}_updated_at": now,
      updated_at: now
    )
  end

  def upload_response(resource)
    {
      character: name,
      resource: resource,
      filename: self.class.filename_for(name, resource),
      updated_at: public_send("#{resource}_updated_at").iso8601
    }
  end
end

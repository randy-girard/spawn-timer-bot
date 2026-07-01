helpers do
  def require_character_api_key!
    if CHARACTER_API_KEY.nil? || CHARACTER_API_KEY.empty?
      halt 503, { error: "Character API is not configured" }.to_json
    end

    provided_key = request.env["HTTP_X_API_KEY"] || params["api_key"]
    if provided_key.nil? || provided_key.empty? || !Rack::Utils.secure_compare(provided_key, CHARACTER_API_KEY)
      halt 401, { error: "Invalid or missing API key" }.to_json
    end
  end

  def validate_character_name!(name)
    unless Character::VALID_NAME.match?(name)
      halt 400, { error: "Invalid character name" }.to_json
    end
  end

  def read_upload_content!(resource:)
    ["file", resource].each do |field|
      uploaded = params[field] || params[field.to_sym]
      next unless uploaded.is_a?(Hash) && uploaded[:tempfile]

      content = uploaded[:tempfile].read
      uploaded[:tempfile].rewind if uploaded[:tempfile].respond_to?(:rewind)
      return content unless content.nil? || content.empty?
    end

    content = request.body.read
    return content unless content.nil? || content.empty?

    halt 400, {
      error: "Request body is empty. Send raw file content or multipart form data with a 'file' field."
    }.to_json
  end

  def upload_character_resource!(name, resource)
    validate_character_name!(name)
    content = read_upload_content!(resource: resource)

    character = Character.find_or_create_by_name!(name)
    character.update_resource!(resource, content)
    character.upload_response(resource)
  end

  def fetch_character_resource(name, resource)
    validate_character_name!(name)
    character = Character.find_by_name(name)
    halt 404, { error: "Character not found" }.to_json unless character
    halt 404, { error: "#{resource.capitalize} not found for character" }.to_json unless character.resource_present?(resource)

    character.resource_data(resource)
  end

  def list_character_resources(resource)
    {
      resource: resource,
      characters: Character.list_resources(resource)
    }
  end
end

before "/api/characters/*" do
  content_type :json
  require_character_api_key!
end

get "/api/characters/inventory" do
  list_character_resources("inventory").to_json
end

get "/api/characters/spellbook" do
  list_character_resources("spellbook").to_json
end

get "/api/characters/:name/inventory" do
  content = fetch_character_resource(params[:name], "inventory")
  content_type "text/plain"
  content
end

post "/api/characters/:name/inventory" do
  upload_character_resource!(params[:name], "inventory").to_json
end

get "/api/characters/:name/spellbook" do
  content = fetch_character_resource(params[:name], "spellbook")
  content_type "text/plain"
  content
end

post "/api/characters/:name/spellbook" do
  upload_character_resource!(params[:name], "spellbook").to_json
end

before "/api/dkp/*" do
  content_type :json
  require_character_api_key!

  if DKP_DB.nil?
    halt 503, { error: "DKP database is not configured" }.to_json
  end
end

# Exact-match DKP item lookup (case-insensitive; ` and ' are interchangeable).
#
#   GET /api/dkp/items?q=Belt+of+the+Destroyer
#   GET /api/dkp/items?q=Berserker%60s+Helm
get "/api/dkp/items" do
  query = params["q"].to_s.strip
  if query.empty?
    halt 400, { error: "Missing required query parameter 'q'" }.to_json
  end

  begin
    item = Dkp::Item.find_exact_with_dkp!(query)
    { query: query, item: item }.to_json
  rescue Dkp::AmbiguousItemError => e
    halt 409, e.to_h.to_json
  rescue Dkp::ItemNotFoundError => e
    halt 404, e.to_h.to_json
  end
end

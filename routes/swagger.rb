OPENAPI_SPEC_PATH = File.expand_path("../docs/openapi.yaml", __dir__)

get "/api/openapi.yaml" do
  content_type "application/yaml"
  send_file OPENAPI_SPEC_PATH
end

get "/api/docs" do
  content_type "text/html"
  <<~HTML
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Spawn Timer Bot API</title>
        <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5.11.0/swagger-ui.css">
      </head>
      <body>
        <div id="swagger-ui"></div>
        <script src="https://unpkg.com/swagger-ui-dist@5.11.0/swagger-ui-bundle.js"></script>
        <script>
          SwaggerUIBundle({
            url: "/api/openapi.yaml",
            dom_id: "#swagger-ui",
            deepLinking: true,
            presets: [SwaggerUIBundle.presets.apis, SwaggerUIBundle.SwaggerUIStandalonePreset],
            layout: "BaseLayout"
          });
        </script>
      </body>
    </html>
  HTML
end

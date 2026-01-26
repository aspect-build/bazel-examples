# Rails JSON API Example

This example demonstrates a minimal Ruby on Rails API-only application built with Bazel,
including minitest unit tests.

## Structure

- `app/controllers/` - Rails API controllers
  - `application_controller.rb` - Base API controller
  - `health_controller.rb` - Health check endpoint
  - `items_controller.rb` - CRUD operations for items
- `config/` - Rails configuration (adapted for Bazel sandbox)
- `test/` - Minitest unit tests

## Notes on Bazel Compatibility

Rails' autoloading doesn't work within Bazel's sandbox, so:
- Controllers are explicitly required in `config/application.rb`
- Routes are defined inline in `config/environment.rb`

## Running Tests

```bash
# Run individual tests
bazel test //rails_api:health_controller_test
bazel test //rails_api:items_controller_test

# Run all tests
bazel test //rails_api:all
```

## API Endpoints

- `GET /health` - Health check endpoint
- `GET /items` - List all items
- `GET /items/:id` - Get a single item
- `POST /items` - Create a new item

## Example Responses

### Health Check
```json
{"status": "ok", "timestamp": "2024-01-15T10:30:00Z"}
```

### List Items
```json
{
  "items": [
    {"id": 1, "name": "Widget", "price": 9.99},
    {"id": 2, "name": "Gadget", "price": 19.99},
    {"id": 3, "name": "Gizmo", "price": 29.99}
  ]
}
```

# frozen_string_literal: true

require "pathname" # (FormData::File checks for a Pathname, but doesn't require it)
require "stringio"

# A fixed boundary, so that every iteration (and both versions) builds
# the same body. Multipart.generate_boundary would make a random one.
BOUNDARY = ("-" * 21) + ("0123456789abcdef" * 3)[0, 42]

# http.rb streams a body with IO.copy_stream, which reads it 16 KB at a
# time into one buffer (HTTP::Connection::BUFFER_SIZE).
CHUNK_SIZE = 16_384

# A login form's fields.
def small_params
  { "username" => "ixti", "password" => "s3cr3t p@ss", "remember" => "1" }
end

# A form of `count` fields, with values that need escaping.
def large_params(count)
  Array.new(count) { |i| ["field_#{i}", "value #{i} & more/stuff=#{'x' * (i % 17)}"] }.to_h
end

# Nested hashes and arrays, as Rails-style params.
NESTED_PARAMS = {
  "user"  => {
    "name"        => "Aleksey Zapparov",
    "email"       => "ixti@example.com",
    "address"     => { "street" => "1 Main St", "city" => "Springfield", "zip" => "12345" },
    "roles"       => %w[admin editor viewer],
    "preferences" => { "theme" => "dark", "languages" => %w[en ru uk], "notify" => nil }
  },
  "items" => Array.new(20) { |i| { "id" => i.to_s, "qty" => (i * 3).to_s, "tags" => %w[a b] } },
  "q"     => "search terms with spaces & symbols"
}.freeze

# `size` bytes of binary data, the same every time.
def binary_data(size)
  Random.new(42).bytes(size)
end

# A file part from memory, with its filename and content type given, so
# that its name doesn't come from the IO's object_id.
def file_part(data, filename: "upload.bin", content_type: "application/octet-stream")
  HTTP::FormData::File.new(StringIO.new(data), filename: filename, content_type: content_type)
end

# Reads the whole body as http.rb does, 16 KB at a time into one buffer.
def read_in_chunks(body, buffer)
  body.rewind
  bytes = 0
  bytes += buffer.bytesize while body.read(CHUNK_SIZE, buffer)
  bytes
end

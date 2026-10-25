# frozen_string_literal: true

require_relative "duel_helper"

duel "multipart: build a few text fields" do
  once { @params = small_params }
  HTTP::FormData::Multipart.new(@params, boundary: BOUNDARY)
end

duel "multipart: build 200 text fields" do
  once { @params = large_params(200) }
  HTTP::FormData::Multipart.new(@params, boundary: BOUNDARY)
end

duel "multipart: build with an array of values" do
  once { @params = { "name" => "ixti", "tags" => Array.new(20) { |i| "tag#{i}" } } }
  HTTP::FormData::Multipart.new(@params, boundary: BOUNDARY)
end

duel "multipart: build with a file" do |n|
  once { @data = binary_data(4096) }
  files = untimed { Array.new(n) { file_part(@data, filename: "avatar.png", content_type: "image/png") } }
  files.each { |file| HTTP::FormData::Multipart.new({ "username" => "ixti", "avatar" => file }, boundary: BOUNDARY) }
end

duel "multipart: build with 20 files" do
  once do
    @params = Array.new(20) { |i| ["files[]", HTTP::FormData::Part.new("x" * 512, filename: "f#{i}.txt", content_type: "text/plain")] }
  end
  HTTP::FormData::Multipart.new(@params, boundary: BOUNDARY)
end

duel "multipart: to_s a few text fields" do
  once { @form = HTTP::FormData::Multipart.new(small_params, boundary: BOUNDARY) }
  @form.to_s
end

duel "multipart: to_s 200 text fields" do
  once { @form = HTTP::FormData::Multipart.new(large_params(200), boundary: BOUNDARY) }
  @form.to_s
end

duel "multipart: to_s a 16 KB file" do
  once { @form = HTTP::FormData::Multipart.new({ "file" => file_part(binary_data(16_384)) }, boundary: BOUNDARY) }
  @form.to_s
end

duel "multipart: read a 64 KB file in 16 KB chunks" do
  once do
    @form = HTTP::FormData::Multipart.new({ "name" => "ixti", "file" => file_part(binary_data(65_536)) },
                                          boundary: BOUNDARY)
    @buffer = String.new(capacity: CHUNK_SIZE)
  end
  read_in_chunks(@form, @buffer)
end

duel "multipart: read 200 fields in 16 KB chunks" do
  once do
    @form = HTTP::FormData::Multipart.new(large_params(200), boundary: BOUNDARY)
    @buffer = String.new(capacity: CHUNK_SIZE)
  end
  read_in_chunks(@form, @buffer)
end

duel "multipart: read in small chunks" do
  once do
    @form = HTTP::FormData::Multipart.new(small_params.merge("file" => file_part(binary_data(4096))),
                                          boundary: BOUNDARY)
    @buffer = String.new(capacity: 64)
  end
  @form.rewind
  nil while @form.read(64, @buffer)
end

duel "multipart: rewind 200 fields" do
  once do
    @form = HTTP::FormData::Multipart.new(large_params(200), boundary: BOUNDARY)
    @form.to_s
  end
  @form.rewind
end

duel "multipart: content length of 200 fields" do |n|
  once { @params = large_params(200) }
  forms = untimed { Array.new(n) { HTTP::FormData::Multipart.new(@params, boundary: BOUNDARY) } }
  forms.each(&:content_length)
end

duel "multipart: content length with a file" do |n|
  once { @data = binary_data(4096) }
  forms = untimed do
    Array.new(n) { HTTP::FormData::Multipart.new({ "name" => "ixti", "file" => file_part(@data) }, boundary: BOUNDARY) }
  end
  forms.each(&:content_length)
end

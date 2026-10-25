# frozen_string_literal: true

require_relative "duel_helper"

duel "urlencode: a small form" do
  once { @params = small_params }
  HTTP::FormData.create(@params)
end

duel "urlencode: a large form of 200 fields" do
  once { @params = large_params(200) }
  HTTP::FormData.create(@params)
end

duel "urlencode: nested hashes and arrays" do
  once { @params = NESTED_PARAMS }
  HTTP::FormData.create(@params)
end

duel "urlencode: pairs with repeated keys" do
  once { @pairs = Array.new(50) { |i| ["tag", "tag #{i}"] } + [%w[page 2], ["flag", nil]] }
  HTTP::FormData.create(@pairs)
end

duel "urlencode: values with multibyte characters" do
  once { @params = { "name" => "Алексей Запаров", "city" => "東京都", "note" => "café ☕ — naïve résumé" } }
  HTTP::FormData.create(@params)
end

duel "urlencode: read a large body" do
  once { @form = HTTP::FormData.create(large_params(200)) }
  @form.to_s
end

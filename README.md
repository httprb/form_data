# FormData

Utility-belt to build form data request bodies.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'form_data'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install form_data


## Usage

``` ruby
form = FormData.create({
  :username     => "ixti",
  :avatar_file  => FormData::File.new("/home/ixti/avatar.png")
})

# Assuming socket is an open socket to some HTTP server
socket << "POST /some-url HTTP/1.1\r\n"
socket << "Host: example.com\r\n"
socket << "Content-Type: #{form.content_type}\r\n"
socket << "Content-Length: #{form.content_length}\r\n"
socket << "\r\n"
socket << form.to_s
```


## Contributing

1. Fork it ( https://github.com/ixti/form_data.rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Copyright

Copyright (c) 2014 Aleksey V Zapparov.
See [LICENSE.txt][1] for further details.

[1]: https://github.com/ixti/form_data.rb/blob/master/LICENSE.txt

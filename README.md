# AsJsonRepresentations
[![Gem Version](https://badge.fury.io/rb/as_json_representations.svg)](https://badge.fury.io/rb/as_json_representations)
![Build Status](https://travis-ci.org/rjurado01/as_json_representations.svg?branch=master)

Creates representations of your model data in a simple and clean way.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'as_json_representations'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install as_json_representations

## Usage

Includes the `AsJsonRepresentations` module into your class and define your representations.  
Representations are evaluated into class instance object and must returns a `json` object.

```ruby
class User
  include AsJsonRepresentations

  attr_accessor :first_name, :last_name, :age, :city

  def initialize(first_name, last_name, age, city)
    @first_name = first_name
    @last_name = last_name
    @age = age
    @city = city
  end

  representation :public do |options| # you can pass options
    {
      full_name: "#{first_name} #{last_name}",
      date: options[:date]
    }
  end

  representation :private, extend: :public do # you can extends other representations
    {
      age: age,
      city: city.as_json(representation: :basic)
    }
  end
end

# you can define representations in a module
module CityRepresentations
  include AsJsonRepresentations

  representation :basic do
    {
      name: name
    }
  end
end

class City
  include CityRepresentations

  attr_accessor :name

  def initialize(name)
    @name = name
  end
end

city = City.new('Madrid')
user = User.new('John', 'Doe', 30, city)
user.as_json(representation: :private, date: '2017-12-21')
# {:full_name=>"John Doe", :date=>"2017-12-21", :age=>30, :city=>{:name=>"Madrid"}}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/as_json_representations.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

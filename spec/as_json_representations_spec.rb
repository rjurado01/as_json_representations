RSpec.describe AsJsonRepresentations do
  it 'has a version number' do
    expect(AsJsonRepresentations::VERSION).not_to be nil
  end

  it 'render correctly representations' do
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

    expect(
      user.as_json(representation: :private, date: '2017-12-21')
    ).to eq(full_name: 'John Doe', age: 30, date: '2017-12-21', city: {name: 'Madrid'})
  end
end

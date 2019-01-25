RSpec.describe AsJsonRepresentations do
  it 'has a version number' do
    expect(AsJsonRepresentations::VERSION).not_to be nil
  end

  context 'when use into basic class' do
    before :all do
      class User < ActiveRecord::Base
        include AsJsonRepresentations

        belongs_to :city

        representation :public do |options| # you can pass options
          {
            full_name: "#{first_name} #{last_name}",
            date: options[:date]
          }
        end

        # you can extend another representations and use includes (ActiveRecord)
        representation :private, extend: :public, includes: [:city] do
          {
            age: age,
            city: city.as_json(representation: :basic)
          }
        end
      end

      # you can define representations in a module
      module CityRepresentations
        include AsJsonRepresentations

        representation :basic, includes: [:uno, :dos] do
          {
            name: name
          }
        end
      end

      module City2Representations
        include CityRepresentations
        representation :basic, extend: true do
          {
            status: status
          }
        end
      end

      class City < ActiveRecord::Base
        include CityRepresentations

        has_many :user
      end
      class City2 < City
        include City2Representations

        def status
          "statu2s"
        end
      end

      @city = City.create(name: 'Madrid')
      @city = City2.create(name: 'Madrid2')
      @user = User.create(first_name: 'John', last_name: 'Doe', age: 30, city: @city)
      @result = {full_name: 'John Doe', age: 30, date: '2017-12-21', city: {name: 'Madrid'}}
    end

    context 'when representation is called' do
      it 'doesn\'t work' do
        data = City.all.as_json(representation: :basic)

        expect(data[0]).to eq(name: 'Madrid')
        expect(data[1]).to eq(name: 'Madrid2', status: 'statu2s')
      end
    end

    context 'when representation is called' do
      it 'doesn\'t work' do
        data = City.all.representation(:basic)

        expect(data[0]).to eq(name: 'Madrid')
        expect(data[1]).to eq(name: 'Madrid2', status: 'statu2s')
      end
    end
  end
end

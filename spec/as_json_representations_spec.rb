RSpec.describe AsJsonRepresentations do
  it 'has a version number' do
    expect(AsJsonRepresentations::VERSION).not_to be nil
  end

  context 'when use into basic class' do
    before :all do
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

      @city = City.new('Madrid')
      @user = User.new('John', 'Doe', 30, @city)
      @result = {full_name: 'John Doe', age: 30, date: '2017-12-21', city: {name: 'Madrid'}}
    end

    context 'when use as_json method' do
      context 'when pass representation as symbol' do
        it 'renders correctly representations' do
          expect(@user.as_json(representation: :private, date: '2017-12-21')).to eq(@result)
        end
      end

      context 'when pass representation as string' do
        it 'renders correctly representations' do
          expect(@user.as_json(representation: 'private', date: '2017-12-21')).to eq(@result)
        end
      end
    end

    context 'when use representation method' do
      it 'renders correctly representations' do
        expect(@user.representation(:private, date: '2017-12-21')).to eq(@result)
      end
    end

    context 'when use representation method with an array' do
      it 'renders correctly representations' do
        query = [@user]
        allow(query).to receive(:includes).and_return(query)
        expect(query).to receive(:includes).with(:city)
        expect(query.representation(:private, date: '2017-12-21')).to eq([@result])
      end
    end
  end

  context 'when class has as_json method' do
    before :all do
      module AsJsonDefault
        def as_json(options=nil)
          {dog_name: name, color: options[:color]}
        end
      end

      class Dog
        include AsJsonDefault
        include AsJsonRepresentations

        attr_accessor :name

        def initialize(name)
          @name = name
        end

        representation :basic do
          {name: name}
        end
      end
    end

    context 'when use representation option' do
      it 'renders representation' do
        dog = Dog.new('bob')
        expect(dog.as_json(representation: :basic)).to eq(name: 'bob')
      end
    end

    context 'when do not use representation option' do
      it 'calls super method' do
        dog = Dog.new('bob')
        expect(dog.as_json(color: 'dark')).to eq(dog_name: 'bob', color: 'dark')
      end
    end
  end

  context 'when use into module with inheritance' do
    before :all do
      module ParentRepresentations
        include AsJsonRepresentations

        representation :a do
          {name: name}
        end

        representation :b, includes: %i[test2 test3] do
          {name: name}
        end

        representation :c, extend: :basic, includes: %i[test] do
          {name: name}
        end
      end

      module ChildRepresentations
        include ParentRepresentations

        representation :a do
          {color: color}
        end

        representation :b, extend: true, includes: %i[test] do
          {color: color}
        end
      end

      module GrandChildRepresentations
        include ChildRepresentations

        representation :b, extend: true do
          {aux: true}
        end
      end

      class Parent
        include ParentRepresentations

        attr_accessor :name

        def initialize(name)
          @name = name
        end
      end

      class Child < Parent
        include ChildRepresentations

        attr_accessor :color

        def initialize(name, color)
          @name = name
          @color = color
        end
      end

      class GrandChild < Child
        include GrandChildRepresentations
      end
    end

    it 'renders representation' do
      # first level
      parent = Parent.new('parent')
      expect(parent.as_json(representation: :a)).to eq(name: 'parent') # overwritten

      # second level
      child = Child.new('child', 'red')
      expect(child.as_json(representation: :a)).to eq(color: 'red') # overwritten
      expect(child.as_json(representation: :b)).to eq(name: 'child', color: 'red') # extended
      expect(child.as_json(representation: :c)).to eq(name: 'child') # parent

      # third level
      gchild = GrandChild.new('gchild', 'blue')
      expect(gchild.as_json(representation: :b)).to eq(name: 'gchild', color: 'blue', aux: true)
    end

    it 'uses includes with collection' do
      query = [Parent.new('gchild')]
      allow(query).to receive(:includes).and_return(query)
      expect(query).to receive(:includes).with(:test2).with(:test3)
      query.representation(:b)
    end

    it 'uses includes with inheritance' do
      query = [Child.new('gchild', 'blue')]
      allow(query).to receive(:includes).and_return(query)
      expect(query).to receive(:includes).with(:test).with(:test2).with(:test3)
      query.representation(:b)
    end
  end
end

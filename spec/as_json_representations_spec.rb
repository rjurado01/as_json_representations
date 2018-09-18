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

        representation :private, extend: :public do # you can extends another representations
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

        representation :a do {name: name} end
        representation :b do {name: name} end
        representation :c do {name: name} end
      end

      module ChildRepresentations
        include ParentRepresentations

        representation :a do {color: color} end

        representation :b, extend: true do
          {color: color}
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
    end

    it 'renders representation' do
      parent = Parent.new('parent')
      expect(parent.as_json(representation: :a)).to eq(name: 'parent') # overwritten

      child = Child.new('child', 'red')
      expect(child.as_json(representation: :a)).to eq(color: 'red') # overwritten
      expect(child.as_json(representation: :b)).to eq(name: 'child', color: 'red') # extended
      expect(child.as_json(representation: :c)).to eq(name: 'child') # parent
    end
  end
end

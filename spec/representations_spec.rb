RSpec.describe 'Representation' do
  describe 'when use into basic class' do
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

        representation :city do
          {
            city: city.as_json(representation: :basic)
          }
        end

        representation :private, extend: :public do # you can extend another representations
          {
            age: age
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
    end

    after :all do
      [User, City, CityRepresentations].each { |x| Object.send(:remove_const, x.to_s) }
    end

    context 'when use simple representation' do
      let(:result) { {full_name: 'John Doe', date: nil} }

      it 'renders correctly with representation as symbol' do
        expect(@user.as_json(representation: :public)).to eq(result)
      end

      it 'renders correctly with representation as string' do
        expect(@user.as_json(representation: 'public')).to eq(result)
      end

      it 'renders correctly when use :repersentation alias' do
        expect(@user.representation(:public)).to eq(result)
      end
    end

    context 'when pass options' do
      let(:result) { {full_name: 'John Doe', date: '2017-12-21'} }

      it 'renders correctly' do
        expect(@user.as_json(representation: :public, date: '2017-12-21')).to eq(result)
      end
    end

    context 'when use representation with relations' do
      let(:result) { {city: {name: 'Madrid'}} }

      it 'renders correctly' do
        expect(@user.as_json(representation: :city)).to eq(result)
      end
    end

    context 'when use representation with extend' do
      let(:result) { {full_name: 'John Doe', date: nil, age: 30} }

      it 'renders correctly' do
        expect(@user.as_json(representation: :private)).to eq(result)
      end
    end

    context 'when use representation with an array' do
      let(:result) { {full_name: 'John Doe', date: nil} }

      it 'renders correctly representations' do
        query = [@user]
        expect(query.representation(:public)).to eq([result])
      end
    end
  end

  context 'when use into class with has as_json method' do
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

    after :all do
      [AsJsonDefault, Dog].each { |x| Object.send(:remove_const, x.to_s) }
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

        representation :b do
          {name: name}
        end

        representation :c do
          {name: name}
        end
      end

      module ChildRepresentations
        include ParentRepresentations

        representation :a do
          {color: color}
        end

        representation :b, extend: true do
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

    after :all do
      [
        Parent, Child, GrandChild,
        ParentRepresentations, ChildRepresentations, GrandChildRepresentations
      ].each { |x| Object.send(:remove_const, x.to_s) }
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
  end
end

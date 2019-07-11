RSpec.describe 'QueryMethods' do
  describe '#includes' do
    context 'when use module reprsentation' do
      before :all do
        module ChildRepresentations
          include AsJsonRepresentations

          representation(:a, includes: [:one]) { {} }
        end

        class Child
          include ChildRepresentations
        end
      end

      after :all do
        [Child, ChildRepresentations].each { |x| Object.send(:remove_const, x.to_s) }
      end

      let(:query) { [Child.new] }

      it 'uses includes correcly' do
        allow(query).to receive(:includes).and_return(query)
        allow(query).to receive(:klass).and_return(query.first.class)
        expect(query).to receive(:includes).with([:one])
        query.as_json(representation: :a)
      end

      it 'works when includes returns new query (ActiveRecord::Relation)' do
        includes_query = query.dup # simulate returns new query when calls include
        allow(query).to receive(:includes).and_return(includes_query)

        allow(query).to receive(:klass).and_return(query.first.class)
        expect(query).to receive(:includes).with([:one])
        expect(includes_query).to receive(:map).and_call_original
        query.as_json(representation: :a)
      end
    end

    context 'when use module reprsentation with extend' do
      before :all do
        module ChildRepresentations
          include AsJsonRepresentations

          representation(:a, includes: [:one]) { {} }
          representation(:b, extend: :a, includes: [:two]) { {} }
        end

        class Child
          include ChildRepresentations
        end
      end

      after :all do
        [Child, ChildRepresentations].each { |x| Object.send(:remove_const, x.to_s) }
      end

      it 'uses includes correcly' do
        child = Child.new
        query = [child]

        allow(query).to receive(:includes).and_return(query)
        allow(query).to receive(:klass).and_return(query.first.class)
        expect(query).to receive(:includes).with(%i[one two])
        query.as_json(representation: :b)
      end
    end

    context 'when use module reprsentation with extend and inheritance' do
      before :all do
        module ParentRepresentations
          include AsJsonRepresentations

          representation(:a, includes: [:one]) { {} }
        end

        module ChildRepresentations
          include ParentRepresentations

          representation(:a, extend: true, includes: [:two]) { {} }
        end

        class Child
          include ChildRepresentations
        end
      end

      after :all do
        [
          Child, ChildRepresentations, ParentRepresentations
        ].each { |x| Object.send(:remove_const, x.to_s) }
      end

      it 'uses includes correcly' do
        child = Child.new
        query = [child]

        allow(query).to receive(:includes).and_return(query)
        allow(query).to receive(:klass).and_return(query.first.class)
        expect(query).to receive(:includes).with(%i[one two])
        query.as_json(representation: :a)
      end
    end
  end

  describe '#eager_load' do
    context 'when use module reprsentation' do
      before :all do
        module ChildRepresentations
          include AsJsonRepresentations

          representation(:a, eager_load: [:one]) { {} }
        end

        class Child
          include ChildRepresentations
        end
      end

      after :all do
        [Child, ChildRepresentations].each { |x| Object.send(:remove_const, x.to_s) }
      end

      let(:query) { [Child.new] }

      it 'uses eager_load correcly' do
        allow(query).to receive(:eager_load).and_return(query)
        allow(query).to receive(:klass).and_return(query.first.class)
        expect(query).to receive(:eager_load).with([:one])
        query.as_json(representation: :a)
      end

      it 'works when eager_load returns new query (ActiveRecord::Relation)' do
        eager_load_query = query.dup # simulate returns new query when calls include
        allow(query).to receive(:eager_load).and_return(eager_load_query)

        allow(query).to receive(:klass).and_return(query.first.class)
        expect(query).to receive(:eager_load).with([:one])
        expect(eager_load_query).to receive(:map).and_call_original
        query.as_json(representation: :a)
      end
    end

    context 'when use module reprsentation with extend' do
      before :all do
        module ChildRepresentations
          include AsJsonRepresentations

          representation(:a, eager_load: [:one]) { {} }
          representation(:b, extend: :a, eager_load: [:two]) { {} }
        end

        class Child
          include ChildRepresentations
        end
      end

      after :all do
        [Child, ChildRepresentations].each { |x| Object.send(:remove_const, x.to_s) }
      end

      it 'uses eager_load correcly' do
        child = Child.new
        query = [child]

        allow(query).to receive(:eager_load).and_return(query)
        allow(query).to receive(:klass).and_return(query.first.class)
        expect(query).to receive(:eager_load).with(%i[one two])
        query.as_json(representation: :b)
      end
    end

    context 'when use module reprsentation with extend and inheritance' do
      before :all do
        module ParentRepresentations
          include AsJsonRepresentations

          representation(:a, eager_load: [:one]) { {} }
        end

        module ChildRepresentations
          include ParentRepresentations

          representation(:a, extend: true, eager_load: [:two]) { {} }
        end

        class Child
          include ChildRepresentations
        end
      end

      after :all do
        [
          Child, ChildRepresentations, ParentRepresentations
        ].each { |x| Object.send(:remove_const, x.to_s) }
      end

      it 'uses eager_load correcly' do
        child = Child.new
        query = [child]

        allow(query).to receive(:eager_load).and_return(query)
        allow(query).to receive(:klass).and_return(query.first.class)
        expect(query).to receive(:eager_load).with(%i[one two])
        query.as_json(representation: :a)
      end
    end
  end
end

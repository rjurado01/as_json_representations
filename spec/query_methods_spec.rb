RSpec.describe 'QueryMethods' do
  AsJsonRepresentations::QUERY_METHODS.each do |query_method|
    describe "#{query_method}" do
      before :all do
        QUERY_METHOD = query_method
      end

      after :all do
        Object.send(:remove_const, 'QUERY_METHOD')
      end

      context 'when use module representation' do
        before :all do
          module ChildRepresentations
            include AsJsonRepresentations

            representation(:a, QUERY_METHOD => [:one]) { {} }
          end

          class Child
            include ChildRepresentations
          end
        end

        after :all do
          [Child, ChildRepresentations].each { |x| Object.send(:remove_const, x.to_s) }
        end

        let(:query) { [Child.new] }

        it "uses #{query_method} correcly" do
          allow(query).to receive(query_method).and_return(query)
          allow(query).to receive(:klass).and_return(query.first.class)
          expect(query).to receive(query_method).with([:one])
          query.as_json(representation: :a)
        end

        it "works when #{query_method} returns new query (ActiveRecord::Relation)" do
          query_method_query = query.dup # simulate returns new query when calls include
          allow(query).to receive(query_method).and_return(query_method_query)

          allow(query).to receive(:klass).and_return(query.first.class)
          expect(query).to receive(query_method).with([:one])
          expect(query_method_query).to receive(:map).and_call_original
          query.as_json(representation: 'a') # support string as representation name
        end
      end

      context 'when use module representation with extend' do
        before :all do
          module ChildRepresentations
            include AsJsonRepresentations

            representation(:a, QUERY_METHOD => [:one]) { {} }
            representation(:b, extend: :a, QUERY_METHOD => [:two]) { {} }
          end

          class Child
            include ChildRepresentations
          end
        end

        after :all do
          [Child, ChildRepresentations].each { |x| Object.send(:remove_const, x.to_s) }
        end

        it "uses #{query_method} correcly" do
          child = Child.new
          query = [child]

          allow(query).to receive(query_method).and_return(query)
          allow(query).to receive(:klass).and_return(query.first.class)
          expect(query).to receive(query_method).with(%i[one two])
          query.as_json(representation: :b)
        end
      end

      context 'when use module reprsentation with extend and inheritance' do
        before :all do
          module ParentRepresentations
            include AsJsonRepresentations

            representation(:a, QUERY_METHOD => [:one]) { {} }
          end

          module ChildRepresentations
            include ParentRepresentations

            representation(:a, extend: true, QUERY_METHOD => [:two]) { {} }
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

        it "uses #{query_method} correcly" do
          child = Child.new
          query = [child]

          allow(query).to receive(query_method).and_return(query)
          allow(query).to receive(:klass).and_return(query.first.class)
          expect(query).to receive(query_method).with(%i[one two])
          query.as_json(representation: :a)
        end
      end
    end
  end
end

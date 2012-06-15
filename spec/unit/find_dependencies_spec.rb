module Jeeves
  class ImportMethod; end
  class ImportCallable; end
  class ImportConstant; end
end
require "jeeves/find_dependencies"

module Jeeves
  describe FindDependencies do
    let(:scope) { stub("scope", to_s: "ScopeStub") }
    let(:delegator) { stub("delegator") }

    before do
      ImportMethod.stub(:call)
      ImportCallable.stub(:call)
      ImportConstant.stub(:call)
    end

    it "maps dependency names to anonymous delegator functions" do
      ImportMethod.stub(:call).with(:my_dependency, scope) { delegator }
      FindDependencies.call(scope, :my_dependency).should == {
        my_dependency: delegator
      }
    end

    it "maps multiple dependencies" do
      delegator2 = stub("delegator 2")
      ImportMethod.stub(:call).with(:my_dep_1, scope) { delegator }
      ImportMethod.stub(:call).with(:my_dep_2, scope) { delegator2 }
      FindDependencies.call(scope, :my_dep_1, :my_dep_2).should == {
        my_dep_1: delegator,
        my_dep_2: delegator2
      }
    end

    it "uses ImportCallable if ImportMethod fails" do
      ImportCallable.stub(:call).with(:my_dependency, scope) { delegator }
      FindDependencies.call(scope, :my_dependency).should == {
        my_dependency: delegator
      }
    end

    it "uses ImportConstant if ImportMethod and ImportCallable fail" do
      ImportConstant.stub(:call).with(:my_dependency, scope) { delegator }
      FindDependencies.call(scope, :my_dependency).should == {
        my_dependency: delegator
      }
    end

    it "raises an error if all importers fail" do
      expect { FindDependencies.call(scope, :my_dependency) }.
        to raise_error(ArgumentError,
          "Dependency 'my_dependency' was not found in ScopeStub")
    end
  end
end


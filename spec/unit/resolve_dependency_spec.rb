module Jeeves
  class ImportMethod; end
  class ImportCallable; end
  class ImportConstant; end
end
require "jeeves/resolve_dependency"

module Jeeves
  describe ResolveDependency do
    let(:scope) { stub("scope", to_s: "ScopeStub") }
    let(:delegator) { stub("delegator") }

    before do
      ImportMethod.stub(:call)
      ImportCallable.stub(:call)
      ImportConstant.stub(:call)
    end

    it "maps dependency names to anonymous delegator functions" do
      ImportMethod.stub(:call).with(:my_dependency, scope) { delegator }
      ResolveDependency.call(scope, :my_dependency).should be(delegator)
    end

    it "uses ImportCallable if ImportMethod fails" do
      ImportCallable.stub(:call).with(:my_dependency, scope) { delegator }
      ResolveDependency.call(scope, :my_dependency).should be(delegator)
    end

    it "uses ImportConstant if ImportMethod and ImportCallable fail" do
      ImportConstant.stub(:call).with(:my_dependency, scope) { delegator }
      ResolveDependency.call(scope, :my_dependency).should be(delegator)
    end

    it "raises an error if all importers fail" do
      expect { ResolveDependency.call(scope, :my_dependency) }.
        to raise_error(ArgumentError,
          "Dependency 'my_dependency' was not found in ScopeStub")
    end
  end
end


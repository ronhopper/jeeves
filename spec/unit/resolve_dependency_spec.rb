module Jeeves
  class ResolveMethod; end
  class ResolveCallable; end
  class ResolveConstant; end
end
require "jeeves/resolve_dependency"

module Jeeves
  describe ResolveDependency do
    let(:scope) { stub("scope", to_s: "ScopeStub") }
    let(:delegator) { stub("delegator") }

    before do
      Jeeves::ResolveDependency.stub(:in_test_framework?) { false } # to avoid RSpec integration
      ResolveMethod.stub(:call)
      ResolveCallable.stub(:call)
      ResolveConstant.stub(:call)
    end

    it "maps dependency names to anonymous delegator functions" do
      ResolveMethod.stub(:call).with(scope, :my_dependency) { delegator }
      ResolveDependency.call(scope, :my_dependency).should be(delegator)
    end

    it "uses ResolveCallable if ResolveMethod fails" do
      ResolveCallable.stub(:call).with(scope, :my_dependency) { delegator }
      ResolveDependency.call(scope, :my_dependency).should be(delegator)
    end

    it "uses ResolveConstant if ResolveMethod and ResolveCallable fail" do
      ResolveConstant.stub(:call).with(scope, :my_dependency) { delegator }
      ResolveDependency.call(scope, :my_dependency).should be(delegator)
    end

    it "raises an error if all importers fail" do
      expect { ResolveDependency.call(scope, :my_dependency) }.
        to raise_error(Jeeves::UnresolvedDependency,
          "Dependency 'my_dependency' was not found in ScopeStub")
    end
  end
end


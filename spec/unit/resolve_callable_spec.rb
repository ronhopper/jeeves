require "jeeves/resolve_callable"

module JeevesTestApp
  module CallableTest
    class StaticCallable
      def self.call(*args, &block)
        block.call(args.map(&:to_s).join("*"))
      end
    end

    class MyCallable
      def call(*args, &block)
        block.call(args.map(&:to_s).join("-"))
      end
    end
  end
end

module Jeeves
  describe ResolveCallable do

    it "returns an anonymous function which delegates to the static call method of the callable" do
      delegator = ResolveCallable.call(JeevesTestApp::CallableTest, :static_callable)
      result = delegator.call(:foo, :bar, :baz) { |s| s.capitalize }
      result.should == "Foo*bar*baz"
    end

    it "returns an anonymous function which delegates to a new instance of the callable" do
      delegator = ResolveCallable.call(JeevesTestApp::CallableTest, :my_callable)
      result = delegator.call(:foo, :bar, :baz) { |s| s.upcase }
      result.should == "FOO-BAR-BAZ"
    end

    it "returns nil if the the callable class is not defined" do
      delegator = ResolveCallable.call(JeevesTestApp::CallableTest, :undefined_callable)
      delegator.should be(nil)
    end

  end
end


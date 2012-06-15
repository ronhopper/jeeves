require "jeeves/import_callable"

module JeevesTestApp
  module CallableTest
    class MyCallable
      def call(*args, &block)
        block.call(args.map(&:to_s).join("-"))
      end
    end
  end
end

module Jeeves
  describe ImportCallable do

    it "returns an anonymous function which delegates to a new instance of the callable" do
      callable = ImportCallable.call(:my_callable, JeevesTestApp::CallableTest)
      result = callable.call(:foo, :bar, :baz) { |s| s.upcase }
      result.should == "FOO-BAR-BAZ"
    end

    it "returns nil if the the callable class is not defined" do
      callable = ImportCallable.call(:undefined_callable, JeevesTestApp::CallableTest)
      callable.should be(nil)
    end

  end
end


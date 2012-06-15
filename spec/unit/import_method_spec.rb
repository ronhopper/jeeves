require "jeeves/import_method"

module JeevesTestApp
  module MethodTest
    def self.my_method(*args, &block)
      block.call(args.map(&:to_s).join("-"))
    end
  end
end

module Jeeves
  describe ImportMethod do

    it "returns an anonymous function which delegates to the method" do
      delegator = ImportMethod.call(:my_method, JeevesTestApp::MethodTest)
      result = delegator.call(:foo, :bar, :baz) { |s| s.upcase }
      result.should == "FOO-BAR-BAZ"
    end

    it "returns nil if the scope does not respond to the method" do
      delegator = ImportMethod.call(:undefined_method, JeevesTestApp::MethodTest)
      delegator.should be(nil)
    end

  end
end


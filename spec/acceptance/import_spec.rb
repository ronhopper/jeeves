require "jeeves"

module JeevesTestApp
  module OtherScope
    def self.my_method(*args, &block)
      block.call(args.map(&:to_s).join("-"))
    end

    class MyCallable
      def call(*args, &block)
        block.call(args.map(&:to_s).join("+"))
      end
    end

    MY_CONSTANT = "MY VALUE"
  end

  module InnerScope
    class TestSubject
      extend Jeeves
      import :my_method, from: OtherScope
      import :my_callable, from: OtherScope
      import :my_constant, from: OtherScope
    end
  end
end

describe "import" do
  subject { JeevesTestApp::InnerScope::TestSubject.new }

  it "imports a method" do
    result = subject.my_method(:foo, :bar, :baz) { |s| s.upcase }
    result.should == "FOO-BAR-BAZ"
  end

  it "imports a callable" do
    result = subject.my_callable(:foo, :bar, :baz) { |s| s.reverse }
    result.should == "zab+rab+oof"
  end

  it "imports a constant" do
    subject.my_constant.should == "MY VALUE"
  end
end


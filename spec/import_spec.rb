require "jeeves"

module JeevesTestApp
  module OtherScope
    def self.my_method(*args, &block)
      block.call(args.map(&:to_s).join("-"))
    end

    class MyCallableClass
      def self.call(*args, &block)
        block.call(args.map(&:to_s).join("+"))
      end
    end

    class MyCallableInstance
      def call(*args, &block)
        block.call(args.map(&:to_s).join("*"))
      end
    end

    MY_CONSTANT = "FIDELLE"
  end

  module InnerScope
    class TestSubject
      extend Jeeves
      import :my_method, from: OtherScope
      import :my_callable_class, from: OtherScope
      import :my_callable_instance, from: OtherScope
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

  it "imports a callable class" do
    result = subject.my_callable_class(:foo, :bar, :baz) { |s| s.reverse }
    result.should == "zab+rab+oof"
  end

  it "imports a callable instance" do
    result = subject.my_callable_instance(:foo, :bar, :baz) { |s| s.capitalize }
    result.should == "Foo*bar*baz"
  end

  it "imports a constant" do
    subject.my_constant.should == "FIDELLE"
  end
end


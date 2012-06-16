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
    def self.marco
      :polo
    end

    class TestSubject
      extend Jeeves
      import :my_method, :my_callable, :my_constant, from: OtherScope
      import :marco
      import :lazy_method, lazy: true
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

  it "defaults to the current class's scope" do
    subject.marco.should == :polo
  end

  it "resolves lazy dependencies at call time" do
    JeevesTestApp::InnerScope.stub(:lazy_method) { :snooze }
    subject.lazy_method.should == :snooze
  end

  it "resolves non-lazy dependencies at import time" do
    JeevesTestApp::InnerScope.stub(:marco) { :not_polo }
    subject.marco.should == :polo
  end

  it "raises an error if no importers can find the dependency" do
    Jeeves::ImportMock.stub(:call) # to avoid RSpec integration
    expect { subject.class.import :unknown, from: JeevesTestApp::OtherScope }.
      to raise_error(ArgumentError,
           "Dependency 'unknown' was not found in JeevesTestApp::OtherScope")
  end
end


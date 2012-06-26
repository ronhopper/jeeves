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

    class StaticCallable
      def self.call(*args, &block)
        block.call(args.map(&:to_s).join("*"))
      end
    end

    class AClass
      A_CONSTANT = 4326
    end

    class TestSubject
      extend Jeeves
      import :my_method, :my_callable, :my_constant, from: OtherScope
      import :marco, :static_callable, lazy: false
      import :lazy_method, lazy: true
      import :smart_resolver
      import [:marco, :say_polo]
      import :a_constant, from: AClass, lazy: true
    end

    def self.smart_resolver
      :acts_smart
    end
  end
end

describe "import" do
  subject { JeevesTestApp::InnerScope::TestSubject.new }

  it "imports a method" do
    result = subject.my_method(:foo, :bar, :baz) { |s| s.upcase }
    result.should == "FOO-BAR-BAZ"
  end

  it "imports a static callable" do
    result = subject.static_callable(:foo, :bar, :baz) { |s| s.capitalize }
    result.should == "Foo*bar*baz"
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
    JeevesTestApp::InnerScope.stub(:lazy_method) { :snooze1 }
    subject.lazy_method.should == :snooze1
    JeevesTestApp::InnerScope.stub(:lazy_method) { :snooze2 }
    subject.lazy_method.should == :snooze2
  end

  it "resolves non-lazy dependencies at import time" do
    JeevesTestApp::InnerScope.stub(:marco) { :not_polo }
    subject.marco.should == :polo
  end

  it "defaults to resolving dependencies once at first call" do
    subject.smart_resolver
    JeevesTestApp::InnerScope.stub(:smart_resolver) { :snooze }
    subject.smart_resolver.should == :acts_smart
  end

  it "imports under an alias" do
    subject.say_polo.should == :polo
  end

  it "also imports into as a class method" do
    result = subject.class.my_method(:foo, :bar, :baz) { |s| s.upcase }
    result.should == "FOO-BAR-BAZ"
  end

  it "defines imported methods in the singleton class" do
    subject.a_constant.should == 4326
    # this results in a stack overflow if the methods are defined on Class
  end

  it "raises an error if no importers can find the dependency" do
    Jeeves.stub(:in_test_framework?) { false } # to avoid RSpec integration
    expect do
      class JeevesTestApp::InnerScope::TestSubject
        import :unknown, from: JeevesTestApp::OtherScope, lazy: false
      end
    end.to raise_error(Jeeves::UnresolvedDependency,
                       "Dependency 'unknown' was not found in JeevesTestApp::OtherScope")
  end

  it "raises an error if the scope is undefined" do
    Jeeves.stub(:in_test_framework?) { false } # to avoid RSpec integration
    expect do
      class JeevesTestApp::InnerScope::TestSubject
        import :unknown, from: MyUndefined::Scope, lazy: false
      end
    end.to raise_error(NameError)
  end
end


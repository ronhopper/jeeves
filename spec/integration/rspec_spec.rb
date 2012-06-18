require "jeeves"

module JeevesTestApp
  module InnerScope
    def self.loaded_dependency
      :real_value
    end

    class TestSubject
      extend Jeeves
      import :my_mock, :loaded_dependency

      def call
        my_mock(42)
      end

      def call_integrated
        loaded_dependency
      end
    end
  end
end

describe "rspec integration" do
  subject { JeevesTestApp::InnerScope::TestSubject.new }

  it "wires dependencies directly to Jeeves for easy stubbing" do
    Jeeves.stub(:my_mock).with(42) { "The answer?" }
    subject.call.should == "The answer?"
  end

  it "raises an error if the dependency is not mocked" do
    expect { subject.call }.to raise_error(Jeeves::UnresolvedDependency,
      "Dependency 'my_mock' was not found in JeevesTestApp::InnerScope")
  end

  it "overrides loaded dependencies with mocked methdos on Jeeves" do
    Jeeves.stub(:loaded_dependency) { :stubbed_value }
    subject.call_integrated.should == :stubbed_value
  end

  it "uses loaded dependencies if they are not mocked on Jeeves" do
    subject.call_integrated.should == :real_value
  end
end


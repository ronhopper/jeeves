require "jeeves"

module JeevesTestApp
  module InnerScope
    class TestSubject
      extend Jeeves
      import :my_mock

      def call
        my_mock(42)
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
    expect { subject.call }.to raise_error(ArgumentError,
      "Dependency 'my_mock' was not found in JeevesTestApp::InnerScope")
  end
end


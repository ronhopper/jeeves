require "jeeves/resolve_constant"

module JeevesTestApp
  module ConstantTest
    MY_CONSTANT = "MY VALUE"
  end
end

module Jeeves
  describe ResolveConstant do

    it "returns an anonymous function which returns the constant" do
      delegator = ResolveConstant.call(JeevesTestApp::ConstantTest, :my_constant)
      delegator.call.should == "MY VALUE"
    end

    it "returns nil if the constant is not defined" do
      delegator = ResolveConstant.call(JeevesTestApp::ConstantTest, :undefined_constant)
      delegator.should be(nil)
    end

  end
end


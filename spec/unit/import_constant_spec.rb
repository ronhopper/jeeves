require "jeeves/import_constant"

module JeevesTestApp
  module ConstantTest
    MY_CONSTANT = "MY VALUE"
  end
end

module Jeeves
  describe ImportConstant do

    it "returns an anonymous function which returns the constant" do
      delegator = ImportConstant.call(:my_constant, JeevesTestApp::ConstantTest)
      delegator.call.should == "MY VALUE"
    end

    it "returns nil if the constant is not defined" do
      delegator = ImportConstant.call(:undefined_constant, JeevesTestApp::ConstantTest)
      delegator.should be(nil)
    end

  end
end


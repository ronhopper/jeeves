require "jeeves/import_constant"

module JeevesTestApp
  module ConstantTest
    MY_CONSTANT = "MY VALUE"
  end
end

module Jeeves
  describe ImportConstant do

    it "returns an anonymous function which returns the constant" do
      callable = ImportConstant.call(:my_constant, JeevesTestApp::ConstantTest)
      callable.call.should == "MY VALUE"
    end

    it "returns nil if the constant is not defined" do
      callable = ImportConstant.call(:undefined_constant, JeevesTestApp::ConstantTest)
      callable.should be(nil)
    end

  end
end


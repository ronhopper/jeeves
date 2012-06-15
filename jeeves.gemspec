# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "jeeves/version"

Gem::Specification.new do |s|
  s.name         = "jeeves"
  s.version      = Jeeves::VERSION
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Ron Hopper"]
  s.email        = ["rchopper@gmail.com"]
  s.homepage     = "http://github.com/ronhopper/jeeves"
  s.summary      = "Jeeves is a dependency management library for Ruby."
  s.files        = Dir.glob("{lib,spec}/**/*")
  s.test_files   = Dir.glob("spec/**/*")
  s.require_path = "lib"

  s.add_development_dependency "rspec", "~> 2.8"
end


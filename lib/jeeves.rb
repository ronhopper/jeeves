module Jeeves
  autoload :ResolveDependency, "jeeves/resolve_dependency"
  autoload :ResolveMethod,     "jeeves/resolve_method"
  autoload :ResolveCallable,   "jeeves/resolve_callable"
  autoload :ResolveConstant,   "jeeves/resolve_constant"

  def import(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    scope = options.fetch(:from) do
      module_names = ancestors.first.to_s.split('::')[0..-2]
      module_names.inject(Object) { |m, c| m.const_get(c) }
    end
    args.each do |name|
      if name.is_a?(Array)
        external_name, internal_name = *name
      else
        external_name = internal_name = name
      end
      if options[:lazy]
        self.class.send(:define_method, internal_name) do |*args, &block|
          delegator = ResolveDependency.call(scope, external_name)
          delegator.call(*args, &block)
        end
      else
        delegator = ResolveDependency.call(scope, external_name)
        self.class.send(:define_method, internal_name) do |*args, &block|
          delegator.call(*args, &block)
        end
      end
      define_method(internal_name) do |*args, &block|
        self.class.send(internal_name, *args, &block)
      end
    end
  end

  def const_missing(name)
    return super unless Jeeves.in_test_framework?
    Module.new do
      @name = [name]
      class << self
        def const_missing(name)
          @name << name
          self
        end
        def to_s
          @name.join("::")
        end
      end
    end
  end

  def self.in_test_framework?
    defined?(RSpec) || defined?(Test::Unit)
  end
end


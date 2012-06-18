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
        define_method(internal_name) do |*args, &block|
          delegator = ResolveDependency.call(scope, external_name)
          delegator.call(*args, &block)
        end
      else
        delegator = ResolveDependency.call(scope, external_name)
        define_method(internal_name) do |*args, &block|
          delegator.call(*args, &block)
        end
      end
    end
  end
end


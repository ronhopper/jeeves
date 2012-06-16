module Jeeves
  autoload :ResolveDependency, "jeeves/resolve_dependency"
  autoload :ImportMethod,      "jeeves/import_method"
  autoload :ImportCallable,    "jeeves/import_callable"
  autoload :ImportConstant,    "jeeves/import_constant"
  autoload :ImportMock,        "jeeves/import_mock"

  def import(*args)
    options = args.last.respond_to?(:fetch) ? args.pop : {}
    scope = options.fetch(:from) do
      module_names = ancestors.first.to_s.split('::')[0..-2]
      module_names.inject(Object) { |m, c| m.const_get(c) }
    end
    args.each do |name|
      if options[:lazy]
        define_method(name) do |*args, &block|
          delegator = ResolveDependency.call(scope, name)
          delegator.call(*args, &block)
        end
      else
        delegator = ResolveDependency.call(scope, name)
        define_method(name) do |*args, &block|
          delegator.call(*args, &block)
        end
      end
    end
  end
end


module Jeeves
  autoload :FindDependencies, "jeeves/find_dependencies"
  autoload :ImportMethod,     "jeeves/import_method"
  autoload :ImportCallable,   "jeeves/import_callable"
  autoload :ImportConstant,   "jeeves/import_constant"

  def import(*args)
    options = args.last.respond_to?(:fetch) ? args.pop : {}
    scope = options.fetch(:from) do
      module_names = ancestors.first.to_s.split('::')[0..-2]
      module_names.inject(Object) { |m, c| m.const_get(c) }
    end
    FindDependencies.call(scope, *args).each do |name, delegator|
      define_method(name) do |*args, &block|
        delegator.call(*args, &block)
      end
    end
  end
end


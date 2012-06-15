module Jeeves
  autoload :FindDependencies, "jeeves/find_dependencies"
  autoload :ImportMethod,     "jeeves/import_method"
  autoload :ImportCallable,   "jeeves/import_callable"
  autoload :ImportConstant,   "jeeves/import_constant"

  def import(*args)
    FindDependencies.call(*args).each do |name, delegator|
      define_method(name) do |*args, &block|
        delegator.call(*args, &block)
      end
    end
  end
end


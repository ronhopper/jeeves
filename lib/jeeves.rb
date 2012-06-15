module Jeeves
  autoload :ImportMethod,   "jeeves/import_method"
  autoload :ImportCallable, "jeeves/import_callable"
  autoload :ImportConstant, "jeeves/import_constant"

  IMPORTERS = [ImportMethod, ImportCallable, ImportConstant]

  def import(name, options={})
    scope = options.fetch(:from)
    IMPORTERS.any? do |import|
      if callable = import.call(name, scope)
        define_method(name) { |*args, &block| callable.call(*args, &block) }
      end
    end
  end
end


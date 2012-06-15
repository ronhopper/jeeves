module Jeeves
  autoload :ImportMethod,   "jeeves/import_method"
  autoload :ImportCallable, "jeeves/import_callable"
  autoload :ImportConstant, "jeeves/import_constant"

  def import(name, options={})
    scope = options.fetch(:from)
    if not define_delegator(name, scope)
      raise ArgumentError, "Dependency '#{name}' was not found in #{scope}"
    end
  end

private

  IMPORTERS = [ImportMethod, ImportCallable, ImportConstant]

  def define_delegator(name, scope)
    callable = IMPORTERS.reduce(nil) { |c, i| c ||= i.call(name, scope) }
    if callable
      define_method(name) { |*args, &block| callable.call(*args, &block) }
    end
  end
end


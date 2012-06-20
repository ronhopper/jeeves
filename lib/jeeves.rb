module Jeeves
  autoload :Import,               "jeeves/import"
  autoload :ResolveDependency,    "jeeves/resolve_dependency"
  autoload :ResolveMethod,        "jeeves/resolve_method"
  autoload :ResolveCallable,      "jeeves/resolve_callable"
  autoload :ResolveConstant,      "jeeves/resolve_constant"
  autoload :DefineImportedMethod, "jeeves/define_imported_method"
  autoload :StubScope,            "jeeves/stub_scope"

  def import(*args)
    Import.new.call(self, *args)
  end

  def const_missing(name)
    if Jeeves.in_test_framework?
      StubScope.call(name)
    else
      super
    end
  end

  def self.in_test_framework?
    defined?(RSpec) || defined?(Test::Unit)
  end
end


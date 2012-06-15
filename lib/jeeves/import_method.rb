module Jeeves
  class ImportMethod
    def self.call(name, scope)
      if scope.respond_to?(name)
        scope.method(name)
      end
    end
  end
end


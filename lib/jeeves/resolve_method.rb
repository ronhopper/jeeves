module Jeeves
  class ResolveMethod
    def self.call(scope, name)
      if scope.respond_to?(name)
        scope.method(name)
      end
    end
  end
end


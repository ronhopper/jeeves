module Jeeves
  class ResolveConstant
    def self.call(scope, name)
      const_name = name.upcase
      if scope.const_defined?(const_name)
        const_value = scope.const_get(const_name)
        lambda { const_value }
      end
    end
  end
end


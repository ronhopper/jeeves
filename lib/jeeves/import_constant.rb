module Jeeves
  class ImportConstant
    def self.call(name, scope)
      const_name = name.upcase
      if scope.const_defined?(const_name)
        const_value = scope.const_get(const_name)
        lambda { const_value }
      end
    end
  end
end


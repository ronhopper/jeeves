module Jeeves
  class ResolveCallable
    def self.call(scope, name)
      class_name = camelize(name)
      if scope.const_defined?(class_name)
        scope.const_get(class_name).new
      end
    end

  private

    def self.camelize(s)
      s.to_s.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end
end


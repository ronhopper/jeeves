module Jeeves
  class ResolveMock
    def self.call(scope, name)
      if in_test_framework?
        lambda do |*args, &block|
          if Jeeves.respond_to?(name)
            Jeeves.public_send(name, *args, &block)
          else
            raise ArgumentError, "Dependency '#{name}' was not found in #{scope}"
          end
        end
      end
    end

  private

    def self.in_test_framework?
      defined?(RSpec) || defined?(Test::Unit)
    end
  end
end


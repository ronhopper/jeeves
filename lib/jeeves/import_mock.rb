module Jeeves
  class ImportMock
    def self.call(name, scope)
      if defined?(RSpec) || defined?(Test::Unit)
        lambda do |*args, &block|
          if Jeeves.respond_to?(name)
            Jeeves.public_send(name, *args, &block)
          else
            raise ArgumentError, "Dependency '#{name}' was not found in #{scope}"
          end
        end
      end
    end
  end
end


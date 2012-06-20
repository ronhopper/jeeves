module Jeeves
  class StubScope
    def self.call(name)
      Module.new do
        @name = [name]
        class << self
          def const_missing(name)
            @name << name
            self
          end
          def to_s
            @name.join("::")
          end
        end
      end
    end
  end
end


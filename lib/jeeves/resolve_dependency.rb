module Jeeves
  class ResolveDependency
    RESOLVERS = [ResolveMethod, ResolveCallable, ResolveConstant, ResolveMock]

    def self.call(scope, name)
      delegator = nil
      RESOLVERS.each do |resolver|
        break if delegator = resolver.call(scope, name)
      end
      delegator or raise ArgumentError, "Dependency '#{name}' was not found in #{scope}"
    end
  end
end


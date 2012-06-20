module Jeeves
  class UnresolvedDependency < StandardError
  end

  class ResolveDependency
    RESOLVERS = [ResolveMethod, ResolveCallable, ResolveConstant]

    def self.call(scope, name)
      delegator = nil
      RESOLVERS.each do |resolver|
        break if delegator = resolver.call(scope, name)
      end
      delegator = mock(delegator, scope, name) if Jeeves.in_test_framework?
      delegator or unresolved(scope, name)
    end

  private

    def self.mock(delegator, scope, name)
      lambda do |*args, &block|
        if Jeeves.respond_to?(name)
          Jeeves.send(name, *args, &block)
        elsif delegator
          delegator.call(*args, &block)
        else
          unresolved(scope, name)
        end
      end
    end

    def self.unresolved(scope, name)
      raise UnresolvedDependency, "Dependency '#{name}' was not found in #{scope}"
    end
  end
end


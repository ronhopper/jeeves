module Jeeves
  class FindDependencies
    def self.call(*args)
      options = args.pop
      scope = options.fetch(:from)
      args.inject({}) do |dependencies, name|
        dependencies.update(name => delegator_for(name, scope))
      end
    end

  private

    IMPORTERS = [ImportMethod, ImportCallable, ImportConstant]

    def self.delegator_for(name, scope)
      delegator = nil
      IMPORTERS.each do |importer|
        break if delegator = importer.call(name, scope)
      end
      delegator or raise ArgumentError, "Dependency '#{name}' was not found in #{scope}"
    end
  end
end


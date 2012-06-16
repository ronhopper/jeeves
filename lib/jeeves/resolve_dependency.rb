module Jeeves
  class ResolveDependency
    IMPORTERS = [ImportMethod, ImportCallable, ImportConstant, ImportMock]

    def self.call(scope, name)
      delegator = nil
      IMPORTERS.each do |importer|
        break if delegator = importer.call(name, scope)
      end
      delegator or raise ArgumentError, "Dependency '#{name}' was not found in #{scope}"
    end
  end
end


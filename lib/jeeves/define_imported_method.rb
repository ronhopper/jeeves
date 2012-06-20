module Jeeves
  class DefineImportedMethod
    def call(target, internal_name, options)
      @target = target
      @internal_name = internal_name
      @scope = options.fetch(:from)
      @external_name = options.fetch(:name)
      if options[:lazy] == true
        define_lazy
      elsif options[:lazy] == false
        define_non_lazy
      else
        define_smart
      end
      define_on_instance
    end

  private

    def define_lazy
      scope = @scope
      external_name = @external_name
      @target.class.send(:define_method, @internal_name) do |*args, &block|
        delegator = ResolveDependency.call(scope, external_name)
        delegator.call(*args, &block)
      end
    end

    def define_non_lazy
      delegator = ResolveDependency.call(@scope, @external_name)
      @target.class.send(:define_method, @internal_name) do |*args, &block|
        delegator.call(*args, &block)
      end
    end

    def define_smart
      scope = @scope
      internal_name = @internal_name
      external_name = @external_name
      @target.class.send(:define_method, @internal_name) do |*args, &block|
        delegator = ResolveDependency.call(scope, external_name)
        self.class.send(:define_method, internal_name) do |*args, &block|
          delegator.call(*args, &block)
        end
        delegator.call(*args, &block)
      end
    end

    def define_on_instance
      internal_name = @internal_name
      @target.send(:define_method, internal_name) do |*args, &block|
        self.class.send(internal_name, *args, &block)
      end
    end
  end
end

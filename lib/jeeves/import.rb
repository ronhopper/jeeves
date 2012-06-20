module Jeeves
  class Import
    def call(target, *args)
      @target = target
      parse_options(args)
      @names.each do |external_name, internal_name|
        DefineImportedMethod.new.call(target, internal_name, from: @scope,
                                      name: external_name, lazy: @lazy)
      end
    end

  private

    def parse_options(args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      @names = args.map { |name| name.is_a?(Array) ? name : [name, name] }
      @scope = options.fetch(:from) { default_scope }
      @lazy = options.fetch(:lazy, :smart)
    end

    def default_scope
      module_names = @target.ancestors.first.to_s.split('::')[0..-2]
      module_names.inject(Object) { |m, c| m.const_get(c) }
    end
  end
end


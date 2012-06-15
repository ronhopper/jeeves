module Jeeves

  def import(name, options={})
    namespace = options[:from]
    class_name = camelize(name)
    const_name = name.to_s.upcase
    if namespace.respond_to?(name)
      define_method(name) do |*args, &block|
        namespace.public_send(name, *args, &block)
      end
    elsif namespace.const_defined?(class_name)
      callable = namespace.const_get(class_name)
      if !callable.respond_to?(:call)
        callable = callable.new
      end
      define_method(name) do |*args, &block|
        callable.call(*args, &block)
      end
    elsif namespace.const_defined?(const_name)
      define_method(name) do
        namespace.const_get(const_name)
      end
    end
  end

private

  def camelize(s)
    s.to_s.gsub(/(?:^|_)(.)/) { $1.upcase }
  end

end


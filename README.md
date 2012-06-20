Jeeves
======

Jeeves is a personal valet for your Ruby code. It is used to manage
dependencies between loosely coupled classes via explicit declaraion.

It is _not_ a traditional dependency injection framework, although it can
easily fill that role.


Motivation
----------

Writing loosely-coupled code obeying the Single-Responsibility Principle often
leads to some headaches wiring dependencies together. There are a number of
ways to deal with this in Ruby, each with different trade-offs.

The goal of Jeeves is to:
  * declare dependencies explicity using simple syntax
  * resolve dependencies solely via naming conventions
  * simplify the mocking of dependencies in unit tests

### Explicit Declaration

Flexible code design is intimately connected with keeping dependencies under
control. In Ruby it is easy for implicit dependencies to get out of hand.
Jeeves uses explicit dependency declarations via Python-like import statements:
```ruby
import :my_dependency
```

The import declaration creates an instance method which delegates to the
external dependency. The dependency may be a static method, a class with a
`call` method or a constant.

With Jeeves, it is easy to program in a more functional style using classes
that define a single behavior. For example:
```ruby
module MyApp
  class InvoiceCustomers
    extend Jeeves

    import :customers, from: Repository
    import :generate_invoice, :email_invoice

    def call
      customers.each do |customer|
        invoice = generate_invoice(customer)
        email_invoice(invoice)
      end
    end

  end
end
```

### Resolution via Naming Convention

Instead of relying on a gnarly XML file to tie dependencies together, Jeeves
resolves an imported dependency by looking in a few places until it finds it.

First, it looks for a static method of the same name:
```ruby
module MyApp
  class Config
    def self.redis
      @redis ||= Redis.new(host: "localhost", port: 6379)
    end
  end

  class DoSomething
    extend Jeeves

    import :redis, from: Config

    def call
      redis.get("mykey")
    end
  end
end
```

Next, it looks for a class with the same name (CamelCased) and a `call` method:
```ruby
module MyApp
  class CalculateSomething
    def call(value)
      value**2 - value + 1.2
    end
  end

  class DoSomething
    extend Jeeves

    import :calculate_something

    def call(value)
      calculate_something(value)
    end
  end
end
```

Finally, it looks for a constant with the same name (UPCASED):
```ruby
module MyApp
  class CalculateArea
    extend Jeeves

    import :pi, from: Math

    def call(radius)
      pi * radius**2
    end
  end
end
```

### Simplified Mocking

During isolated unit testing, external constants and direct class
references cause annoyance because they must be redeclared.

For example, consider the RSpec unit test:
```ruby
require 'my_app/widget'

describe MyApp::Widget do
  it "does something with my external class" do
    MyApp::MyExternalClass.should_receive(:foo) { :bar }
    subject.do_something
  end
end
```

In order for this code to work, you have to either require `my_external_class`
or redefine it like so:
```ruby
require 'my_app/widget'

module MyApp
  class MyExternalClass
  end
end

describe MyApp::Widget do
  it "does something with my external class" do
    MyApp::MyExternalClass.stub(foo: "bar")
    subject.do_something.should == :bar
  end
end
```

Jeeves simplifies this by dynamically delegating all unresolvable dependencies
to the `Jeeves` module when used inside of RSpec or Test::Unit. With Jeeves,
the same unit test looks like so:

```ruby
require 'my_app/widget'

describe MyApp::Widget do
  it "does something with my external class" do
    Jeeves.stub(my_external_class: stub(foo: "bar"))
    subject.do_something.should == :bar
  end
end
```


Usage
-----

Extend your class with Jeeves and use the `import` method to declare external
dependencies, like so:

```ruby
module MyApp
  class Widget
    extend Jeeves

    import :my_dependency

    def do_something
      my_dependency.a_method_on_my_dependency
    end

  end
end
```

This will resolve the dependency during class definition, by looking for:
  * the method `MyApp.my_dependency`
  * a class method `MyApp::MyDependency.call`
  * an instance method `MyApp::MyDependency.new.call`
  * a constant `MyApp::MY_DEPENDENCY`
  * otherwise, it raises an `Jeeves::UnresolvedDependency` error

Multiple dependencies can be imported at once:
```ruby
import :first_dependency, :second_dependency, :third_dependency
```

Dependencies can be looked up in a specific scope, rather than the default
scope (the scope in which the current class lives):
```ruby
import :my_dependency, from: MyApp::SomeOtherModule
```

Dependencies can be aliased, so that the current class refers to the dependency
by its alias, rather than its actual external name:
```ruby
import [:my_dependency, :my_alias]
```

Dependencies can be declared lazy, so that resolution occurs each time the
method is called, rather than once during class definition:
```ruby
import :my_dependency, lazy: true
```

If you're feeling reckless, you can monkey-patch Jeeves into your project with
`Class.send(:include, Jeeves)` instead of writing `extend Jeeves` everywhere.


History
-------

### Edge
* Mock undefined dependency scope within RSpec or Test::Unit

### Version 0.2.1
* Import dependencies as class methods (rather than just instance methods)
* Raise Jeeves::UnresolvedDependency when a dependency is not found
* Mocked dependencies override real dependencies

### Version 0.2.0
* Import dependency as an alias
* Import callable classes (rather than just callable instances)
* Mockable dependencies within RSpec or Test::Unit
* Lazy dependency resolution

### Version 0.1.0
* Import defaults to current class's scope
* Import multiple dependencies in one call
* Raise ArgumentError when a dependency is not found

### Version 0.0.1
* Import a method, callable or constant from a specified scope


License
-------

Copyright (C) 2012 Ronald C. Hopper

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


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

Coming soon.

### Resolution via Naming Convention

Coming soon.

### Simplified Mocking

Coming soon.

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
  * otherwise, it raises an unresolved dependency error

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


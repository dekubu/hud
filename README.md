# Hud

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/hud`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hud'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hud

Absolutely! Here's a README documentation for the `Hud` module and its classes and methods:

---

# Hud

The `Hud` module provides a component-based rendering system integrated with the Rack framework.

## Table of Contents

- [Dependencies](#dependencies)
- [Classes and Modules](#classes-and-modules)
  - [Error](#error)
  - [Display](#display)
    - [Helpers](#helpers)
    - [Component](#component)

---

## Dependencies

- hud/version
- hud/db/entity.rb
- rack/app
- tilt
- ostruct
- tilt/erb
- rack/app/front_end

---

## Classes and Modules

### Error

A standard error class specific to `Hud`.

### Display

This class provides methods to handle the display of components.

#### Helpers

A module that provides helper methods for the display.

##### `display(name, locals: {})`

Displays a component by its name.

*Example*:

```ruby
# Assuming you have a User component defined
display(:user, locals: { name: 'Alice' })
```

#### Component

A base class for all components. Components are meant to represent parts of the UI that can be reused across different views.

##### `self.call(locals: {})`

Creates a new instance of a component with the given locals.

*Example*:

```ruby
UserComponent.call(locals: { name: 'Bob' })
```

##### `display(name, locals = {})`

Displays a partial component by its name.

*Example*:

```ruby
# Inside a component's view
<%= display(:profile_picture, locals: { url: 'path/to/pic.jpg' }) %>
```

##### `to_s`

Renders the component as a string. It looks for the component's template and renders it. If the template is not found, it prompts to create a view for the component.

*Example*:

```ruby
user_component = UserComponent.new(locals: { name: 'Charlie' })
puts user_component
```

---

## Getting Started

1. Define your components by extending `Hud::Display::Component`.
2. Create a corresponding `.html.erb` template for each component inside a `components` directory.
3. Use the `display` method to render components within other components or views.

---

Note: This README assumes that you have a basic understanding of Ruby and the Rack framework. Ensure that you set up your project structure correctly, especially the `components` directory for templates.

---


Remember to include necessary libraries like `SecureRandom`, `DateTime`, `SDBM`, and `MessagePack` in your project. Ensure that the `User` class (used in the examples) is defined with appropriate attributes for the examples to work.
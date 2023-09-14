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

# Hud::DB::Entity

The `Hud::DB::Entity` class provides functionalities for entities with serialization, querying, associations, and a dynamic repository for CRUD operations using the `SDBM` database.

## Table of Contents

- [Attributes](#attributes)
- [Class Methods](#class-methods)
- [Instance Methods](#instance-methods)
- [Dynamic Repository Creation](#dynamic-repository-creation)
  - [Repository Methods](#repository-methods)

---

## Attributes

- **uid**: A unique identifier for the entity.
- **created_at**: Timestamp when the entity was created.
- **last_updated_at**: Timestamp when the entity was last updated.

## Class Methods

### `queries(&block)`

Allows you to define query methods for the entity.

```ruby
class User < Hud::DB::Entity
  queries do
    def find_by_name(name)
      all.select { |user| user.name == name }
    end
  end
end
```

### `associations(repository, &block)`

Defines association methods for the entity.

```ruby
class Post < Hud::DB::Entity
  associations(User::Repository) do
    def author
      User::Repository.get(author_id)
    end
  end
end
```

### `from_hash(uid, data_hash)`

Creates an entity instance from a given hash.

```ruby
user_hash = { name: 'Alice', age: 30 }
user = User.from_hash('12345', user_hash)
```

## Instance Methods

### `to_hash`

Converts the entity object into a hash representation.

```ruby
user = User.new
user.name = 'Alice'
user.age = 30
user_hash = user.to_hash
```

## Dynamic Repository Creation

If the `Repository` constant is accessed and it's missing, a new repository class is dynamically created for the entity.

### Repository Methods

#### `add(entity)`

Adds a new entity to the repository.

```ruby
user = User.new
user.name = 'Alice'
uid = User::Repository.add(user)
```

#### `update(entity)`

Updates an existing entity in the repository.

```ruby
user = User::Repository.get('12345')
user.name = 'Bob'
User::Repository.update(user)
```

#### `delete(entity)`

Deletes an entity from the repository.

```ruby
user = User::Repository.get('12345')
User::Repository.delete(user)
```

#### `reset!`

Deletes all entities from the repository.

```ruby
User::Repository.reset!
```

#### `get(uid)`

Retrieves an entity from the repository using its UID.

```ruby
user = User::Repository.get('12345')
```

#### `count`

Returns the count of all entities in the repository.

```ruby
total_users = User::Repository.count
```

#### `all`

Returns all entities from the repository.

```ruby
users = User::Repository.all
```

---

Remember to include necessary libraries like `SecureRandom`, `DateTime`, `SDBM`, and `MessagePack` in your project. Ensure that the `User` class (used in the examples) is defined with appropriate attributes for the examples to work.
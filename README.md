# Rails Templater

This is a template which allows creating new Ruby on Rails 3 applications quickly using some opinionated defaults. It is inspired by ffmike's [BigOldRailsTemplate](http://github.com/ffmike/BigOldRailsTemplate) Rails 2 template project. To use templater with your Rails apps, use the -m switch when creating your application:

After cloning the rails-templater to your hard drive, you can generate a new app like so:

If you want to use Active Record with MySql:
    rails new application_name -T -m /path/to/rails-templater/templater.rb

## Generated Application

Rails Templater will generate the following:

### Ruby on Rails

* Uses [Haml](http://haml-lang.com) as the template engine
* Uses [Sass](http://sass-lang.com) for generating CSS

## Database

* Uses Active Record as the default ORM

## Testing

* [RSpec](http://github.com/rspec/rspec) for testing
* [factory_girl](http://github.com/thoughtbot/factory_girl) for fixture replacement
* [shoulda](https://github.com/thoughtbot/shoulda) for ActiveModel RSpec matchers
* [fracture](https://github.com/nigelr/fracture) for unified view/controller specs
* [timecop](https://github.com/travisjeffery/timecop) for testing time dependant code

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Send me a pull request. Bonus points for topic branches.

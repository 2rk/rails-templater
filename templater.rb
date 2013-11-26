#Create Gemspec
create_file ".rvmrc", "rvm use 2.0.0-p247@#{app_name} --create"
copy_file  ".rvmrc", ".rvmrc.example"

# Delete all unnecessary files
remove_file "README"
remove_file "public/index.html"
remove_file "public/robots.txt"
remove_file "public/images/rails.png"
remove_file "config/database.yml"

create_file 'README'
create_file 'log/.gitkeep'
create_file 'tmp/.gitkeep'

# db stuffs
create_file "config/database.yml", <<EOF
# MySQL.  Versions 4.1 and 5.0 are recommended.
#
# Install the MYSQL driver
#   gem install mysql2
#
# Ensure the MySQL gem is defined in your Gemfile
#   gem 'mysql2'
#
# And be sure to use new-style password hashing:
#   http://dev.mysql.com/doc/refman/5.0/en/old-client.html
development:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: #{app_name}_development
  pool: 5
  username: root
  password:
  socket: /tmp/mysql.sock

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: #{app_name}_test
  pool: 5
  username: root
  password:
  socket: /tmp/mysql.sock

production:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: #{app_name}_production
  pool: 5
  username: root
  password:
  socket: /tmp/mysql.sock
EOF

copy_file  ".config/database.yml", ".config/database.yml.example"

git :init

## GEMFILE STUFF
gem 'haml-rails'
gem 'mysql2'

gem_group :development, :test do
  gem 'awesome_print'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'fracture'
  gem 'database_cleaner'
  gem 'hirb'
  gem 'rspec-rails'
  gem 'shoulda-matchers', '~> 2.4.0'
  gem 'timecop'
end

inside app_name do
  run 'bundle install'
end

inside app_name do
  run 'rake db:create:all'
end

# load new scaffold controller
create_file 'lib/templates/rails/scaffold_controller/controller.rb', <<EOF
<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"
<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController

  def index
    @<%= plural_table_name %> = <%= orm_class.all(class_name) %>
  end

  def show
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
  end

  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
  end

  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "params[:\#{singular_table_name}]") %>

    if @<%= orm_instance.save %>
      redirect_to <%= singular_table_name %>_path(@<%= singular_table_name %>), <%= key_value :notice, "'\#{human_name} was successfully created.'" %>
    else
      render <%= key_value :action, "'new'" %>
    end
  end

  def edit
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
  end

  def update
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>

    if @<%= orm_instance.update_attributes("params[:\#{singular_table_name}]") %>
          redirect_to <%= singular_table_name %>_path(@<%= singular_table_name %>), <%= key_value :notice, "'\#{human_name} was successfully updated.'" %>
    else
      render <%= key_value :action, "'edit'" %>
    end
   end

  def destroy
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
      @<%= orm_instance.destroy %>

      redirect_to <%= index_helper %>_path
  end
end
<% end -%>
EOF

## RSpec all the things

generate 'rspec:install'
spec_helper_path = 'spec/spec_helper.rb'
run 'mkdir spec/support'
run 'touch spec/support/common_lets.rb'
create_file 'spec/support/assign_to_matcher.rb', <<EOF
require 'active_support/deprecation'

module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:
                            # Ensures that the controller assigned to the named instance variable.
                            #
                            # Options:
                            # * <tt>with_kind_of</tt> - The expected class of the instance variable
                            #   being checked.
                            # * <tt>with</tt> - The value that should be assigned.
                            #
                            # Example:
                            #
                            #   it { should assign_to(:user) }
                            #   it { should_not assign_to(:user) }
                            #   it { should assign_to(:user).with_kind_of(User) }
                            #   it { should assign_to(:user).with(@user) }
      def assign_to(variable)
        AssignToMatcher.new(variable)
      end

      class AssignToMatcher # :nodoc:
        attr_reader :failure_message_for_should, :failure_message_for_should_not

        def initialize(variable)
          #ActiveSupport::Deprecation.warn 'The assign_to matcher is deprecated and will be removed in 2.0'
          @options = {}
          @variable    = variable_and_attribute_split(variable)
          @options[:check_value] = false
        end

        def variable_and_attribute_split variable
          variables = variable.to_s.split('.', 2)
          if variables.length == 2
            @options[:expected_attribute] = variables.last
            @options[:expected_attribute_check] = true
          end

          variables.first
        end

        def with_kind_of(expected_class)
          @options[:expected_class] = expected_class
          self
        end

        #def with_attribute(expected_attribute)
        #  @options[:expected_attribute] = expected_attribute
        #  self
        #end
        #
        #def and_value(expected_attribute_value)
        #  @options[:expected_attribute_value] = expected_attribute_value
        #  self
        #end

        def with(expected_value = nil, &block)
          @options[:check_value] = true
          @options[:expected_value] = expected_value
          @options[:expectation_block] = block
          self
        end

        def with_items(*expected_value)
          @options[:check_value_items] = true
          @options[:expected_value] = expected_value.flatten
          \#@options[:expectation_block] = block
          self
        end

        def matches?(controller)
          @controller = controller
          normalize_expected_value!
          assigned_value? &&
              kind_of_expected_class? &&
              equal_to_expected_value? #&&
                                       #with_attribute_and_name?
        end

        def description
          description = "assign @\#{@variable}"
          if @options.key?(:expected_class)
            description << " with a kind of \#{@options[:expected_class]}"
          end
          description
        end

        def in_context(context)
          @context = context
          self
        end

        private

        #def with_attribute_and_name?
        #  if @options.key?(:expected_attribute)
        #    if assigned_value.respond_to?(@options[:expected_attribute])
        #      if assigned_value.send(@options[:expected_attribute]) == @options[:expected_attribute_value]
        #        true
        #      else
        #        @failure_message_for_should =
        #            "Expected attribute of \#@variable.\#{@options[:expected_attribute]} to have a value of '\#{@options[:expected_attribute_value]}'"
        #        false
        #      end
        #    else
        #      @failure_message_for_should =
        #          "Expected \#@variable to have an attribute of .\#{@options[:expected_attribute]}"
        #      false
        #    end
        #  else
        #    true
        #  end
        #end

        def assigned_value?
          if @controller.instance_variables.map(&:to_s).include?("@\#{@variable}")
            @failure_message_for_should_not =
                "Didn't expect action to assign a value for @\#{@variable}, " <<
                    "but it was assigned to \#{assigned_value.inspect}"
            true
          else
            @failure_message_for_should =
                "Expected action to assign a value for @\#{@variable}"
            false
          end
        end

        def kind_of_expected_class?
          if @options.key?(:expected_class)
            if assigned_value.kind_of?(@options[:expected_class])
              @failure_message_for_should_not =
                  "Didn't expect action to assign a kind of \#{@options[:expected_class]} " <<
                      "for \#{@variable}, but got one anyway"
              true
            else
              @failure_message_for_should =
                  "Expected action to assign a kind of \#{@options[:expected_class]} " <<
                      "for \#{@variable}, but got \#{assigned_value.inspect} " <<
                      "(\#{assigned_value.class.name})"
              false
            end
          else
            true
          end
        end

        def equal_to_expected_value?
          if @options[:expected_attribute_check]
            #if @options.key?(:expected_attribute)
            if assigned_value.respond_to?(@options[:expected_attribute])
              if assigned_value.send(@options[:expected_attribute]) == @options[:expected_value]
                true
              else
                @failure_message_for_should =
                    "Expected attribute of \#@variable.\#{@options[:expected_attribute]} to have a value of '\#{@options[:expected_value]}'"
                false
              end
            else
              @failure_message_for_should =
                  "Expected \#@variable to have an attribute of .\#{@options[:expected_attribute]}"
              false
            end
            #else
            #  true
            #end
          else
            if @options[:check_value]
              if @options[:expected_value] == assigned_value
                @failure_message_for_should_not =
                    "Didn't expect action to assign \#{@options[:expected_value].inspect} " <<
                        "for \#{@variable}, but got it anyway"
                true
              else
                @failure_message_for_should =
                    "Expected action to assign \#{@options[:expected_value].inspect} " <<
                        "for \#{@variable}, but got \#{assigned_value.inspect}"
                false
              end
            else
              if @options[:check_value_items]
                if @options[:expected_value].sort == assigned_value.sort
                  @failure_message_for_should_not =
                      "Didn't expect action to assign \#{@options[:expected_value].sort.inspect} " <<
                          "for \#{@variable}, but got it anyway"
                  true
                else
                  @failure_message_for_should =
                      "Expected action to assign \#{@options[:expected_value].sort.inspect} " <<
                          "for \#{@variable}, but got \#{assigned_value.sort.inspect}"
                  false
                end
              else
                true
              end

            end
          end
        end

        def normalize_expected_value!
          if @options[:expectation_block]
            @options[:expected_value] = @context.instance_eval(&@options[:expectation_block])
          end
        end

        def assigned_value
          @controller.instance_variable_get("@\#{@variable}")
        end
      end
    end
  end
end
EOF



# load rspec templates
create_file 'lib/templates/rspec/helper/helper_spec.rb', <<EOF
require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the <%= class_name %>Helper. For example:
#
# describe <%= class_name %>Helper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
<% module_namespacing do -%>
describe <%= class_name %>Helper do

end
<% end -%>
EOF
create_file 'lib/templates/rspec/integration/request.rb', <<EOF
require 'spec_helper'

describe "<%= class_name.pluralize %>" do
end
EOF

create_file 'lib/templates/rspec/model/model_spec.rb', <<EOF
require 'spec_helper'

<% module_namespacing do -%>
describe <%= class_name %> do
end
<% end -%>
EOF

create_file 'lib/templates/rspec/scaffold/controller_spec.rb', <<EOF
require 'spec_helper'

<% module_namespacing do -%>
describe <%= controller_class_name %>Controller do
  render_views
  common_lets

  before :all do
    Fracture.define_selector :new_<%= file_name %>_link
    Fracture.define_selector :cancel_new_<%= file_name %>_link
    Fracture.define_selector :edit_<%= file_name %>_link
    Fracture.define_selector :cancel_edit_<%= file_name %>_link
  end

  context 'not logged in' do
    before { sign_out user }

    {index: :get, show: :get, new: :get, create: :post, edit: :get, update: :put, destroy: :delete}.each do |v, m|
      it "\#{m} \#{v} should logout" do
        self.send(m, v, id: <%= file_name %>)
        should redirect_to new_user_session_path
      end
    end
  end

  context 'logged in as user' do
    before { sign_in user }

<% unless options[:singleton] -%>
    describe 'GET index' do
      before do
        <%= file_name %>
        <%= file_name %>_other
        get :index
      end

      it { should assign_to(:<%= table_name %>).with([<%= file_name %>]) }
      it { should render_template :index }
      it { should have_only_fractures(:new_<%= file_name %>_link) }
    end

<% end -%>
    describe 'GET show' do
      before { get :show, id: <%= file_name %> }

      it { should assign_to(:<%= file_name %>).with(<%= file_name %>) }
      it { should render_template :show }
      it { should have_only_fractures(:edit_<%= file_name %>_link) }
    end

    describe 'GET new' do
      before { get :new }

      it { should assign_to(:<%= file_name %>).with_kind_of(<%= class_name %>) }
      #it { should assign_to('<%= file_name %>.parent').with(parent) }
      it { should render_template :new }
      it { should have_only_fractures :cancel_new_<%= file_name %>_link }
      it { should have_a_form.that_is_new.with_path_of(<%= table_name %>_path)}
    end

    describe 'POST create' do
      context 'valid' do
        before do
          <%= class_name %>.any_instance.stub(:valid?).and_return(true)
          post :create
        end

        it { should redirect_to <%= file_name %>_path(<%= class_name %>.last) }
        it { should assign_to(:<%= file_name %>).with(<%= class_name %>.last) }
        #it { should assign_to('<%= file_name %>.parent').with(parent) }
      end

      context 'invalid' do
        before do
          <%= class_name %>.any_instance.stub(:valid?).and_return(false)
          post :create
        end

        it { should assign_to(:<%= file_name %>).with_kind_of(<%= class_name %>) }
        #it { should assign_to('<%= file_name %>.parent').with(parent) }
        it { should render_template :new }
        it { should have_only_fractures :cancel_new_<%= file_name %>_link }
        it { should have_a_form.that_is_new.with_path_of(<%= table_name %>_path)}
      end
    end

    describe 'GET edit' do
      before { get :edit, id: <%= file_name %> }

      it { should assign_to(:<%= file_name %>).with(<%= file_name %>) }
      it { should render_template :edit }
      it { should have_only_fractures :cancel_edit_<%= file_name %>_link }
      it { should have_a_form.that_is_edit.with_path_of(<%= file_name %>_path) }
    end

    describe 'PUT update' do
      context 'valid' do
        before do
          <%= class_name %>.any_instance.stub(:valid?).and_return(true)
          put :update, id: <%= file_name %>
        end

        it { should assign_to(:<%= file_name %>).with(<%= file_name %>) }
        it { should redirect_to <%= file_name %>_path(<%= file_name %>) }
      end
      context 'invalid' do
        before do
          <%= file_name %>
          <%= class_name %>.any_instance.stub(:valid?).and_return(false)
          put :update, id: <%= file_name %>
        end

        it { should assign_to(:<%= file_name %>).with(<%= file_name %>) }
        it { should render_template :edit }
        it { should have_only_fractures :cancel_edit_<%= file_name %>_link }
        it { should have_a_form.that_is_edit.with_path_of(<%= file_name %>_path) }
      end
    end

    describe 'DELETE destroy' do
      before { delete :destroy, id: <%= file_name %> }

      it { expect(<%= class_name %>.find_by_id(<%= file_name %>.id)).to be_nil }
      it { should redirect_to <%= index_helper %>_path }
    end
  end
end
<% end -%>
EOF
create_file 'lib/templates/rspec/scaffold/routing_spec.rb', <<EOF
require 'spec_helper'

<% module_namespacing do -%>
describe <%= controller_class_name %>Controller do
  describe 'routing' do

<% unless options[:singleton] -%>
    it('routes to #index') { get('/<%= ns_table_name %>').should route_to('<%= ns_table_name %>#index') }
<% end -%>
    it('routes to #new') { get('/<%= ns_table_name %>/new').should route_to('<%= ns_table_name %>#new') }
    it('routes to #show') { get('/<%= ns_table_name %>/1').should route_to('<%= ns_table_name %>#show', id: '1') }
    it('routes to #edit') { get('/<%= ns_table_name %>/1/edit').should route_to('<%= ns_table_name %>#edit', id: '1') }
    it('routes to #create') { post('/<%= ns_table_name %>').should route_to('<%= ns_table_name %>#create') }
    it('routes to #update') { put('/<%= ns_table_name %>/1').should route_to('<%= ns_table_name %>#update', id: '1') }
    it('routes to #destroy') { delete('/<%= ns_table_name %>/1').should route_to('<%= ns_table_name %>#destroy', id: '1') }
  end
end
<% end -%>
EOF

## END RSpec

## Haml all the things
remove_file 'app/views/layouts/application.html.erb'
create_file 'app/views/layouts/application.html.haml', <<EOF
!!! 5
%html
%head
  = csrf_meta_tag
  /[if lt IE 9]
    = javascript_include_tag 'html5'
%body
  = yield
  = javascript_include_tag :defaults
EOF
create_file 'lib/templates/haml/scaffold/_form.html.haml', <<EOF
  = form_for @<%= singular_table_name %> do |f|
    - if @<%= singular_table_name %>.errors.any?
      #error_explanation
        %h2= "\#{pluralize(@<%= singular_table_name %>.errors.count, 'error')} prohibited this <%= singular_table_name %> from being saved:"
        %ul
          - @<%= singular_table_name %>.errors.full_messages.each do |msg|
            %li= msg

    <% for attribute in attributes -%>
      .field
        = f.label :<%= attribute.name %>
        = f.<%= attribute.field_type %> :<%= attribute.name %>
    <% end -%>
      .actions
        = f.submit 'Save'
EOF

create_file 'lib/templates/haml/scaffold/edit.html.haml', <<EOF
%h1 Editing <%= singular_table_name %>

= render 'form'
= link_to 'Cancel', <%= singular_table_name %>_path(@<%= singular_table_name %>), id: :cancel_edit_<%= singular_table_name %>_link
EOF


create_file 'lib/templates/haml/scaffold/index.html.haml', <<EOF
%h1 Listing <%= plural_table_name %>
%table
  %tr
<% for attribute in attributes -%>
    %th <%= attribute.human_name %>
<% end -%>

  - @<%= plural_table_name %>.each do |<%= singular_table_name %>|
    %tr
<% @first = true -%>
<% for attribute in attributes -%>
<% if @first -%>
<% @first = false -%>
      %td= link_to <%= singular_table_name %>.<%= attribute.name %>, <%= singular_table_name %>_path(<%= singular_table_name %>)
<% else -%>
      %td= <%= singular_table_name %>.<%= attribute.name %>
<% end -%>
<% end -%>

%br

= link_to 'New <%= human_name %>', new_<%= singular_table_name %>_path, id: :new_<%= singular_table_name %>_link
EOF
create_file 'lib/templates/haml/scaffold/new.html.haml', <<EOF
%h1 New <%= singular_table_name %>

= render 'form'
= link_to 'Cancel', <%= index_helper %>_path, id: :cancel_new_<%= singular_table_name %>_link
EOF
create_file 'lib/templates/haml/scaffold/show.html.haml', <<EOF
%p#notice= notice

<% for attribute in attributes -%>
  %p
    %b <%= attribute.human_name %>:
    = @<%= singular_table_name %>.<%= attribute.name %>
<% end -%>
= link_to 'Edit', edit_<%= singular_table_name %>_path(@<%= singular_table_name %>), id: :edit_<%= singular_table_name %>_link
EOF


initializer 'haml.rb',<<EOF
Haml::Template.options[:format] = :html5
EOF

# END haml


# Start Fracture
append_file 'config/boot.rb', <<EOF
  ENV["FIXTURES_PATH"] ||= 'spec/fixtures'
EOF
# END Fracture

# Start .gitignore
append_file '.gitignore', <<EOF
.ackrc
.rvmrc
config/database.yml
public/cache/
public/stylesheets/compiled/
public/system/*
tmp/restart.txt
.idea
/.bundle
.powrc

# Ignore the default SQLite database.
/db/*.sqlite3

# Ignore all logfiles and tempfiles.
/log/*.log
/tmp
EOF
# End .gitignore

## Gem specific Injections

inject_into_file 'spec/spec_helper.rb', "\n\s\sconfig.include Capybara::DSL\n", after: "RSpec.configure do |config|\n"
inject_into_file 'spec/spec_helper.rb', "\n\s\sconfig.include FactoryGirl::Syntax::Methods\n", after: "RSpec.configure do |config|\n"

generators_configuration = <<-END
config.generators do |g|
      g.view_specs false
    end
END

environment generators_configuration

git :add => "."
git :commit => "-m 'Initial commit'"  
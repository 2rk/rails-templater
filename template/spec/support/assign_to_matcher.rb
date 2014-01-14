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
          #@options[:expectation_block] = block
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
          description = "assign @#{@variable}"
          if @options.key?(:expected_class)
            description << " with a kind of #{@options[:expected_class]}"
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
        #            "Expected attribute of #@variable.#{@options[:expected_attribute]} to have a value of '#{@options[:expected_attribute_value]}'"
        #        false
        #      end
        #    else
        #      @failure_message_for_should =
        #          "Expected #@variable to have an attribute of .#{@options[:expected_attribute]}"
        #      false
        #    end
        #  else
        #    true
        #  end
        #end

        def assigned_value?
          if @controller.instance_variables.map(&:to_s).include?("@#{@variable}")
            @failure_message_for_should_not =
                "Didn't expect action to assign a value for @#{@variable}, " <<
                    "but it was assigned to #{assigned_value.inspect}"
            true
          else
            @failure_message_for_should =
                "Expected action to assign a value for @#{@variable}"
            false
          end
        end

        def kind_of_expected_class?
          if @options.key?(:expected_class)
            if assigned_value.kind_of?(@options[:expected_class])
              @failure_message_for_should_not =
                  "Didn't expect action to assign a kind of #{@options[:expected_class]} " <<
                      "for #{@variable}, but got one anyway"
              true
            else
              @failure_message_for_should =
                  "Expected action to assign a kind of #{@options[:expected_class]} " <<
                      "for #{@variable}, but got #{assigned_value.inspect} " <<
                      "(#{assigned_value.class.name})"
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
                    "Expected attribute of #@variable.#{@options[:expected_attribute]} to have a value of '#{@options[:expected_value]}'"
                false
              end
            else
              @failure_message_for_should =
                  "Expected #@variable to have an attribute of .#{@options[:expected_attribute]}"
              false
            end
            #else
            #  true
            #end
          else
            if @options[:check_value]
              if @options[:expected_value] == assigned_value
                @failure_message_for_should_not =
                    "Didn't expect action to assign #{@options[:expected_value].inspect} " <<
                        "for #{@variable}, but got it anyway"
                true
              else
                @failure_message_for_should =
                    "Expected action to assign #{@options[:expected_value].inspect} " <<
                        "for #{@variable}, but got #{assigned_value.inspect}"
                false
              end
            else
              if @options[:check_value_items]
                if @options[:expected_value].sort == assigned_value.sort
                  @failure_message_for_should_not =
                      "Didn't expect action to assign #{@options[:expected_value].sort.inspect} " <<
                          "for #{@variable}, but got it anyway"
                  true
                else
                  @failure_message_for_should =
                      "Expected action to assign #{@options[:expected_value].sort.inspect} " <<
                          "for #{@variable}, but got #{assigned_value.sort.inspect}"
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
          @controller.instance_variable_get("@#{@variable}")
        end
      end
    end
  end
end
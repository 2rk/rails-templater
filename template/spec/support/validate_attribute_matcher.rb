require 'rspec/expectations'

# Validate an attribute on a model (or object with ActiveModel::Validations)
#
# This provides an easy way to prove that a given value is valid on an attribute or not,
# supporting any kind of validation. It checks for errors on that attribute, so it requires
# all validations on that field to pass for should, or any single validation to fail for
# a should_not
#
# Example
#   it { should validate_attribute(:name).with("Fred") }
#
#   it { should_not validate_attribute(:foo).with_nil }
#

RSpec::Matchers.define :validate_attribute do |attribute|
  @attribute = attribute
  @value = nil
  @value_set = false

  match do |subject|
    subject.__send__("#{@attribute}=".to_sym, @value) if @value_set
    subject.valid?
    !subject.errors.include?(@attribute)
  end

  chain(:with) { |value| @value = value; @value_set = true }
  chain(:with_nil) { @value = nil; @value_set = true }

  failure_message_for_should { |actual| "expected that .#{@attribute} = #{@value} would be valid" }
  failure_message_for_should_not { |actual| "expected that .#{@attribute} = #{@value} would not be valid" }
end

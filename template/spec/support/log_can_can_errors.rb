# This module is for using as a subclass on CanCan::ControllerResource so that errors raised during
# loading / authorizing can be reported during testing to help diagnose which resource raised the error.
module LogCanCanErrors
  mattr_accessor :log_errors
  mattr_accessor :already_included

  # If you want Can Can load/authorize errors to be printed out to help you figure out which resource is giving
  # an error, do this in your controller spec:
  #
  #   before { log_can_can_errors }
  #
  # Note that once the logging is on, it will stay on for all future tests until you turn it off with:
  #
  #   after { log_can_can_errors(false) }
  #
  # or similar.
  def log_can_can_errors(on=true)
    LogCanCanErrors.log_errors = on
    unless already_included
      already_included = true
      CanCan::ControllerResource.class_eval do
        prepend ::LogCanCanErrors::ControllerResourcePatches
      end
    end
  end

  module ControllerResourcePatches #:nodoc:
    def load_resource #:nodoc:
      begin
        super
      rescue StandardError => ex
        puts "Loading resource '#{@name}' failed with error: #{ex.inspect}" if LogCanCanErrors.log_errors
        raise
      end
    end

    def authorize_resource #:nodoc:
      begin
        super
      rescue StandardError => ex
        puts "Authorizing resource '#{@name}' failed with error: #{ex.inspect}" if LogCanCanErrors.log_errors
        raise
      end
    end
  end
end

LogCanCanErrors.log_errors = false

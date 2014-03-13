module AccessDenied
  class MissingException < StandardError; end

  # This method invokes to block passed through and adds an expectation that the block
  # failed with a CanCan::AccessDenied or an ActiveRecord::RecordNotFound (which occurs
  # when loading through an invalid combination)
  #
  # example:
  #           context "GET index" do
  #             it { expects_access_denied { get :index } }
  #           end
  #
  def expects_access_denied(&block)
    begin
      block.call

      # the block ran with no errors, raise this exception and fail the test
      raise MissingException, "Expected an error, but none was raised"

    rescue CanCan::AccessDenied, ActiveRecord::RecordNotFound => e
      # run an expectation. This will always pass, but we want rspec to see the
      # expectation as having passed.
      expect([CanCan::AccessDenied, ActiveRecord::RecordNotFound]).to include(e.class)
    rescue
      # pass all other exceptions up to rspec
      raise
    end
  end
end

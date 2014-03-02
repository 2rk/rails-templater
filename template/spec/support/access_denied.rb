module AccessDenied
  def expect_access_denied(&block)
    begin
      block.call
      raise "Expected an error, but none was raised"
    rescue StandardError => e
      expect([CanCan::AccessDenied, ActiveRecord::RecordNotFound]).to include(e.class)
    end
  end
end

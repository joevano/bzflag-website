require File.dirname(__FILE__) + '/../test_helper'
require 'bzflag_controller'

# Re-raise errors caught by the controller.
class BzflagController; def rescue_action(e) raise e end; end

class BzflagControllerTest < Test::Unit::TestCase
  def setup
    @controller = BzflagController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :initial_variable
  private
  def initial_variable
  	@remote_user = 'guodongj'
  	@active_tab = 'asinSelection'
  end
end

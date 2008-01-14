class MailingListController < ApplicationController
  before_filter :authorize

  def method_missing(action)
    if action == "index"
      action = "threads"
    end

    @action = action
    file = "mailing_list/#{action}.html"
    begin
      @content = read_html_and_strip_to_body_content(file)
      @xhtml_invalid = true
    rescue
      flash.now[:notice] = "Can't find article"
    end
    render :template => "mailing_list/article"
  end

  private

  def authorize
    unless @admin_menu_perm
      flash[:notice] = "Access Denied."
      session[:original_uri] = request.request_uri
      redirect_to(:controller => "login", :action => "login")
    end
  end
end

class HelpController < ApplicationController
  before_filter :get_user

  def method_missing(action)
    if action == "index"
      action = "bzflag-admin-help2"
    end

    @action = action
    file = "help/#{action}.html"
    begin
      @content = read_html_and_strip_to_body_content(file)
    rescue
      flash.now[:notice] = "Can't find help page: #{action}"
    end
    render :template => "mailing_list/article", :layout => "bzflag"
  end
end

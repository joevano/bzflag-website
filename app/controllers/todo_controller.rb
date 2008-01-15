class TodoController < ApplicationController
  before_filter :authorize_admin_menu_perm

  def method_missing(action)
    if action == "index"
      action = "bzflag"
    end

    @action = action
    file = "public/#{action}.html"
    begin
      @content = read_html_and_strip_to_body_content(file)
    rescue
      flash.now[:notice] = "Can't find todo list: #{action}"
    end
    render :template => "mailing_list/article"
  end
end

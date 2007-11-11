require 'fileutils'

class HelpController < ApplicationController
  before_filter :get_user

  def method_missing(action)
    if action == "index"
      action = "bzflag-admin-help2"
    end

    @action = action
    file = "help/#{action}.html"
    begin
      @content = IO.read(file)
      # Strip off the header
      @content = @content.sub(/^.*<body class="crock">/im, '')
      # Strip off the trailer
      @content = @content.sub(/<\/body>.*$/im, '')
    rescue
      flash.now[:notice] = "Can't find help page: #{action}"
    end
    render :template => "mailing_list/article", :layout => "bzflag"
  end
end

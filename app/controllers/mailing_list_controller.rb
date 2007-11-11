require 'fileutils'

class MailingListController < ApplicationController
  before_filter :get_user

  def method_missing(action)
    if action == "index"
      action = "threads"
    end

    @action = action
    file = "mailing_list/#{action}.html"
    begin
      @content = IO.read(file)
      # Strip off the header
      @content = @content.sub(/^.*<body>/im, '')
      # Strip off the trailer
      @content = @content.sub(/<\/body>.*$/im, '')
      @xhtml_invalid = true
    rescue
      flash[:notice] = "Can't find article"
    end
    render :template => "mailing_list/article", :layout => "bzflag"
  end
end

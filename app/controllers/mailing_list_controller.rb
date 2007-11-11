require 'fileutils'

class MailingListController < ApplicationController
  before_filter :get_user

  def index
    @action = "threads"
    @xhtml_invalid = true
    render :template => "mailing_list/article"
  end

  def method_missing(action)
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

require 'fileutils'

class MailingListController < ApplicationController

  def index
    @action = "threads"
    render :template => "mailing_list/article"
  end

  def method_missing(action)
    @action = action
    file = "mailing_list/#{action}.html"
    @content = IO.read(file)
    # Strip off the header
    @content = @content.sub(/^.*<body>/im, '')
    # Strip off the trailer
    @content = @content.sub(/<\/body>.*$/im, '')
    render :template => "mailing_list/article", :layout => "bzflag"
  end
end

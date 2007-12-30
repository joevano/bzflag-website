#!/usr/bin/env ruby
# Parse BZFlag server log file data from the logDetail plugin
#
# Create database records from the log for use with the bzflag_website
require 'lib/log_parser'

LogParser.process

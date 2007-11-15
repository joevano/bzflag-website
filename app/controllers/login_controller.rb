require 'net/http'
require 'ostruct'
require 'yaml'
require 'cgi'

config = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/config.yml"))
env_config = config.send(RAILS_ENV)
config.common.update(env_config) unless env_config.nil?
::AppConfig = OpenStruct.new(config.common)

class LoginController < ApplicationController

  def login
    @host = AppConfig.root_url
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged out."
    redirect_to "/bzflag/index"
  end

  def validate
    username = params[:username]
    token = params[:token]

    all_groups = Group.find(:all).collect { |grp| grp.name }

    checktoken = "/db/?action=CHECKTOKENS&checktokens=#{CGI::escape(username)}%3D#{CGI::escape(token)}&groups=" + all_groups.join('%0D%0A')
    logger.info(checktoken)
    response = Net::HTTP.get('my.bzflag.org', checktoken)
    logger.info('Token validation reponse for ' + username + ':' + response)

    session[:user_id] = ip = bzid = groups = nil
    if response.index('TOKGOOD: ')
      ip = request.remote_ip
      for line in response
        line.chomp!
        if line.index('TOKGOOD: ')
          data = line.split(' ',2)[1]
          groups = data.split(':',2)[1]
          groups = groups && groups.split(':')
        elsif line.index('BZID: ')
          bzid = line.split(' ')[1]
        end
      end
      # Find or create the user
      u = User.find_by_bzid(bzid) || User.new
      u.bzid = bzid
      u.callsign = username
      u.ip = request.remote_ip
      u.save
      session[:user_id] = u.id

      # Update the groups this user is associated with
      groups = groups || []
      newgroups = groups.collect { |g| Group.find_by_name(g) }
      u.groups.replace(newgroups)
    else
      flash[:notice] = "Login failed."
    end
    redirect_to "/bzflag/index"
  end
end

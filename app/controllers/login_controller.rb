require 'net/http'
require 'ostruct'
require 'yaml'

config = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/config.yml"))
env_config = config.send(RAILS_ENV)
config.common.update(env_config) unless env_config.nil?
::AppConfig = OpenStruct.new(config.common)

class LoginController < ApplicationController

  def login
    @host = AppConfig.root_url
  end

  def logout
    session[:username] = nil
    session[:bzid] = nil
    session[:groups] = nil
    session[:ip] = nil
    redirect_to "/bzflag/index"
  end

  def validate
    username = params[:username]
    token = params[:token]

    groups = ['NORANG.HIDE',
              'NORANG.RECORD',
              'NORANG.REPLAY',
              'NORANG.JRADMIN',
              'NORANG.SRADMIN',
              'NORANG.TRADMIN',
              'DEVELOPERS']
    checktoken = "/db/?action=CHECKTOKENS&checktokens=#{username}%3D#{token}&groups=" + groups.join('%0D%0A')
    response = Net::HTTP.get('my.bzflag.org', checktoken)

    session[:username] = nil
    session[:bzid] = nil
    session[:groups] = nil
    session[:ip] = nil
    if response.index('TOKGOOD: ')
      session[:ip] = request.remote_ip
      for line in response
        line.chomp!
        if line.index('TOKGOOD: ')
          data = line.split(' ',2)[1]
          session[:username] = data.split(':',2)[0]
          groups = data.split(':',2)[1]
          if groups
            session[:groups] = groups.split(':')
          end
        elsif line.index('BZID: ')
          session[:bzid] = line.split(' ')[1]
        end
      end
    end
    redirect_to "/bzflag/index"
  end
end

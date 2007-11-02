require 'net/http'

class LoginController < ApplicationController

  def login
  end

  def logout
    session[:username] = nil
    session[:bzid] = nil
    session[:groups] = nil
  end

  def validate
    @username = params[:username]
    @token = params[:token]

    groups = ['NORANG.HIDE',
              'NORANG.RECORD',
              'NORANG.REPLAY',
              'NORANG.JRADMIN',
              'NORANG.SRADMIN',
              'NORANG.TRADMIN',
              'DEVELOPERS']
    checktoken = "/db/?action=CHECKTOKENS&checktokens=#{@username}%3D#{@token}&groups=" + groups.join('%0D%0A')
    @response = Net::HTTP.get('my.bzflag.org', checktoken)

    session[:username] = nil
    session[:bzid] = nil
    session[:groups] = nil
    if @response.index('TOKGOOD: ')
      for line in @response
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
      flash[:notice] = "Login successful!"
    else
      flash[:notice] = "Login failed - bad token"
    end

  end
end

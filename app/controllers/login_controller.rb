require 'net/http'

class LoginController < ApplicationController

  def login
  end

  def logout
  end

  def validate
    @username = params[:username]
    @token = params[:token]
    groups = ['NORANG.HIDE','NORANG.RECORD','NORANG.REPLAY','NORANG.JRADMIN','NORANG.SRADMIN','NORANG.TRADMIN','DEVELOPERS']
    site = "/db/?action=CHECKTOKENS&checktokens=#{@username}%3D#{@token}&groups=" + groups.join('%0D%0A')
    @response = Net::HTTP.get('my.bzflag.org', site)

    valid_login = nil
    @username = nil
    @groups = []
    @bzid = nil
    for line in @response
      if line.index('TOKGOOD: ')
        data = line.split(' ',2)[1]
        @username = data.split(':',2)[0]
        @groups = data.split(':',2)[1].split(':')
        valid_login = true
      elsif line.index('BZID: ')
        @bzid = line.split(' ')[1]
      end
    end
    if valid_login
      flash[:notice] = "Login successful!"
    else
      flash[:notice] = "Login failed - bad token"
    end
  end
end

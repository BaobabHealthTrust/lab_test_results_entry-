require 'user_service.rb'
class UserController < ApplicationController
  def index
    if params[:error]
      @prompt = true      
    end
 
  end
 
  def log
      if !params[:error].blank?
        @error = params[:error]
      end
      config = YAML.load_file("#{Rails.root}/config/application.yml")

      @app_name = config['facility_name']
      @log_in = true
  end

  def log_out
    session.delete(:user)
    redirect_to '/'
  end

  def authenticate
    username = params[:username]
    password = params[:password]

    status = UserService.authenticate(username,password)
       
    if status[0] == true           
        token = status[1]['authorization']['token']
        user_id = status[1]['authorization']['user']['user_id']
        f_name = status[1]['authorization']['user']['person']['names'][0]['given_name']
        s_name = status[1]['authorization']['user']['person']['names'][0]['family_name']
        
        session['user'] = [token,user_id,f_name,s_name]
        redirect_to '/user/index'
    else
        redirect_to  '/?error=' + 'wrong username or password' if status[1].message == "401 Unauthorized" 
        redirect_to  '/?error=' + 'opp!! something went wrong' if status[1].message == "500 Internal Server Error"            
    end       

  end
end

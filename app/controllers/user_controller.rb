require 'user_service.rb'
class UserController < ApplicationController
  def index
    if params[:error]
      @prompt = true      
    end
 
  end
  $found_patients = []
  $search = false;
  $create_order = 'false'
  def log
      if !params[:error].blank?
        @error = params[:error]
      end
      config = YAML.load_file("#{Rails.root}/config/application.yml")

      @app_name = config['facility_name']
      @log_in = true
  end

  def patient_particulars

  end

  def search_patient
    option = params[:option]
    $create_order = params[:create_order] if params[:create_order] == 'true'
    $create_order = 'false' if params[:create_order] == 'false'
    if option == "by name"
      
      last_name = params[:last_name]
      first_name = params[:first_name]
      gender = params[:gender]
      res = UserService.search_patient_by_name(first_name,last_name,gender,session[:user][0])
      $search = false;
    else
      id = params[:id]
      res = UserService.scan_patient(id,session[:user][0])
      $search = true;
    end
    $found_patients = res
    render plain: res.to_json and return
  end

  def found_patients
    @data = $found_patients
    @search_option = $search
    @create_order = $create_order
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

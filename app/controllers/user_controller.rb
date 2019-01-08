class UserController < ApplicationController
  def index
    if params[:error]
      @prompt = true      
    end

    if !params[:confirmation].blank? && params[:confirmation] != nil
      
      @confirmation = params[:confirmation]      
    end   
  end
 
  def log

  end

  def authenticate
    username = params[:username]
    password = params[:password]


  end
end

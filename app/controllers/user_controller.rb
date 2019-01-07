class UserController < ApplicationController
  def index
    if params[:error]
      @prompt = true      
    end

    if params[:confirmation] == 'true' || params[:confirmation] == 'false'
      @confirmation = params[:confirmation]      
    end
   
  end
end

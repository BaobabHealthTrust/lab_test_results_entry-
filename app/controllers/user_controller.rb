class UserController < ApplicationController
  def index
    if params[:error]
      @prompt = true
    end
  end
end

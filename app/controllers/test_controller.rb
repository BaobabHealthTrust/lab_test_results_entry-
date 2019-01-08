require 'test_service'
class TestController < ApplicationController
  VOIDED = 'voided'
  PASS   = 'verified'
  FAILED = 'failed'
  def index

         

        @patient_id = params[:patient_id]
        @patient_name = params[:patient_name]
        @patient_gender = params[:patient_gender]
        @patient_DOB = params[:patient_DOB]

        @accession_number = params[:tracking_number]
        @sample_type = params[:sample_type]
        @test = params[:tests]
        @date_ordered = params[:date_created].to_date rescue nil    
        @disable = false

        res = TestService.check_test_status(@accession_number)
       
          status = res[0]
        
          if status.values.join("") == VOIDED
            @checker = [true,'action not posible to complete, as test is voided']
            @disable = 'true'
          elsif status.values.join("") == PASS
            @checker = [true,'action not posible to complete, as test passed']
            @disable = 'true'
          elsif status.values.join("") == FAILED
            @checker = [true,'action not posible to complete, as test failed']
            @disable = 'true'
          end
        
  end


  def retrieve_order
    tracking_number = params[:tracking_number]   
    re = TestService.retrieve_order(tracking_number)
   
    render plain: re.to_json and return
  end

  def retrieve_test_details
    test_name = params[:test]
    test_name = test_name.gsub("AND","&")
    res = TestService.retrieve_test_details(test_name)
    if res == false
        render plain: 'no measures'.to_s and return
    else
        render plain: res and return
    end    
  end

  def save_results    
    results = params[:data].to_unsafe_h   
    tracking_number = params[:tracking_number]
    test_name = params[:test_name]   
    test_name = test_name.gsub("AND","&")
   
    
    who_updated = {
                'id_number': session[:user][1],
                'phone_number': '',
                'first_name': session[:user][2],
                'last_name': session[:user][3]
    }
      
    res = TestService.save_results(tracking_number,test_name,results,who_updated)
    render plain: res[0].to_json and return
  end

  

  def update_test_status
    status = params[:status]
    test_name = params[:test]
    tracking_number = params[:tracking_number]
    
    who_updated = {
      'id_number': session[:user][1],
      'phone_number': '',
      'first_name': session[:user][2],
      'last_name': session[:user][3]
    }

    res = TestService.update_test_status(tracking_number,test_name,status,who_updated)
    if res['error'] == false
      msg = true
    else
      msg = false
    end
    render plain: msg and return
  end 

  def confirmation

      if !params[:confirmation].blank?
          @prompt = true
      end

      @test_values = params[:test_values]
      @test_values = @test_values.split("_") if !@test_values.blank?
      @patient_id = params[:patient_id]
      @patient_name = params[:patient_name]
      @patient_gender = params[:patient_gender]
      @patient_DOB = params[:patient_DOB]

      @accession_number = params[:tracking_number]
      @sample_type = params[:sample_type]
      @test = params[:tests]
      @date_ordered = params[:date_created].to_date rescue nil    
      @test_status = params[:test_status]

  end

end

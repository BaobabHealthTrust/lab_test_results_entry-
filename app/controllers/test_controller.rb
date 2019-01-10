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

        @collected_by = params[:collected_by]
        @requested_by = params[:requested_by]
        @target_lab = params[:target_lab]

        @accession_number = params[:tracking_number]
        @sample_type = params[:sample_type]
        @test = params[:tests]
        @date_ordered = params[:date_created].to_date rescue nil    
        @disable = false

        res = TestService.check_test_status(@accession_number)
        results = TestService.retrieve_test_results(@accession_number)
      
        if results == false
          @tests = res.collect do |k|
                      tst_name = k.keys
                      status = k[k.keys.join("")]
                      [tst_name.join(""),status,'no result','',false] if status == 'drawn' || status == 'Drawn'
                      [tst_name.join(""),status,status,{'result': status},true] if status != 'drawn' || status != 'Drawn'
                      
                  end
        else            
            
            rst = results
          @tests = res.collect do |k|
                tst_name = k.keys
                status = k[k.keys.join("")]
                if !results['results'][tst_name.join("")].blank?
                  [tst_name.join(""),status,results['results'][tst_name.join("")]['result_date'],results['results'][tst_name.join("")],true]
                else
                    [tst_name.join(""),status,'no result','',false] if status == 'drawn' || status == 'Drawn'
                    [tst_name.join(""),status,status,{'result': status},true] if status != 'drawn' || status != 'Drawn'
                end
              end
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

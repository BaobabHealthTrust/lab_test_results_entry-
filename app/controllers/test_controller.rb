require 'test_service'
require 'user_service'
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

  def save_order
   
    order_location = "ART"
    specimen_type = params[:specimen_type]
    tst = [params[:test]]
    priority = params[:priority]
    target_lab = params[:target_lab]
    requesting_clinician = params[:requesting_by]
    name = params[:name]
    identifier = params[:id]
    gender = params[:gender]
    birthdate = params[:birthdate]
    patient = ["",name.split(" ")[0],name.split(" ")[1],birthdate,gender]
    date_drawn = params[:date_drawn]
    res = TestService.save_order(order_location,specimen_type,tst,priority,target_lab,requesting_clinician,session[:user],patient,identifier,date_drawn)

    render plain: res.to_json and return
  end


  def create_order
    @person_id = params[:person_id]
    @name = params[:name]
    @gender = params[:gender]
    @birthdate = params[:birthdate]
    @state_province = params[:state_province]   
    identifier = ""   
      r = UserService.search_patient_identifiers_by_patient_id(@person_id,session[:user][0])
      if r[0] == true
        r[1][0]['identifier']
        if r[1][0]['type']['patient_identifier_type_id'] == 3
            identifier = r[1][0]['identifier']
        end
      end    
    @test_cat = TestService.retrieve_test_catelog
    @target_lab = TestService.retrieve_target_labs
    @person_id = identifier
  end

  def get_test_measures
      test_name = params[:test_name]
      res = TestService.query_test_measures(test_name)
      render plain: res.to_json and return
  end

  def patient_home
    @person_id = params[:person_id]
    @name = params[:name]
    @gender = params[:gender]
    @birthdate = params[:birthdate]
    @state_province = params[:state_province]
    create_order = params[:create_order]
    identifier = ""
    if create_order == "true"
      identifier = @person_id    
    else     
        r = UserService.search_patient_identifiers_by_patient_id(@person_id,session[:user][0])
        if r[0] == true
          r[1][0]['identifier']
          if r[1][0]['type']['patient_identifier_type_id'] == 3
              identifier = r[1][0]['identifier']
          end
        end
    end
    @person_id = identifier
    @res = TestService.get_tests_with_no_results(identifier)    
  end


  def save_dispatch
      tracking_number = params[:tracking_number]
      dispatcher = params[:dispatcher]
    
      res = TestService.dispatch(tracking_number,dispatcher)
      if !res = false
          render plain: 'true' and return
      else
          render plain: 'false' and return
      end
  end

  def sample_dispatch
      @dispatcher_f_name = params[:dispatcher_name].split("_")[0]
      @dispatcher_s_name = params[:dispatcher_name].split("_")[1]

  end


  def dispatcher
  
  end
  
  def retrieve_order
    tracking_number = params[:tracking_number]   
    if params[:checking]
      re = TestService.retrieve_order(tracking_number)  
      render plain: re.to_json and return
    else
      r = TestService.check_if_dispatched(tracking_number)
      if r == false
        re = TestService.retrieve_order(tracking_number)  
        render plain: re.to_json and return
      else
        render plain: r.to_json and return
      end
    end
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

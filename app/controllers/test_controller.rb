require 'test_service'
class TestController < ApplicationController

  def index
    tracking_number = params[:tracking_number]
    re = TestService.retrieve_order(tracking_number)
    if re != false
      data = re
     
      @patient_id = data['other']['patient']['id']
      @patient_name = data['other']['patient']['name']
      @patient_gender = data['other']['patient']['gender']
      @patient_DOB = data['other']['patient']['DOB']

      @accession_number = tracking_number
      @sample_type = data['other']['sample_type']
      @test = data['tests'].keys[0]
      @date_ordered = data['other']['date_created'].to_date
    else
      redirect_to '/?error=' + 'Order for specified accession number not found' 
    end

  end


  def retrieve_order
    tracking_number = params[:tracking_number]
    re = TestService.retrieve_order(tracking_number)
    raise re.inspect

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
                'id_number': '1',
                'phone_number': '2939393',
                'first_name': 'gibo',
                'last_name': 'malolo'
    }
      
    res = TestService.save_results(tracking_number,test_name,results,who_updated)
    render plain: res[0].to_json and return
  end

  def update_test_status
    status = params[:status]
    test_name = params[:test]
    tracking_number = params[:tracking_number]
    
    who_updated = {
      'id_number': '1',
      'phone_number': '2939393',
      'first_name': 'gibo',
      'last_name': 'malolo'
    }

    res = TestService.update_test_status(tracking_number,test_name,status,who_updated)
    if res['error'] == false
      msg = true
    else
      msg = false
    end
    render plain: msg and return
  end 

end

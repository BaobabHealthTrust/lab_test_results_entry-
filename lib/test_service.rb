module TestService


    def self.retrieve_order(tracking_number)

        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        _token = File.read("#{Rails.root}/tmp/token")
        headers = {
            content_type: 'application/json',
            token: _token
        }
       
        url = "#{protocol}://#{host}:#{port}#{prefix}query_order_by_tracking_number/#{tracking_number}"
     
        res = JSON.parse(RestClient.get(url,headers))
        if res['error'] == false
            return res['data']
        else
            return 'false'
        end
        
    end

    def self.check_test_status(tracking_number)
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        _token = File.read("#{Rails.root}/tmp/token")
        headers = {
            content_type: 'application/json',
            token: _token
        }
       
        url = "#{protocol}://#{host}:#{port}#{prefix}query_test_status/#{tracking_number}"
        puts "----------------"
        puts tracking_number
        puts url
        res = JSON.parse(RestClient.get(url,headers))
        if res['error'] == false
            return res['data']
        else
            return 'false'
        end

    end

    def self.save_results(tracking_number_,test_name_,results_,who_updated)
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        _token = File.read("#{Rails.root}/tmp/token")
        headers = {
            content_type: 'application/json',
            token: _token
        }
        
        data = {
                :tracking_number => tracking_number_,
                :test_status => 'verified',
                :test_name => test_name_,     
                :who_updated => {
                        'id_number': '1',
                        'phone_number': '2939393',
                        'first_name': 'gibo',
                        'last_name': 'malolo'
                },
                :results => results_
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}update_test"
        res = JSON.parse(RestClient.post(url,data,headers))
       
        if res['error'] == false
            return [true, res['message']]
        else
            return [false,res['message']]
        end


    end

    def self.update_test_status(tracking_number,test_name,status,who_updated)
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        _token = File.read("#{Rails.root}/tmp/token")
        headers = {
            content_type: 'application/json',
            token: _token
        }
       
        test_name = test_name.gsub(" ","_")    
    
        status = 'failed' if status == 'fail'
        status = 'voided' if status == 'void'
        data = {
                :tracking_number => tracking_number,
                :test_status => status,
                :test_name => test_name,     
                :who_updated => who_updated,
                :results => { }
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}update_test"        
        res = JSON.parse(RestClient.post(url,data,headers))        
        return res
    end


    def self.query_test_measures(test_name)
        test_name = test_name.gsub(" ","_")
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        _token = File.read("#{Rails.root}/tmp/token")

        headers = {
            content_type: 'application/json',
            token: _token
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}query_test_measures/#{test_name}"
        res = JSON.parse(RestClient.get(url,headers))

        if res['error'] == false
            return res['data']
        else
            return false
        end
    end
    

    def self.retrieve_test_catelog
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        _token = File.read("#{Rails.root}/tmp/token")
        headers = {
            content_type: 'application/json',
            token: _token
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}retrieve_test_Catelog"
        res = JSON.parse(RestClient.get(url,headers))

        if res['error'] == false
            return res['data']
        else
            return false
        end
    end

    def self.save_order(order_location,specimen_type,tests,priority,target_lab,requesting_clinician,session,patient,identifier,date_drawn)
       
        settings = YAML.load_file "#{Rails.root}/config/application.yml"
        config = YAML.load_file "#{Rails.root}/config/emr_service.yml"
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"

        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']
        
        _token = File.read("#{Rails.root}/tmp/token")
        
                headers = {
                    content_type: 'application/json',
                    token: _token
                }

                json = {
                        :district => settings['district'],
                        :health_facility_name => settings['facility_name'],
                        :first_name=> patient[1],
                        :last_name=>  patient[2],
                        :middle_name=> '',
                        :date_of_birth=>  patient[3],
                        :gender=> patient[4],
                        :national_patient_id=>  identifier,
                        :phone_number=> "",
                        :reason_for_test=> (tests.include?("EID") ? 'HIV Exposed Infant' : 'Routine'),
                        :who_order_test_last_name=> session[3],
                        :who_order_test_first_name=> session[2],
                        :who_order_test_phone_number=> '',
                        :who_order_test_id=> session[1],
                        :order_location=> order_location,
                        :sample_type=> specimen_type,
                        :date_sample_drawn=> date_drawn,
                        :tests=> tests,
                        :sample_status => 'specimen_collected',
                        :sample_priority=> priority || 'Routine',
                        :target_lab=> target_lab,            
                        :art_start_date => (art_start_date rescue nil),            
                        :date_received => Date.today.strftime("%Y%m%d%H%M%S"),
                        :requesting_clinician => requesting_clinician        
                }       
                    
                url = "#{protocol}://#{host}:#{port}#{prefix}create_order"
                res = JSON.parse(RestClient.post(url,json,headers))            
       
        #url = "#{protocol}://#{host}:#{port}#{prefix}programs/1/lab_tests/orders"
        #res = JSON.parse(RestClient.post(url,data,headers))
            if res['error'] == false
                #host = configs['host']
                #prefix = configs['prefix']
                #port = configs['port']
                #protocol = configs['protocol']
                #headers = {
                #    content_type: 'application/json',
                #    Authorization: session[3]
                #}

                #data = {
                #    "tracking_number" =>  res['data']['tracking_number'],
                #    "patient_id"      => patient[0],
                #    "ordered_by"      => { "first_name" => session[1], "last_name" => session[2] , "id" => session[0]
                #    }
                #}
                #url = "#{protocol}://#{host}:#{port}#{prefix}programs/1/lab_tests/orders"
                #res = JSON.parse(RestClient.post(url,data,headers))
                #
                return [true, res['data']['tracking_number']]
            else
                return [false,""]
            end           
        
    end


    def self.retrieve_target_labs
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']
        _token = File.read("#{Rails.root}/tmp/token")

        headers = {
            content_type: 'application/json',
            token: _token
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}retrieve_target_labs"
        res = JSON.parse(RestClient.get(url,headers))

        if res['error'] == false
            return res['data']
        else
            return false
        end
    end

    def self.retrieve_test_details(test_name)
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        _token = File.read("#{Rails.root}/tmp/token")
        headers = {
            content_type: 'application/json',
            token: _token
        }
       
        test_name = test_name.gsub(" ","_")
        url = "#{protocol}://#{host}:#{port}#{prefix}query_test_measures/#{test_name}"
        
        res = JSON.parse(RestClient.get(url,headers))
        if res['error'] == false
            return res['data']
        else
            return false
        end
    end


    def self.get_tests_with_no_results(npid)
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']
       
        _token = File.read("#{Rails.root}/tmp/token")
        tests  = ""
        headers = {
            content_type: "application/json",
            token: _token
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}query_tests_with_no_results_by_npid/#{npid}"
        res = JSON.parse(RestClient.get(url,headers))
        
        if res['error'] == false
            tests = res['data']
        else
            return false
        end 
       
        return tests      
    end


    def self.check_if_dispatched(tracking_number)
        
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        _token = File.read("#{Rails.root}/tmp/token")
        headers = {
            content_type: 'application/json',
            token: _token
        }
    
        url = "#{protocol}://#{host}:#{port}#{prefix}check_if_dispatched/#{tracking_number}"
        
        res = JSON.parse(RestClient.get(url,headers))
        if res['error'] == false
            return false
        else
            return true
        end
    end

    def self.dispatch(tracking_number,dispatcher_name)
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        _token = File.read("#{Rails.root}/tmp/token")
        headers = {
            content_type: 'application/json',
            token: _token
        }
       
        data = {
            'tracking_number': tracking_number,
            'dispatcher_first': dispatcher_name.split("_")[0],
            'dispatcher_last': dispatcher_name.split("_")[1]
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}dispatch_sample"
        
        res = JSON.parse(RestClient.post(url,data,headers))
        if res['error'] == false
            return res['data']
        else
            return false
        end
    end

    def self.retrieve_test_results(tracking_number)
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        _token = File.read("#{Rails.root}/tmp/token")
        headers = {
            content_type: 'application/json',
            token: _token
        }
       

        url = "#{protocol}://#{host}:#{port}#{prefix}query_results_by_tracking_number/#{tracking_number}"
        
        res = JSON.parse(RestClient.get(url,headers))
        if res['error'] == false
            return res['data']
        else
            return false
        end
    end

end

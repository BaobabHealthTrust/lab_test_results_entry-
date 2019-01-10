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

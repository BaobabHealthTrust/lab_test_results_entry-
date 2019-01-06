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
            return false
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
end

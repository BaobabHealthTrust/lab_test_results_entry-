class ApplicationController < ActionController::Base

    before_action :check_nlims_token, :except => [
                                       
                                        ]

    def check_nlims_token
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        settings = YAML.load_file "#{Rails.root}/config/application.yml"
        _token = File.read("#{Rails.root}/tmp/token")

        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']
        username = configs['nlims_custome_password']
        password = configs['nlims_custome_username']

        headers = {
            content_type: 'application/json',
            token: _token
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}check_token_validity"
        res = JSON.parse(RestClient.get(url,headers))
        if res['error'] == true
            url = "#{protocol}://#{host}:#{port}#{prefix}re_authenticate/#{username}/#{password}"
            res = JSON.parse(RestClient.get(url,headers))
            
            if res['error'] == false
                File.open("#{Rails.root}/tmp/token",'w'){ |t|
                    t.write(res['data']['token'])
                }
            end

        end
    end

end

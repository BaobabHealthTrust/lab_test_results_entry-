Rails.application.routes.draw do
 
  root 'user#log'  
 
  get  '/test/index'
  get  '/user/index'                    => 'user#index'
  get  '/test/retrieve_order'           => 'test#retrieve_order'
  get  '/test/retrieve_test_details'    => 'test#retrieve_test_details'
  get  '/test/save_results'             => 'test#save_results'
  get  '/test/update_test_status'       => 'test#update_test_status'
  get  '/test/confirmation'             => 'test#confirmation'
  post '/user/authenticate'             => 'user#authenticate'
  get  '/user/log_out'                  => 'user#log_out'
  get  '/test/dispatcher'               => 'test#dispatcher'
  get  '/test/sample_dispatch'          => 'test#sample_dispatch'
  get  '/test/dispatch'                 => 'test#save_dispatch'
  get  '/user/search_patient'           => 'user#search_patient'
  get  '/user/found_patients'           => 'user#found_patients'
  get  '/test/patient_home'             => 'test#patient_home'
  get  '/test/get_test_measures'        => 'test#get_test_measures'
  get  '/user/patient_particulars'      => 'user#patient_particulars'
  get  '/test/create_order'             => 'test#create_order'
  post '/test/save_order'               => 'test#save_order'
  get '/test/save_order'               => 'test#save_order'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

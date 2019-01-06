Rails.application.routes.draw do
  get '/test/index'
  get '/'   => 'user#index'


  get '/test/retrieve_order'          => 'test#retrieve_order'
  get '/test/retrieve_test_details'   => 'test#retrieve_test_details'
  get '/test/save_results'            => 'test#save_results'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

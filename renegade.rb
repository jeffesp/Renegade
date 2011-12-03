require 'rubygems'
require 'sinatra'
#require 'bcrypt'

require 'renegade-data'

get '/login' do
    erb :login
end

post '/login' do
    # if email is not registered and password is not empty, check user
    user = { } # load from db
    BCrypt::Password.new(user.password_hash) == params[:password] or erb :login
    # redirect to home as logged in user
end

get '/create' do
   @contact_address = "jespenschied@gmail.com"
   erb :create
end

post '/create' do
    params[:username]
    params[:password]
    params[:firstname]
    params[:lastname]
    # redirect to home page, create message that says the user should expect an email when the account is enabled
    erb :index
end

get '/list/:type' do
  @type = params[:type].to_sym
  data = RenegadeData.new
  @people = data.get_people(@type)
  erb :people
end

get '/add/:type' do
  @type = params[:type].to_sym
  erb :addperson
end

post '/add/:type' do
  data = RenegadeData.new
  person = data.add_person(params[:first_name], params[:last_name], params[:type].to_sym)
  redirect "/view/student/{#person.id}", 302
end

get '/view/:type/:id' do
  data = RenegadeData.new
  person = data.get_person(params[:id], params[:type].to_sym)
  erb :viewperson
end

get '/(index)?' do
    @title = "Testing"
    erb :home
end


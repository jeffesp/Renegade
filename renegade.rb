require 'rubygems'
require 'sinatra/base'
require 'renegade-data'

class Renegade < Sinatra::Base
  before do
    # auth
    # create conn to db?
  end

  after do
    # close conn to db?
  end


  get '/' do
      erb :home
  end

  #get '/login' do
  #    erb :login
  #end
  #
  #post '/login' do
  #    # if email is not registered and password is not empty, check user
  #    user = { } # load from db
  #    BCrypt::Password.new(user.password_hash) == params[:password] or erb :login
  #    # redirect to home as logged in user
  #end
  #
  #get '/create' do
  #   @contact_address = "jespenschied@gmail.com"
  #   erb :create
  #end
  #
  #post '/create' do
  #    params[:username]
  #    params[:password]
  #    params[:firstname]
  #    params[:lastname]
  #    # redirect to home page, create message that says the user should expect an email when the account is enabled
  #    erb :index
  #end

  get '/list/:type' do
    @type = params[:type].to_sym
    data = RenegadeData.new
    @people = data.get_people(@type)
    erb :people
  end

  get '/add/:type' do
    @type = params[:type].to_sym
    @person = {}
    @action = 'add'
    erb :addperson
  end

  post '/add/:type' do
    personid = RenegadeData.new.add_person(params)
    redirect "/view/student/#{personid}", 302
  end

  get '/edit/:type/:id' do
    @type = params[:type].to_sym
    @person = RenegadeData.new.get_person(params[:id], params[:type].to_sym) or redirect "/notfound"
    @action = 'edit'
    erb :addperson
  end

  post '/edit/:type' do
    personid = RenegadeData.new.update_person(params)
    redirect "/view/student/#{params[:id]}", 302
  end

  post '/add/:type' do
    personid = RenegadeData.new.data.add_person(params)
    redirect "/view/student/#{personid}", 302
  end

  get '/view/:type/:id' do
    data = RenegadeData.new
    @person = data.get_person(params[:id], params[:type].to_sym) or redirect "/notfound"
    erb :viewperson
  end

  get '/notfound' do
    @message = "What you are looking for is no longer here."
    erb :notfound
  end

end

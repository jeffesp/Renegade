require 'rubygems'
require 'sinatra/base'
require 'bcrypt'
require 'renegade-data'

class Renegade < Sinatra::Base
  before do
    # check authenticaion cookie exists if not logging in
    # TODO: content of cookie and regex for login before the ? are needed
    if !request.cookies["auth"] and request.path != '/login'
      redirect to("/login?returnurl=#{request.path}"), 302
    end
    # create conn to db?
  end

  after do
    # close conn to db?
  end


  get '/' do
      erb :home
  end

  get '/login' do
    @showError = params[:showerror]
    erb :login
  end

  post '/login' do
    # if email is registered and password is not empty, check user
    data = RenegadeData.new
    user = data.get_user(params[:email])
    if user == nil or !(user[:active]) or (BCrypt::Password.new(user[:password_hash]) != params[:password])
      redirect to("/login?showerror=true"), 302
    end
    response.set_cookie("auth", user[:password_hash])
    # TODO: redirect back to where they came from. Make sure we are not an open redirect here.
    redirect "/", 302
  end

  get '/create' do
     @contact_address = "jespenschied@gmail.com"
     erb :create
  end

  post '/create' do
    data = RenegadeData.new
    if (params[:password] == params[:confirm])
      data.add_user(params[:email], BCrypt::Password.create(params[:password]))
      redirect "/", 302
    end
    redirect to("/create?showerror=true"), 302
  end

  get '/logout' do
    response.delete_cookie("auth")
    redirect to("/login"), 302
  end

  get '/list/:type' do
    @type = params[:type].to_sym
    data = RenegadeData.new
    @people = data.get_people(@type)
    erb :people
  end

  get '/list/people.json' do
    # here we might receive a search term, some filter information, or nothing?
    content_type :json
    { :people => 'value1' }.to_json
  end

  get '/add/:type' do
    @type = params[:type].to_sym
    @person = {}
    @action = 'add'
    erb :addperson
  end

  post '/add/:type' do
    personid = RenegadeData.new.add_person(params)
    redirect to("/view/student/#{personid}"), 302
  end

  get '/edit/:type/:id' do
    @type = params[:type].to_sym
    @person = RenegadeData.new.get_person(params[:id], params[:type].to_sym) or redirect to("/notfound"), 302
    @action = 'edit'
    erb :addperson
  end

  post '/edit/:type' do
    personid = RenegadeData.new.update_person(params)
    redirect to("/view/student/#{params[:id]}"), 302
  end

  post '/add/:type' do
    personid = RenegadeData.new.data.add_person(params)
    redirect to("/view/student/#{personid}"), 302
  end

  get '/view/:type/:id' do
    data = RenegadeData.new
    @type = params[:type].to_sym
    @person = data.get_person(params[:id], params[:type].to_sym) or redirect to("/notfound"), 302
    erb :viewperson
  end

  # TODO: have some sort of session stuff going on here to display more information
  get '/notfound' do
    @message = "What you are looking for is no longer here."
    erb :notfound
  end

end

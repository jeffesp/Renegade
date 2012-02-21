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

  get '/people' do
    # params might be empty -> just show list
    # params might have data display params -> get people with filter
    # params might have search text -> do a search
    data = RenegadeData.new
    @people = []
    if (params[:search] != nil)
      @people = nil
    elsif (params.count > 0) # if not searching, but has params
      @people = nil
    else
      @people = data.get_people
    end
    erb :people
  end

  get '/add/person' do
    @person = {}
    @action = 'add'
    erb :addperson
  end

  post '/add/person' do
    personid = RenegadeData.new.add_person(params)
    redirect to("/person/#{personid}"), 302
  end

  get '/edit/person/:id' do
    @person = RenegadeData.new.get_person(params[:id]) or redirect to("/notfound"), 302
    @action = 'edit'
    erb :addperson
  end

  post '/edit/person' do
    personid = RenegadeData.new.update_person(params)
    redirect to("/person/#{params[:id]}"), 302
  end

  get '/person/:id' do
    data = RenegadeData.new
    @person = data.get_person(params[:id]) or redirect to("/notfound"), 302
    erb :viewperson
  end

  # TODO: have some sort of session stuff going on here to display more information
  get '/notfound' do
    @message = "What you are looking for is no longer here."
    erb :notfound
  end

end

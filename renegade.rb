require 'rubygems'
require 'sinatra/base'
require 'bcrypt'
require 'renegade-data'

class Renegade < Sinatra::Base

  def select_date_keys(params)
    params.keys.find_all { |key| key.match(/-date-[m|d|y]$/) }
  end
  def has_date_keys(params)
    select_date_keys(params).length > 0
  end
  def get_date_value_names(keys)
    date_names = Set.new
    keys.each do |k|
      prefix = '' #key.match(/^(?<name>\w+)-date-[m|d|y]$/)[:name]
      date_names.add(prefix)
    end
    date_names.to_a
  end
  def process_date_keys(params)
    keys = select_date_keys(params)
    names = get_date_value_names(keys)
    
  end

  def is_local_url(url)
    true
  end

  before do
    # check authenticaion cookie exists if not logging in
    if !request.cookies["auth"] and !/^\/login(\?returnurl=[\w\/]+)?$/i.match(request.path)
      redirect to("/login?returnurl=#{request.path}"), 302
    end

  
  end

  after do
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
p params
    if (params[:returnurl] and is_local_url(params[:returnurl]))
      redirect_to = params[:returnurl]
    else
      redirect_to = '/'
    end
    redirect redirect_to, 302
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
      @people = data.find_people(params[:search])
    elsif (params.count > 0) # if not searching, but has params
      @people =[]
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

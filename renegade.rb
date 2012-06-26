require 'rubygems'
require 'date'
require 'sinatra/base'
require 'bcrypt'
require 'renegade-data'

class Renegade < Sinatra::Base

  @loggedIn = false
  helpers do
    def partial (template, locals = {})
        erb(template, :layout => false, :locals => locals)
    end
    def role_icons(role)
      val = ""
      if (role == :student)
        val += "<i class='icon-book'></i>"
      end
      if (role == :worker or role == :student_worker)
        val = val + "<i class='icon-user'></i>"
      end
      val
    end
  end

  def select_date_keys(params)
    params.keys.find_all { |key| /-date-[m|d|y]$/i.match(key) }
  end
  def has_date_keys(params)
    select_date_keys(params).length > 0
  end
  def get_date_value_names(keys)
    # pull the relevant part of the identifiers out of the keys
    date_names = Set.new
    keys.each do |key|
      key_match = key.match(/^(\w+)-date-[m|d|y]$/i)
      date_names.add(key_match[1]) unless key_match.nil?
    end
    date_names.to_a
  end
  def date_from_params(name, params)
    y, m, d = "#{name}-date-y", "#{name}-date-m", "#{name}-date-d"
    if (params[y].empty? or params[m].empty? or params[d].empty?)
      return nil
    end
    Date::civil(params[y].to_i, params[m].to_i, params[d].to_i).to_s
  end
  def process_date_keys(params)
    # get the names of the dates we want to create from the inputs
    # then extract the values associated with those names and create 
    # a hash that contains the new values
    keys = select_date_keys(params)
    names = get_date_value_names(keys)

    names.each do |name| params[name] = date_from_params(name, params) end

    # remove no longer necessary values
    keys.each do |key| params.delete(key) end
  end

  def is_local_url(url)
    # TODO: we don't 'want to be an open redirect so we should only recognize relative urls here.
    true
  end

  before do
    # check authenticaion cookie exists if not logging in
    if !request.cookies["auth"] and !/^\/create|\/login(\?returnurl=[\w\/]+)?$/i.match(request.path)
      redirect to("/login?returnurl=#{request.path}"), 302
      return
    end
    process_date_keys(params)
    @loggedIn = !request.cookies["auth"].nil?
  end

  after do
  end

  get '/' do
    redirect '/people', 302
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
    if (params[:returnurl] and is_local_url(params[:returnurl]))
      redirect_to = params[:returnurl]
    else
      redirect_to = '/people'
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
      @people = [] #data.get_people
    else
      @people = data.get_people
    end
    @meetings = data.get_locations or []
    @grades = data.get_grades or []
    erb :people
  end

  get '/add/person' do
    data = RenegadeData.new
    @person = { :first_attendance => Date.today }
    @meetings = data.get_locations or []
    @action = 'add'
    erb :addperson
  end

  get '/person/:id' do
    data = RenegadeData.new
    @meetings = data.get_locations or []
    @person = data.get_person(params[:id]) or redirect to("/notfound"), 302
    erb :viewperson
  end

  post '/add/person' do
    personid = RenegadeData.new.add_person(params)
    redirect to("/person/#{personid}"), 302
  end

  get '/edit/person/:id' do
    data = RenegadeData.new
    @person = data.get_person(params[:id]) or redirect to("/notfound"), 302
    @meetings = data.get_locations or []
    @action = 'edit'
    erb :addperson
  end

  post '/edit/person' do
    personid = RenegadeData.new.update_person(params)
    redirect to("/person/#{params[:id]}"), 302
  end

  get '/delete/person/:id' do
    RenegadeData.new.delete_person(params[:id])
    redirect to("/people"), 302
  end

  # TODO: have some sort of session stuff going on here to display more information
  get '/notfound' do
    @message = "What you are looking for is no longer here."
    erb :notfound
  end

end

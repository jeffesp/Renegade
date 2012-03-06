require 'sequel'
require 'json'

# trying to do the simplest thing here, so using Sequel w/o its model classes, and just 
# doing some raw queries, probably going to hate that in the future. Already a bit.

class RenegadeData

  def initialize
    @DB = Sequel.connect('sqlite://renegade.db')
    @types = { :student => 1, :worker => 2, :parent => 3, :contact => 4, :student_worker => 5 }
  end

  def update_people_for_display(people)
    inverted_types = @types.invert
    people.map do |person|
      type = inverted_types[person[:person_type]]
      person[:type] = type
      if (type == :student)
        person[:grade] = grade_from_birthday(person[:birthdate])
      end
      person.merge(JSON.parse(person[:data]))
    end
  end

  def grade_from_birthday(birth_date)
    # TODO: should be class level 'static' method 
    seconds_per_year = 60 * 60 * 24 * 365.25
    grades = [ "PreK", "K", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "PostHS"]
    age = ((Time.new - birth_date) / seconds_per_year).to_i
    # index calculation
    if (age <= 5)
      grades[0]
    elsif (age > 5 or age < 19)
      grades[age-5]
    else
      grades[15]
    end
  end

  def get_people(filter=nil)
    if (filter == nil)
      update_people_for_display(@DB[:people].all)
    else
      nil
    end
  end

  def find_people(name)
    # simple LIKE filtering for now
    # SQLite does have some sort of full text support, and could use get Sequel to support MATCH
    # this is currently case sensitive! could hack around with lower/upper stuff
    name_lower = "%#{name.downcase}%"
    query = @DB.fetch("SELECT * FROM people WHERE delete_date IS NULL AND (lower(first_name) LIKE ? OR lower(last_name) LIKE ?)", name_lower, name_lower)
    update_people_for_display(query)
  end

  def format_phone(data)
    values = JSON.parse(data)
    if values['phone']
      base_phone = values['phone'].gsub(/[\s\(\).-]+/, "")
      p base_phone
      if base_phone.length == 11
        base_phone = base_phone.slice(1..-1)
      end
      m = base_phone.match(/(\d{3})(\d{3})(\d{4})/)
      values['phone'] = "#{m[1]}-#{m[2]}-#{m[3]}" if m
    end
    values.to_json
  end

  def add_person(params)
    local_params = {
      :first_name => params[:first_name],
      :last_name => params[:last_name],
      :gender => params[:gender],
      :birthdate => params[:birthdate],
      :person_type => @types[params[:type].to_sym],
      :meeting_id => 1,
      :data => format_phone(params[:data]),
      :create_date => Date.today
    }
    @DB[:people].insert(local_params)
  end

  def update_person(params)
    local_params = {
      :id => params[:id],
      :first_name => params[:first_name],
      :last_name => params[:last_name],
      :gender => params[:gender],
      :birthdate => params[:birthdate],
      :person_type => @types[params[:type].to_sym],
      :meeting_id => 1,
      :data => format_phone(params[:data])
    }
    @DB[:people].filter(:id => params['id']).update(local_params)
  end

  def get_person(id)
    update_people_for_display(@DB[:people].filter(:id => id)).first
  end

  def get_meetings
    @DB[:meetings]
  end

  def add_meeting(date)
    @DB[:meetings].insert(
      :date => date
    )
  end

  def get_rosters
    @DB[:rosters].filter('end_date IS NOT NULL')
  end

  # site user stuff
  def get_user(email_address)
    @DB[:users].first(:email_address => email_address)
  end

  def add_user(email_address, password_hash)
    @DB[:users].insert(
      :email_address => email_address,
      :password_hash => password_hash,
      :active => false
    )
  end

  def update_user(old_email_address, new_email_address, password_hash)
    local_params = {
      email_address => new_email_address,
      password_hash => password_hash
    }
    @DB[:users].filter(email_address => old_email_address).update(local_params)
  end

  def deactivate_user(email_address)
    @DB[:users].filter(email_address => email_address).update({ active => false})
  end

end

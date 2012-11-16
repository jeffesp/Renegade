require 'sequel'
require 'json'

# trying to do the simplest thing here, so using Sequel w/o its model classes, and just 
# doing some raw queries, probably going to hate that in the future. Already a bit.

class RenegadeData

  def initialize
    @DB = Sequel.connect('sqlite://data/renegade.db')
    @types = [ "Student", "Worker", "Student Worker" ]
    @grades = [ "PreK", "K", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "PostHS"]
  end

  def update_people_for_display(people_query)
    people = people_query.filter(:delete_date => nil).all
    people.map do |person|
      person[:type] = @types[person[:person_type]]
      if (person[:person_type] < 3)
        person[:grade] = grade_from_birthday(person[:birthdate])
      end
    end
    people
  end

  def grade_from_birthday(birth_date)
    # TODO: should be class level 'static' method 
    if birth_date.nil?
      return "N/A"
    end
    seconds_per_year = 60 * 60 * 24 * 365.25
    age = ((Time.new - birth_date) / seconds_per_year).to_i
    # index calculation
    if (age <= 5)
      @grades[0]
    elsif (age > 5 or age < 19)
      @grades[age-5]
    else
      @grades[15]
    end
  end

  def get_people(filter=nil)
    if (filter == nil)
      set = @DB[:people].limit(5, 0)
      count_set = @DB[:people]
    else
      # because the grade is calculated in this file, first we filter by other critera, get that
      # dataset and then filter the rest here. not the best efficiency, but works for this.

      set = @DB[:people]
      if filter.has_key?('gender')
        set = set.where('gender = ?', filter['gender'])
      end
      if filter.has_key?('role')
        set = set.where('person_type = ?', @types.index(filter['role']) + 1)
      end
      if filter.has_key?('meeting')
        set = set.where('meeting_id = ?', filter['meeting'])
      end

      if filter.has_key?('page')
        count_set = set
        set = set.limit(5, filter['page'].to_i * 5)
      else
        count_set = set
        set = set.limit(5, 0)
      end

    end
    [update_people_for_display(set), count_set.count]
  end

  def find_people(name)
    # simple LIKE filtering for now
    # SQLite does have some sort of full text support, and could use get Sequel to support MATCH
    # TODO: somehow this is interpreted as case sensitive. need to work around with .downcase and lower()
    name_lower = "%#{name.downcase}%"
    query = @DB.fetch("SELECT * FROM people WHERE delete_date IS NULL AND (lower(first_name) LIKE ? OR lower(last_name) LIKE ?)", name_lower, name_lower)
    update_people_for_display(query)
  end

  # changes the values hash to remove the split date (name-date-{y,m,d}) members.
  # replaces them with a value at 'name' that is a Date value of the split members.
  def format_date!(values, name)
    if !values["#{name}-date-y"].empty?
      values[name] = Date.new(values["#{name}-date-y"].to_i, values["#{name}-date-m"].to_i, values["#{name}-date-d"].to_i)
    end
    values.delete_if { |key, value| key.include?("#{name}-date") }
    return values
  end
  # takes the 'phone' element from the values array and changes it to make sure it is formatted ###-###-####
  def format_phone!(values)
    if values['phone']
      base_phone = values['phone'].gsub(/[\s\(\).-]+/, "")
      if base_phone.length == 11
        base_phone = base_phone.slice(1..-1)
      end
      m = base_phone.match(/(\d{3})(\d{3})(\d{4})/)
      values['phone'] = "#{m[1]}-#{m[2]}-#{m[3]}" if m
    end
    return values
  end

  def add_person(params)
    local_params = params.merge({
      'person_type' => params['role'],
      'meeting_id' => params['meeting'].to_i,
      'create_date' => Date.today,
      'id' => nil
    })
    local_params = remove_unneeded_person_keys(local_params)
    @DB[:people].insert(local_params)
  end

  def update_person(params)
    local_params = params.merge({
      'person_type' => params['role'],
      'meeting_id' => params['meeting'].to_i,
    })
    local_params = remove_unneeded_person_keys(local_params)
    @DB[:people].filter(:id => params['id']).update(local_params)
  end

  def remove_unneeded_person_keys(params)
    params.delete('role')
    params.delete('meeting')
    params
  end

  def delete_person(id)
    @DB[:people].filter(:id => id).update(:delete_date => Date.today)
  end

  def get_person(id)
    val = update_people_for_display(@DB[:people].filter(:id => id)).first
    return val
  end

  def get_locations
    @DB[:locations].all
  end

  def get_grades
    @grades
  end

  def get_types
    @types
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

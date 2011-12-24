require 'sequel'

# trying to do the simplest thing here, so using Sequel w/o its model classes, and just 
# doing some raw queries

# TODO: write a wrapper using the sandwich code pattern from koans
# Or, better than that, look at the file open code and see how it accepts
# a block as an argument.

class RenegadeData

  def initialize
    @DB = Sequel.connect('sqlite://renegade.db')
    @types = { :student => 1, :worker => 2, :parent => 3 }
  end

  def get_people(type)
    @DB[:people].filter(:person_type => @types[type])
  end

  def get_class_students(class_id)
    # wow, I am doing 3 joins just to get a student out of their class? maybe I need to review my data model
    @DB[:people].
      filter(:person_type => @types[:student], :delete_date => nil).
        join(:student_roster, :student_id => :id).
        join(:roster, :id => :roster_id).
        join(:class, :id => :class_id).
          filter(:class_id => class_id)
  end

  # active is defined as attended in last 2 months by default
  def get_active_people(last_attendance=(Date.today << 2))
    @DB[:people].filter(:last_attendance > last_attendance, :delete_date => nil)
  end

  def find_people(name)
    # simple LIKE filtering for now
    # SQLite does have some sort of full text support, and could use get Sequel to support MATCH
    @DB[:people].filter(:delete_date => nil).filter(:first_name.like("%{#name}%")).or(:last_name.like("%{#name}%"))
  end

  def add_person(params)
    local_params = {
      :first_name => params['first_name'],
      :last_name => params['last_name'],
      :data => params['data'],
      :person_type => @types[params['type'].to_sym],
      :create_date => Date.today
    }
    @DB[:people].insert(local_params)
  end

  def update_person(params)
    local_params = {
      :id => params['id'],
      :first_name => params['first_name'],
      :last_name => params['last_name'],
      :data => params['data'],
      :person_type => @types[params['type'].to_sym]
    }
    @DB[:people].filter(:id => params['id']).update(local_params)
  end

  def get_person(id, type)
    @DB[:people].filter(:id => id, :delete_date => nil).first
  end

  def add_student(params)
    local_params = params.merge({
      :create_date => Date.today,
      :person_type => @types[:student]
    })
    student_id = @DB[:people].insert(local_params)
    #roster_id = @DB[:rosters].filter('end_date IS NOT NULL AND class_id = ?', class_id).select(:roster_id).first
    #classification = 0 #classification = @DB[:classifications].filter('')
    #@DB[:student_roster].insert( :student_id => student_id, :roster_id => roster_id, :classificatoin => classification)
  end

  def add_worker(first_name, last_name)
    @DB[:people].insert(
      :first_name => first_name,
      :last_name => last_name,
      :create_date => Date.today,
      :person_type => @types[:worker]
    )
  end

  def add_parent(first_name, last_name)
    @DB[:people].insert(
      :first_name => first_name,
      :last_name => last_name,
      :create_date => Date.today,
      :person_type => @types[:parent]
    )
  end

  def add_worker_to_class(class_id)

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

end

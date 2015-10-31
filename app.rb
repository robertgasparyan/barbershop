#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db
  return SQLite3::Database.new  "barber.sqlite"
end

def seed_db db, barbers
  barbers.each do |barber|
    if !is_barber_exists? db, barber
      db.execute "insert into barbers (name) values (?)", [barber]
    end
  end
end


#is barber exists in functionality
def is_barber_exists? db, name
  db.execute("select * from Barbers where name=?", [name]).length > 0
end
#end of is_barber_exists function

configure do
  db = get_db

  seed_db db, ['Jon Michaels', 'Razbery Freeman', 'Morgan Johnson']
end



get '/' do
	erb "Hello World of Mine! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"
end

get '/about' do
  @error = "Something wrong"
  erb :about
end

get '/visit' do
  db = get_db
  db.results_as_hash = true
  @results = db.execute "select * from barbers";
  erb :visit
end

get '/showusers' do

  db = get_db
  db.results_as_hash = true
  @results = db.execute "select * from 'Visits'"
  erb :showusers
end

post '/visit' do
  @user_name = params[:username];
  @user_phone = params[:userphone];
  @user_date = params[:userdate];
  @barbername = params[:barbername]


  if @user_name.empty?
    @error = "Username cannot be empty"
    erb :visit
    elsif @user_phone.empty?
    @error = "Phone number cannot be empty"
    erb :visit
    elsif @user_date.empty?
    @error = "Date cannot be empty"
    erb :visit
    else

    db = get_db
    db.execute "insert into 'Visits' (Name,Phone,Date,Barbername) values (?,?,?,?)", [@user_name, @user_phone, @user_date,@barbername];

    combined_data = "#{@user_name} - #{@user_phone} - #{@user_date} - #{@barbername}\n\n"

    users_file = File.open "public/visits.txt", "a" do |file|
        file.write(combined_data)
        file.write "\n"
    end

  #prepare to sending emails

      @message = "Complete"
      erb :thankyou
  end

end


get '/contacts' do
  erb :contacts
end

get '/thankyou' do
  erb :thankyou
end


require 'sinatra'
require 'data_mapper'
DataMapper.setup(:default, 'sqlite:///'+Dir.pwd+'/project.db')
set :bind, '0.0.0.0'

class User
	include DataMapper::Resource

	property :id, Serial
	property :email, String
	property :password, String
end

class Todo
	include DataMapper::Resource

	property :id,         Serial    
  	property :task,       String    
  	property :done,       Boolean  
  	property :user_id,     Numeric

	# attr_accessor :task, :done
	# def initialize task
	# 	@task = task
	# 	@done = false
	# end
end


DataMapper.finalize
DataMapper.auto_upgrade!

enable :sessions

# get '/' do
# 	puts session
# 	if session[:count].nil?
# 		session[:count] = 1
# 	else
# 		session[:count] = session[:count] + 1
# 	end

# 	erb :index, locals: {count: session[:count]}
# end


get '/' do
	if session[:g].nil?
		return redirect '/signin'
	end
	puts User.all.count
	tasks = Todo.all(user_id: session[:g])
	erb :index, locals: {user_id: session[:g], tasks: tasks}
end

get '/signout' do
	session[:g] = nil
	return redirect '/'
end



get '/signin' do
	erb :signin
end

post '/signin' do
	email = params["email"]
	password = params["password"]

	# users = User.all(email: email)

	# if users.length > 0 
	# 	user = users[0]
	# else
	# 	user = nil
	# end

	user = User.all(email: email).first

	puts user.class

	if user.nil?
		return redirect '/signup'
	else
		if user.password == password
			session[g] = user.id
			return redirect '/'
		else
			return redirect '/signin'
		end

	end

	redirect '/signin'
end



get '/signup' do
	erb :signup
end

post '/signup' do
	email = params["email"]
	password = params["password"]

	user = User.all(email: email).first

	if user
		return redirect '/signup'
	else
		user = User.new
		user.email = email
		user.password = password
		user.save
		session[:g] = user.id
		return redirect '/'
	end
end


post '/add' do
  puts params
  task = params["task"]
  todo = Todo.new
  todo.task = task
  todo.done = false
  todo.user_id = session[:user_id]
  todo.save
  return redirect '/'
end

post '/done' do
	task_id = params["id"].to_i
	todo = Todo.get(task_id)
	todo.done = !todo.done
	todo.save
    return redirect '/'
end



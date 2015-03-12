require 'sinatra' 
require 'sinatra/reloader' if development?
#require 'data_mapper'
require 'sequel'
require 'uri'
require 'pp'
require 'rubygems'
require 'sinatra/flash'
#require './auth.rb'
#require 'chartkick'
#require 'webrick'
require 'bcrypt'

=begin
# Configuracion en local
configure :development, :test do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 
                             "sqlite3://#{Dir.pwd}/my_quiz.db" )
end

# Configuracion para Heroku
configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

DataMapper::Logger.new($stdout, :debug)
DataMapper::Model.raise_on_save_failure = true 

require_relative 'model'

DataMapper.finalize

#DataMapper.auto_migrate!
DataMapper.auto_upgrade!
=end

require_relative 'model'
#DB = Sequel.connect('sqlite://DB.db')
#DB = Sequel.sqlite('my_quiz.db')
#puts "Numero de usuarios: "
#puts DB[:usuarios].count
#DB = Sequel.sqlite('DB.db')


enable :sessions
set :session_secret, '*&(^#234a)'

get '/' do
  #@mipass2 = BCrypt::Password.new('edu')
  @actual =  "inicio"
  #Comprobamos si el usuario no se ha registrado.
  if (!session[:username])
    haml :welcome, :layout => false 
  else
    # Obtenemos los usurios de la tabla usuarios
     @usuarios = DB[:usuarios]
    #@ultimas_rutas = Rutas.all(:limit => 4, :order => [ :created_at.desc ])
    haml :index
  end
end

get '/login' do
  if (!session[:username])
    haml :login, :layout => false
  else
    redirect '/'
  end 
end

post '/login' do
  begin

    @user = DB[:usuarios].first(:username => params[:usuario])
    @user_hash = BCrypt::Password.new(@user[:password])

    if (@user_hash == params[:password])
      puts "Entra en el if"
      #session[:id] = @user[:idUsuario]
      session[:username] = @user[:username]
      session[:nombre] = @user[:nombre]
      session[:apellidos] = @user[:apellidos]
      session[:email] = @user[:email]
      session[:imagen] = @user[:imagen]
    else
      flash[:mensaje] = "El nombre de usuario y/o contraseña no son correctos."
      #puts e.message
    end
  rescue Exception => e
    flash[:mensaje] = "El nombre de usuario y/o contraseña no son correctos."
    puts e.message
  end
  redirect './login'
end

get '/signup' do
  if (!session[:username])
    haml :signup, :layout => false
  else
    redirect '/, :order => [:puntuacion.desc]'
  end
end

post '/signup' do
  puts "inside post '/': #{params}"
  begin
    @usuario = DB[:usuarios].first(:username => params[:usuario])
    if (!@usuario)
      if (params[:imagen] == '')
        imagen = "http://i.imgur.com/lEZ3n1E.jpg"
      else
        imagen = params[:imagen]
      end
      @objeto = DB[:usuarios].insert(:username => params[:usuario], :nombre => params[:nombre], 
                                     :apellidos => params[:apellidos], :email => params[:email], 
                                     :password => BCrypt::Password.create(params[:pass1]), 
                                     :imagen => imagen, :created_at => Time.now)
      session[:username] = params[:usuario]
      session[:nombre] = params[:nombre]
      session[:apellidos] = params[:apellidos]
      session[:email] = params[:email]
      session[:imagen] = imagen
      flash[:mensaje] = "¡Enhorabuena! Se ha registrado correctamente."
    else
      flash[:mensaje] = "El nombre de usuario ya existe. Por favor, elija otro."
      redirect '/signup'
    end
  rescue Exception => e
    puts e.message
  end
  redirect '/'
end

get '/logout' do
  session.clear
  redirect '/'
end
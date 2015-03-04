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
  if (!session[:user])
    haml :welcome, :layout => false 
  else
    # Obtenemos los usurios de la tabla usuarios
     @usuarios = DB[:usuarios]
    #@ultimas_rutas = Rutas.all(:limit => 4, :order => [ :created_at.desc ])
    haml :index
  end
end

get '/login' do
  if (!session[:user])
    haml :login, :layout => false
  else
    redirect '/'
  end 
end
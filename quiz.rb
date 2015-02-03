require 'sinatra' 
require 'sinatra/reloader' if development?
require 'data_mapper'
require 'uri'
require 'pp'
require 'rubygems'
require 'sinatra/flash'
#require './auth.rb'
#require 'chartkick'
#require 'webrick'

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

enable :sessions
set :session_secret, '*&(^#234a)'

get '/' do
  @actual =  "inicio"
  #Comprobamos si el usuario no se ha registrado.
  if (!session[:user])
    haml :welcome, :layout => false 
  else
    # Obtenemos las últimas rutas añadidas
    #@ultimas_rutas = Rutas.all(:limit => 4, :order => [ :created_at.desc ])
    # Obtenemos las rutas más populares
    #@populares_rutas = Rutas.all(:limit => 4, :order => [:puntuacion.desc])
    haml :index
  end
end
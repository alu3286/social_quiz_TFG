require 'bundler/setup'
require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'omniauth-facebook'
require 'pry'
require 'erubis'


#**** AUTENTICACION ****
set :erb, :escape_html => true

use OmniAuth::Builder do
  config = YAML.load_file 'config.yml'
  provider :google_oauth2, config['identifier'], config['secret']
  #provider :facebook, config['identifier_f'], config['secret_f']
end


get '/auth/:name/callback' do
  
  session[:auth] = @auth = request.env['omniauth.auth']
  
  #session[:name] = @auth['info'].name
  nombre_completo = @auth['info'].name.split

  session[:nombre] = nombre_completo[0]
  session[:apellidos] = nombre_completo[1,nombre_completo.length].join(" ")
  session[:imagen] = @auth['info'].image
  
  #session[:username] = nombre_completo[0]
  
  session[:url] = @auth['info'].urls.values[0]
  session[:email] = @auth['info'].email
  session[:logs] = ''

  # Añadir a la base de datos directamente, siempre y cuando no exista
  #if !User.first(:username => session[:email])
  #  u = User.create(:username => session[:email])
  #  u.save
  #end

  redirect '/getUser'
end

get '/auth/failure' do
  flash[:mensajeRojo] = "Fallo en la autenticación. Inténtelo de nuevo más tarde."
  redirect '/'
end
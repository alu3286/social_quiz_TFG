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
require 'haml'

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
      session[:id] = @user[:idUsuario]
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
                                     :imagen => imagen, :fecha_creacion => Time.now)
      session[:username] = params[:usuario]
      session[:nombre] = params[:nombre]
      session[:apellidos] = params[:apellidos]
      session[:email] = params[:email]
      session[:imagen] = imagen
      # Obtenemos el id del usuario para la sesion
      session[:id] = DB[:usuarios].first(:username => params[:usuario])[:idUsuario]

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

get '/preguntas' do
  @actual =  "preguntas"
  if (session[:username])
    @preguntas = DB[:preguntas].where(:idUsuario => session[:id]).order(:fecha_creacion).reverse
    #@preguntas = DB[:preguntas].join_table(:inner, DB[:usuarios], :idUsuario => session[:id])

    haml :quizzes
  else
    redirect '/'
  end
end

post '/preguntas' do
  begin
    # Eliminar la pregunta de la base de datos.
    @objeto = DB[:preguntas].where(:idPregunta => params[:pregunta]).delete
    flash[:mensaje] = "Pregunta eliminada correctamente."

  rescue Exception => e
    puts e.message
    flash[:mensajeRojo] = "No se ha podido eliminar la pregunta. Inténtelo de nuevo más tarde."
  end
  redirect '/preguntas'
end

get '/preguntas/new' do
  @actual = "preguntas"
  if (session[:username])
    haml :newQuiz
  else
    redirect '/'
  end
end

post '/preguntas/new' do
  begin
    puts params
    
    # Añadir la pregunta a la base de datos
    @objeto = DB[:preguntas].insert(:titulo => params[:titulo], :fecha_creacion => Time.now, 
                                    :idUsuario => session[:id])
    
    # Añadimos la respuesta a la base de datos
    case params[:tipo]
    when "vf"
      # consulta de verdadero falso a la bbdd
      correct = (params[:opciones] == "true") ? 1 : 0
      puts correct
      @objeto1 = DB[:respuestas].insert(:texto => "", :correcto => correct, 
                                        :tipo => "vf", :idPregunta => @objeto)
    when "corta"
      # consulta de respuesta corta a la bbdd
      @objeto1 = DB[:respuestas].insert(:texto => params[:corta], :correcto => true, 
                                        :tipo => "corta", :idPregunta => @objeto)
    when "multiple"
      #consulta de respuesta multiple a la bbdd
    end
  
    flash[:mensaje] = "Pregunta creada correctamente."

  rescue Exception => e
    puts e.message
    flash[:mensajeRojo] = "No se ha podido crear la pregunta. Inténtelo de nuevo más tarde."
  end
  redirect '/preguntas'
end

#post 'preguntas/delete' do
#  begin
#    puts "Entramos en el borrado de preguntas yeah!!!"
#
#  rescue Exception => e
#    puts e.message
#  end
#end

get '/examenes' do
  if (session[:username])

  else
    redirect '/'
  end
end

get '/calificaciones' do
  if (session[:username])

  else
    redirect '/'
  end
end

get '/configuracion' do
  if (session[:username])

  else
    redirect '/'
  end
end

get '/logout' do
  session.clear
  redirect '/'
end
require 'sinatra' 
require 'sinatra/reloader' if development?
#require 'data_mapper'
#require 'sequel'
require 'sinatra/sequel'
require 'uri'
require 'pp'
require 'rubygems'
require 'sinatra/flash'
#require './auth.rb'
#require 'chartkick'
#require 'webrick'
require 'bcrypt'
require 'haml'

require 'json'

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
                                    :tags =>params[:tags], :idUsuario => session[:id])
    
    # Añadimos la respuesta a la base de datos
    case params[:tipo]
    when "vf"
      # consulta de verdadero falso a la bbdd
      correct = (params[:opciones] == "true") ? 1 : 0
      #puts correct
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

get '/pregunta/:num' do
  @actual =  "preguntas"
  if (session[:username])

    @pregunta = DB[:preguntas].where(:idUsuario => session[:id], :idPregunta => params[:num])
    @respuesta = DB[:respuestas].where(:idPregunta => params[:num])

    #puts "este es el tipo"
    #puts @respuesta[:idRespuesta][:tipo]

    #puts "Este es el titulo"
    #puts @pregunta[:idPregunta][:titulo]

    haml :quizView
  else
    redirect '/'
  end
end

post '/pregunta/:num' do
  begin
    puts params
    
    # Actualizamos la pregunta
    update_pregunta = DB["UPDATE preguntas set titulo = ?, fecha_creacion = ?, tags = ? 
                         WHERE idPregunta = ?", params[:titulo], Time.now, params[:tags], params[:num]]
    update_pregunta.update
    
    # Actualizamos la respuesta
    case params[:tipo]
    when "vf"
      # consulta de verdadero falso a la bbdd
      correct = (params[:opciones] == "true") ? 1 : 0
      update_respuesta = DB["UPDATE respuestas set correcto = ?, tipo = ? WHERE idPregunta = ?", 
                            correct, 'vf', params[:num]]
      update_respuesta.update
    when "corta"
      # consulta de respuesta corta a la bbdd
      update_respuesta = DB["UPDATE respuestas set texto = ?, correcto = ?, tipo = ? WHERE idPregunta = ?", 
                            params[:corta], true, 'corta', params[:num]]
      update_respuesta.update
    when "multiple"
      #consulta de respuesta multiple a la bbdd
    end
  
    flash[:mensaje] = "Pregunta actualizada correctamente."

  rescue Exception => e
    puts e.message
    flash[:mensajeRojo] = "No se ha podido modificar la pregunta. Inténtelo de nuevo más tarde."
  end
  redirect '/preguntas'
end

get '/examenes' do
  @actual =  "examenes"
  if (session[:username])
    @examenes = DB[:examenes].where(:idUsuario => session[:id]).order(:fecha_creacion).reverse

    haml :exams
  else
    redirect '/'
  end
end

get '/examenes/new' do
  @actual = "examenes"
  if (session[:username])

    # Obtenemos el listado de preguntas de ese usuario
    @preguntas = DB[:preguntas].where(:idUsuario => session[:id]).order(:fecha_creacion).reverse

    #Obtenemos los usuarios para la lista de usuarios y grupos
    @usuarios = DB["SELECT * FROM usuarios WHERE idUsuario != #{session[:id]}"]

    #Obtenemos la lista de grupos
    @grupos = DB["SELECT * FROM grupos WHERE idUsuario = #{session[:id]}"]

    haml :newExam
  else
    redirect '/'
  end
end

post '/examenes/new' do
  begin
    puts params
    mi_ids = params[:ids].split(',')
    #puts mi_ids


    puts params[:fecha_apertura].class
    puts params[:fecha_cierre]

    # Añadir la pregunta a la base de datos
    @objeto = DB[:examenes].insert(:titulo => params[:titulo], :fecha_creacion => Time.now,
                                   :fecha_apertura => DateTime.parse(params[:fecha_apertura]), 
                                   :fecha_cierre => DateTime.parse(params[:fecha_cierre]),
                                   :idUsuario => session[:id])

    # Introduzco tantos registros como preguntas tenga
    mi_ids.each do |id|
      @objeto2 = DB[:examen_pregunta].insert(:idExamen => @objeto, :idPregunta => id,
                                             :peso => 1.0, :obligatoria => 1)
    end
  
    flash[:mensaje] = "Examen creado correctamente."

  rescue Exception => e
    puts e.message
    flash[:mensajeRojo] = "No se ha podido crear el examen. Inténtelo de nuevo más tarde."
  end
  redirect '/examenes'
end

post '/examenes/redireccion' do
  begin
    flash[:mensaje] =  "Examen creado correctamente."
    redirect '/examenes' 
  end
end

post '/grupos/redireccion' do
  begin
    flash[:mensaje] =  "Usuarios modificados correctamente."
    redirect '/grupos' 
  end
end

get '/examen/:num' do
  @actual =  "examenes"
  if (session[:username])

    @examen = DB[:examenes].where(:idExamen => params[:num])
    @preguntas = DB["SELECT * FROM preguntas INNER JOIN examen_pregunta ON preguntas.idPregunta = examen_pregunta.idPregunta AND examen_pregunta.idExamen = ?", params[:num]]
    #@preguntas = DB[:preguntas].join_table(:inner, :examen_pregunta, :idPregunta => :idPregunta)
    #@respuestas = @preguntas.join_table(:inner, :respuestas, :idPregunta => :idPregunta).as(:respuestas, :re)

    #Sequel.as(:table, :alias, [:c1, :c2]) # "table" AS "alias"("c1", "c2")

    #@preguntas = DB[:examen_pregunta].where(:idPregunta => params[:num])
    #@respuesta = DB[:respuestas].where(:idPregunta => params[:num])

    

    haml :examView
  else
    redirect '/'
  end
end

post '/eliminaExamen' do
  begin
    puts "Estamos en la eliminacion de examenes"
    puts params
    #mi_ids = params[:ids].split(',')
    #puts mi_ids

    @exapre_detele = DB[:examen_pregunta].filter(:idExamen => params[:ids]).delete
    @examen_detele = DB[:examenes].filter(:idExamen => params[:ids]).delete

    # Añadir la pregunta a la base de datos
    #@objeto = DB[:examenes].insert(:titulo => params[:titulo], :fecha_creacion => Time.now,
    #                               :fecha_apertura => DateTime.parse(params[:fecha_apertura]), 
    #                               :fecha_cierre => DateTime.parse(params[:fecha_cierre]),
    #                               :idUsuario => session[:id])

    # Introduzco tantos registros como preguntas tenga
    #mi_ids.each do |id|
    #  @objeto2 = DB[:examen_pregunta].insert(:idExamen => @objeto, :idPregunta => id,
    #                                         :peso => 1.0, :obligatoria => 1)
    #end
  
    flash[:mensaje] = "Examen eliminado correctamente."

  rescue Exception => e
    puts e.message
    flash[:mensajeRojo] = "No se ha podido eliminar el examen. Inténtelo de nuevo más tarde."
  end
  redirect '/examenes'
end

post '/eliminaPregunta' do
  begin
    puts "Estamos en la eliminacion de preguntas"
    puts params
    #mi_ids = params[:ids].split(',')
    #puts mi_ids

    @exapre_detele = DB[:examen_pregunta].filter(:idPregunta => params[:ids]).delete
    @resp_delete = DB[:respuestas].filter(:idPregunta => params[:ids]).delete
    @pregunta_detele = DB[:preguntas].filter(:idPregunta => params[:ids]).delete

    
  
    flash[:mensaje] = "Pregunta eliminada correctamente."

  rescue Exception => e
    puts e.message
    flash[:mensajeRojo] = "No se ha podido eliminar la pregunta. Inténtelo de nuevo más tarde."
  end
  redirect '/preguntas'
end

post '/dameRespuesta' do
  #puts "Estamos en dameRespuesta"
  #puts params

    @respuesta = DB["SELECT * FROM respuestas 
                    where idPregunta = #{params[:ids]}"]
    
    #my_hash = {:hello => "goodbye"}
    #puts JSON.generate(my_hash) => "{\"hello\":\"goodbye\"}"
    #grades["Dorothy Doe"] = 9
    @resp = Hash.new
    @resp['tipo'] = @respuesta[:idRespuesta][:tipo]
    @resp['texto'] = @respuesta[:idRespuesta][:texto]
    @resp['correcto'] = @respuesta[:idRespuesta][:correcto]
    @resp = JSON.generate(@resp)
    @resp
end



get '/grupos' do
  @actual = "grupos"
  if (session[:username])

    @grupos = DB["SELECT * FROM grupos WHERE idUsuario = #{session[:id]}"]
    @usuarios_grupos = DB["SELECT * FROM grupos g inner join usuario_grupo ug on g.idGrupo = ug.idGrupo 
                          inner join usuarios u on ug.idUsuario = u.idUsuario 
                          where g.idUsuario = #{session[:id]}"]

    haml :groups
  else
    redirect '/'
  end
end

# post '/grupos' do
#   begin
#     puts "Estas de vuelta en grupos"
#     puts params

# #     # Añadir la pregunta a la base de datos
# #     @usu_gr = DB["SELECT ug.idUsuario FROM usuario_grupo ug INNER JOIN grupos g on ug.idGrupo = g.idGrupo 
# #                   WHERE g.idUsuario = #{session[:id]} AND
# #                   g.idGrupo = #{params[:id]}"]

# #     @usu_gr
  
# #     #flash[:mensaje] = ""

# #   rescue Exception => e
# #     puts e.message
# #     flash[:mensajeRojo] = "No se ha podido crear el grupo. Inténtelo de nuevo más tarde."
#   end
# #   redirect '/grupos/miembros'
# end


get '/grupos/new' do
  @actual = "grupos"
  if (session[:username])

    haml :newGroup
  else
    redirect '/'
  end
end

post '/grupos/new' do
  begin
    puts "Parametros nuevo grupo"
    puts params

    # Añadir la pregunta a la base de datos
    @objeto = DB[:grupos].insert(:nombre => params[:nombre], :descripcion => params[:desc],
                                 :fecha_creacion => Time.now, :idUsuario => session[:id])
  
    flash[:mensaje] = "Grupo creado correctamente."

  rescue Exception => e
    puts e.message
    flash[:mensajeRojo] = "No se ha podido crear el grupo. Inténtelo de nuevo más tarde."
  end
  redirect '/grupos'
end

post '/dameusuarios' do
  #puts params
  #puts params[:id]

    @usuarios_finales = DB["SELECT ug.idUsuario, u.username FROM grupos g inner join usuario_grupo ug on g.idGrupo = ug.idGrupo 
                           inner join usuarios u on ug.idUsuario = u.idUsuario 
                           where g.idUsuario = #{session[:id]} AND
                           g.idGrupo = #{params[:id]}"]

    #session[:grupo] = params[:id]
    #puts "esta es mi session"
    #puts session[:grupo]
    
    #my_hash = {:hello => "goodbye"}
    #puts JSON.generate(my_hash) => "{\"hello\":\"goodbye\"}"
    #grades["Dorothy Doe"] = 9
    @us_fin = Hash.new
    @usuarios_finales.each do |us|
      @us_fin["#{us[:idUsuario]}"] = "#{us[:username]}"
    end
    @us_fin = JSON.generate(@us_fin)
    @us_fin
end

get '/grupos/miembros/:num' do
  @actual = "grupos"
  if (session[:username])
    
    puts "Estoy en grupos miembros"
    puts params
    
    @usuarios_grupo = DB["SELECT u.idUsuario, u.username FROM grupos g 
                         inner join usuario_grupo ug on g.idGrupo = ug.idGrupo 
                         inner join usuarios u on ug.idUsuario = u.idUsuario 
                         where g.idUsuario = #{session[:id]} AND
                         g.idGrupo = #{params[:num]}"]
    @usuarios = DB["Select * from usuarios usu1 where not exists (SELECT u.idUsuario, u.username FROM grupos g 
                   inner join usuario_grupo ug on g.idGrupo = ug.idGrupo 
                   inner join usuarios u on ug.idUsuario = u.idUsuario 
                   where g.idUsuario = #{session[:id]} AND
                   g.idGrupo = #{params[:num]} AND
                   usu1.idUsuario = u.idUsuario)"]
    @grupo = DB["SELECT * FROM grupos WHERE idGrupo = #{params[:num]}"]


    haml :members
  else
    redirect '/'
  end
end

post '/grupos/miembros/:num' do
  begin
    puts params

    if !params[:ids].nil?
      mi_ids = params[:ids].split(',')
    end


    # 1. Elimino todos los usuarios del grupo
    @usu_grupo_detele = DB[:usuario_grupo].filter(:idGrupo => params[:num]).delete

    # 2. Inserto los usuarios en ese grupo
    mi_ids.each do |usu|
      #Comprobamos que el usuario ya está en la base de datos.
      #@usuario_grupo = DB["SELECT ug.idUsuario FROM usuario_grupo ug 
      #                     where ug.idGrupo = #{params[:num]} AND
      #                     ug.idUsuario = #{usu}"]
      #puts "Este es el contenido de la variable"
      #puts @usuario_grupo.count
      
      #if (@usuario_grupo.count == 0)
      @objeto = DB[:usuario_grupo].insert(:idGrupo => params[:num], :idUsuario => usu)
      #end
    end
    
      flash[:mensaje] = "Usuarios modificados correctamente."

  rescue Exception => e
    puts e.message
    flash[:mensajeRojo] = "No se ha podido realizar la operación. Inténtelo de nuevo más tarde."
  end
  redirect '/grupos'

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
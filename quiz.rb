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

#require './auth.rb'

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

require_relative 'auth'

require_relative 'model'

set :environment, :production


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
    @preguntas = DB[:preguntas].where(:idUsuario => session[:id]).count
    @examenes = DB[:examenes].where(:idUsuario => session[:id]).count
    @grupos = DB[:grupos].where(:idUsuario => session[:id]).count
    @examen_realizar = DB[:usuario_examen].where(:idUsuario => session[:id]).count

    #puts "Probando nueva consulta count"
    #puts @preguntas

    #@preguntas = DB["SELECT count(idUsuario) FROM preguntas WHERE idUsuario = #{session[:id]}"]
    #@examenes = DB["SELECT count(idUsuario) FROM examenes WHERE idUsuario = #{session[:id]}"]
    #@grupos = DB["SELECT count(idUsuario) FROM grupos WHERE idUsuario = #{session[:id]}"]
    #puts @preguntas[:idUsuario][:"count(idUsuario)"]
    
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

# Usados para autenticación mediante OAuth -------------------
get '/getUser' do
  begin
    # Comprobamos si existe ese email en la base de datos
    @usuario = DB[:usuarios].first(:email => session[:email])
    
    if (!@usuario)
      puts "en el if"
      haml :loginUser, :layout => false
    else
      puts "en el else"

      session[:username] = @usuario[:username]
      session[:nombre] = @usuario[:nombre]
      session[:apellidos] = @usuario[:apellidos]      
      session[:email] = @usuario[:email]
      session[:imagen] = @usuario[:imagen]
      session[:id] = @usuario[:id]
      
      redirect '/'
    end 
  rescue Exception => e
    flash[:mensaje] = "El nombre de usuario y/o contraseña no son correctos."
    puts e.message  
  end
end

post '/getUser' do
  begin
    @usuario = DB[:usuarios].first(:username => params[:usuario])
    if (!@usuario)
      @objeto = DB[:usuarios].insert(:username => params[:username], :nombre => session[:nombre], 
                                     :apellidos => session[:apellidos], :imagen => session[:imagen], 
                                     :email => session[:email], :fecha_creacion => Time.now)
      #session[:nombre] = session[:nombre]
      #session[:apellidos] = session[:apellidos]
      #session[:imagen] = session[:imagen]
      session[:username] = params[:username]
      session[:id] = DB[:usuarios].first(:username => params[:username])[:idUsuario]
      puts "Esta es mi session id"
      puts session[:id]

      flash[:mensaje] = "¡Enhorabuena! Se ha registrado correctamente."
    else
      puts "Muestra mensaje rojo"
      flash[:mensajeRojo] = "El nombre de usuario ya existe. Por favor, elija otro."
      redirect '/getUser'
    end
  rescue Exception => e
    puts e.message
  end
  redirect '/'
end
# Fin OAuth -----------------------------------------------

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
      correct = (params[:opciones] == "true") ? true : false
      #puts correct
      @objeto1 = DB[:respuestas].insert(:texto => "", :correcto => correct, 
                                        :tipo => "vf", :idPregunta => @objeto)
    when "corta"
      # consulta de respuesta corta a la bbdd
      @objeto1 = DB[:respuestas].insert(:texto => params[:corta], :correcto => true, 
                                        :tipo => "corta", :idPregunta => @objeto)
    when "expReg"
      #consulta de respuesta regExp a la bbdd
       @objeto1 = DB[:respuestas].insert(:texto => params[:expReg], :correcto => true, 
                                        :tipo => "expReg", :idPregunta => @objeto)
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

    @pregunta = DB[:preguntas].first(:idPregunta => params[:num])
    @respuesta = DB[:respuestas].first(:idPregunta => params[:num])

    #puts "este es el tipo"
    #puts @respuesta[:idRespuesta][:tipo]

    #puts "Este es el titulo"
    #puts @pregunta[:idPregunta][:titulo]

    haml :editQuiz
  else
    redirect '/'
  end
end

post '/pregunta/:num' do
  begin
    puts params
    
    # Actualizamos la pregunta
    update_pregunta = DB[:preguntas].where(:idPregunta => params[:num])
                                    .update(:titulo => params[:titulo],
                                            :fecha_creacion => Time.now,
                                            :tags => params[:tags])
    # Actualizamos la respuesta
    case params[:tipo]
    when "vf"
      # consulta de verdadero falso a la bbdd
      correct = (params[:opciones] == "true") ? 1 : 0
      update_respuesta = DB[:respuestas].where(:idPregunta => params[:num])
                                        .update(:correcto => correct,
                                                :tipo => 'vf')
    when "corta"
      # consulta de respuesta corta a la bbdd
      update_respuesta = DB[:respuestas].where(:idPregunta => params[:num])
                                        .update(:texto => params[:corta],
                                                :correcto => true,
                                                :tipo => 'corta')
    when "expReg"
      #consulta de expresión regular a la bbdd
      update_respuesta = DB[:respuestas].where(:idPregunta => params[:num])
                                        .update(:texto => params[:expReg],
                                                :correcto => true,
                                                :tipo => 'expReg')
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

    @examen_realizar = DB[:usuario_examen].join(:examenes, :idExamen => :idExamen)
                                          .where(:usuario_examen__idUsuario => session[:id])

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
    #@usuarios = DB["SELECT * FROM usuarios WHERE idUsuario != #{session[:id]}"]
    @usuarios = DB[:usuarios].exclude(:idUsuario => session[:id])

    #Obtenemos la lista de grupos
    #@grupos = DB["SELECT * FROM grupos WHERE idUsuario = #{session[:id]}"]
    @grupos = DB[:grupos].where(:idUsuario => session[:id])

    haml :newExam
  else
    redirect '/'
  end
end

post '/examenes/new' do
  begin
    puts params

    # Añadir el examen a la base de datos
    @objeto = DB[:examenes].insert(:titulo => params[:titulo], :fecha_creacion => Time.now,
                                   :fecha_apertura => DateTime.parse(params[:fecha_apertura],"%Y-%m-%d %H:%M"),
                                   :fecha_cierre => DateTime.parse(params[:fecha_cierre],"%Y-%m-%d %H:%M"),
                                   :idUsuario => session[:id])

    # Introduzco tantos registros como preguntas tenga
    if !params[:ids].nil?
      mi_ids = params[:ids].split(',')
      #puts mi_ids
      mi_ids.each do |id|
        @objeto2 = DB[:examen_pregunta].insert(:idExamen => @objeto, :idPregunta => id,
                                               :peso => 1.0, :obligatoria => 1)
      end
    end

    # Enlazar los usuarios con el examen
    if !params[:usuarios].nil?
      mi_usuarios = params[:usuarios].split(',')
      mi_usuarios.each do |id|
        @objeto3 = DB[:usuario_examen].insert(:idUsuario =>id, :idExamen => @objeto, :intento => 0,
                                              :tiempo => Time.now, :nota => 0, :numero_fallo => 0, 
                                              :puntuacion => 0, :titulo => '', :fecha => Time.now)
      end
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
    flash[:mensaje] =  "Examen modificado correctamente."
    redirect '/examenes' 
  end
end

post '/grupos/redireccion' do
  begin
    puts "Estamos en redireccion"
    flash[:mensaje] =  "Usuarios modificados correctamente."
    redirect '/grupos' 
  end
end

get '/examen/:num' do
  @actual =  "examenes"

  if (session[:username])

    #SELECT * FROM examenes AS e 
    #INNER JOIN examen_pregunta AS ep ON ep."idExamen" = e."idExamen" 
    #INNER JOIN preguntas AS p ON p."idPregunta" = ep."idPregunta" 
    #WHERE e."idExamen" = 2
    @examen = DB[:examenes].first(:idExamen => params[:num]) 
    @preguntas = DB[:examenes].join(:examen_pregunta, :idExamen => :idExamen)
                              .join(:preguntas, :idPregunta => :idPregunta)
                              .where(:examenes__idExamen => params[:num])
    @otras = DB[:preguntas].select(:preguntas__idPregunta,:preguntas__titulo,:preguntas__fecha_creacion,
                                   :preguntas__tags,:preguntas__idUsuario)
                           .join(:examen_pregunta, :idPregunta => :idPregunta)
                           .where(:preguntas__idUsuario => session[:id])
                           .where(:examen_pregunta__idExamen => params[:num])
    
    @preguntas_otras = DB[:preguntas].except(@otras)


    #Obtenemos los usuarios que están asociados a ese examen
    @usuarios = DB[:usuarios].exclude(:idUsuario => session[:id])
    @usuarios_examen = DB[:usuarios].join(:usuario_examen, :idUsuario => :idUsuario)
                                    .where(:idExamen => params[:num])
    @usuarios_examen.each do |usr|
      @usuarios = @usuarios.exclude(:idUsuario => usr[:idUsuario])
    end

    @grupos = DB[:grupos].where(:idUsuario => session[:id])
    
    #Obtenemos el número de usuarios de un grupo
    # PENDIENTE --> para mostrar el número de usuarios de ese grupo

    haml :editExam
  else
    redirect '/'
  end
end

post '/examen/:num' do
  begin
    puts params
    
    # Actualizamos el examen
    @examen = DB[:examenes].where(:idExamen => params[:num])
                           .update(:titulo => params[:titulo],
                                   :fecha_creacion => Time.now,
                                   :fecha_apertura => DateTime.parse(params[:fecha_apertura],"%Y-%m-%d %H:%M"),
                                   :fecha_cierre => DateTime.parse(params[:fecha_cierre],"%Y-%m-%d %H:%M"))
    # Actualizamos las preguntas del examen
    # 1. Eliminamos todas las preguntas de la tabla
    @preg_exam_detele = DB[:examen_pregunta].filter(:idExamen => params[:num]).delete

    # 2. Añadimos las preguntas seleccinadas
    if !params[:ids].nil?
      mi_ids = params[:ids].split(',')
      mi_ids.each do |pregunta| 
        @objeto = DB[:examen_pregunta].insert(:peso => 1, :obligatoria => 1, 
                                              :idExamen => params[:num], 
                                              :idPregunta => pregunta)
      end
    end

    # Gestión de usuarios y grupos para los exámenes -------
    @examen_usuarios_delete = DB[:usuario_examen].filter(:idExamen => params[:num]).delete

    # Enlazar los usuarios de un grupo con el examen
    if !params[:grupos].nil?
      mi_grps = params[:grupos].split(',')
      mi_grps.each do |grp| 
        # Obtener todos los usuarios de ese grupo
        @usrs = DB[:usuario_grupo].filter(:idGrupo => grp)
        @usrs.each do |us|
          @objeto2 = DB[:usuario_examen].insert(:idUsuario => us[:idUsuario], :idExamen => @objeto, :intento => 0,
                                                :tiempo => Time.now, :nota => 0, :numero_fallo => 0, 
                                                :puntuacion => 0, :titulo => '', :fecha => Time.now)
        end
      end
    end

    # Enlazar los usuarios con el examen
    if !params[:usuarios].nil?
      mi_usuarios = params[:usuarios].split(',')

      # Hay que comprobar que estos usuarios no estan ya introducidos por los grupos
      # comprobamos la variable params[:grupos] y luego más comprobaciones...


      mi_usuarios.each do |id|
        @objeto3 = DB[:usuario_examen].insert(:idUsuario =>id, :idExamen => @objeto, :intento => 0,
                                              :tiempo => Time.now, :nota => 0, :numero_fallo => 0, 
                                              :puntuacion => 0, :titulo => '', :fecha => Time.now)
      end
    end

    # ------------------------------------------------------
  
    flash[:mensaje] = "Examen modificado correctamente."

  rescue Exception => e
    puts e.message
    flash[:mensajeRojo] = "No se ha podido modificar el examen. Inténtelo de nuevo más tarde."
  end
  redirect '/examenes'
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
    puts "Estamos en dameRespuesta"
    puts params

    #@respuesta = DB["SELECT * FROM respuestas 
    #                where idPregunta = #{params[:ids]}"]
    @respuesta = DB[:respuestas].first(:idPregunta => params[:ids])
    puts "Dame respuesta"
    puts @respuesta[:idPregunta]
    
    #my_hash = {:hello => "goodbye"}
    #puts JSON.generate(my_hash) => "{\"hello\":\"goodbye\"}"
    #grades["Dorothy Doe"] = 9
    @resp = Hash.new
    @resp['tipo'] = @respuesta[:tipo]
    @resp['texto'] = @respuesta[:texto]
    @resp['correcto'] = @respuesta[:correcto]
    @resp = JSON.generate(@resp)
    @resp
end

# Devuelve las preguntas de un examen dado y sus respuestas.
post '/damePreguntasExamen' do
  #puts "Estamos en dameRespuesta"
  #puts params
  class Sequel::Dataset
    def to_json
      naked.all.to_json
    end
  end

  # @preguntasExamen = DB["SELECT e.idExamen, e.titulo, e.fecha_creacion, e.fecha_apertura, 
  #                       e.fecha_cierre, p.idPregunta, p.titulo, p.fecha_creacion, p.tags, 
  #                       r.idRespuesta, r.tipo, r.texto, r.correcto, r.idPregunta 
  #                       FROM examenes e 
  #                       INNER JOIN examen_pregunta ep ON e.idExamen = ep.idExamen 
  #                       INNER JOIN preguntas p ON p.idPregunta = ep.idPregunta 
  #                       INNER JOIN respuestas r ON p.idPregunta = r.idPregunta 
  #                       WHERE e.idExamen = #{params[:ids]}"]
  @preguntasExamen = DB[:examenes].join(:examen_pregunta, :idExamen => :idExamen)
                                  .join(:preguntas, :idPregunta => :idPregunta)
                                  .join(:respuestas, :idPregunta => :idPregunta)
                                  .where(:examenes__idExamen => params[:ids])

  @preguntasExamen.to_json
end

# Devuelve las preguntas de un examen dado y sus respuestas.
post '/damePreguntasExamenCalificacion' do
  #puts "Estamos en dameRespuesta"
  #puts params
  class Sequel::Dataset
    def to_json
      naked.all.to_json
    end
  end

  # SELECT * FROM examenes e INNER JOIN examen_pregunta ep ON ep."idExamen" = e."idExamen"
  #                        INNER JOIN preguntas p ON p."idPregunta" = ep."idPregunta"
  #                        INNER JOIN respuestas r ON r."idPregunta" = p."idPregunta"
  #                        INNER JOIN usuario_examen_respuesta uer ON e."idExamen" = uer."idExamen" AND uer."idPregunta" = p."idPregunta"
  #                        WHERE e."idExamen" = 1
  @preguntasExamen = DB[:examenes].select(:preguntas__titulo, :respuestas__tipo, :respuestas__texto___textoRespuesta, 
                                          :respuestas__correcto,
                                          :usuario_examen_respuesta__texto___textoUsuario,
                                          :usuario_examen_respuesta__correcto___correctoUsuario)
                                  .join(:examen_pregunta, :idExamen => :idExamen)
                                  .join(:usuario_examen_respuesta, :idExamen => :idExamen, :idPregunta => :idPregunta)
                                  .join(:preguntas, :idPregunta => :idPregunta)
                                  .join(:respuestas, :idPregunta => :idPregunta)
                                  .where(:examenes__idExamen => params[:ids])
  puts "Estas son las columnas finales"
  puts @preguntasExamen.to_json
  @preguntasExamen.to_json
end



get '/grupos' do
  @actual = "grupos"
  if (session[:username])

    @grupos = DB[:grupos].where(:idUsuario => session[:id])
    #@usuarios_grupos = DB["SELECT * FROM grupos g inner join usuario_grupo ug on g.idGrupo = ug.idGrupo 
    #                      inner join usuarios u on ug.idUsuario = u.idUsuario 
    #                      where g.idUsuario = #{session[:id]}"]
    @usuarios_grupos = DB[:grupos].join(:usuario_grupos, :idGrupo => :idGrupo).join(:usuarios, :idUsuario => :idUsuario).where(:idUsuario => session[:id])

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

get '/grupo/:num' do
  @actual = "grupos"
  if (session[:username])
    @grupo = DB[:grupos].first(:idGrupo => params[:num], :idUsuario => session[:id])

    #if @grupo.nil?
    #  redirect '/grupos'
    #else
    #  haml :editGroup
    #end
    haml :editGroup

  else
    redirect '/'
  end
end

post '/grupo/:num' do
  begin
    puts params

    # Actualizamos el examen
    @examen = DB[:grupos].where(:idGrupo => params[:num])
                         .update(:nombre => params[:nombre],
                                 :descripcion => params[:descripcion])

    flash[:mensaje] = "Grupo actualizado correctamente."

  rescue Exception => e
    puts e.message
    flash[:mensajeRojo] = "No se ha podido actualizar el grupo. Inténtelo de nuevo más tarde."
  end
  redirect '/grupos'
end

post '/eliminaGrupo' do
  begin
    puts "Estamos en la eliminacion de grupos"
    puts params
    #mi_ids = params[:ids].split(',')
    #puts mi_ids

    # Eliminar todos los usuarios de ese grupo
    @usu_grupo_detele = DB[:usuario_grupo].filter(:idGrupo => params[:ids]).delete
    # Eliminar el grupo
    @grupo_delete = DB[:grupos].filter(:idGrupo => params[:ids]).delete
  
    flash[:mensaje] = "Grupo eliminado correctamente."

  rescue Exception => e
    puts e.message
    flash[:mensajeRojo] = "No se ha podido eliminar el grupo. Inténtelo de nuevo más tarde."
  end
  redirect '/grupos'
end

post '/dameusuarios' do
  #puts params
  #puts params[:id]

    #@usuarios_finales = DB["SELECT ug.idUsuario, u.username FROM grupos g inner join usuario_grupo ug on g.idGrupo = ug.idGrupo 
    #                       inner join usuarios u on ug.idUsuario = u.idUsuario 
    #                       where g.idUsuario = #{session[:id]} AND
    #                       g.idGrupo = #{params[:id]}"]
    @usuarios_finales = DB[:grupos].join(:usuario_grupo, :idGrupo => :idGrupo).join(:usuarios, :idUsuario => :idUsuario).where(:grupos__idUsuario => session[:id]).where(:grupos__idGrupo => params[:id])

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
    puts @us_fin
    @us_fin
end

get '/grupos/miembros/:num' do
  @actual = "grupos"
  if (session[:username])
    
    puts "Estoy en grupos miembros"
    puts params
    
    #@usuarios_grupo = DB["SELECT u.idUsuario, u.username FROM grupos g 
    #                     inner join usuario_grupo ug on g.idGrupo = ug.idGrupo 
    #                     inner join usuarios u on ug.idUsuario = u.idUsuario 
    #                     where g.idUsuario = #{session[:id]} AND
    #                     g.idGrupo = #{params[:num]}"]
    @usuarios_grupo = DB[:grupos].select(:usuarios__idUsuario, :usuarios__username)
                                 .join(:usuario_grupo, :idGrupo => :idGrupo)
                                 .join(:usuarios, :idUsuario => :idUsuario)
                                 .where(:grupos__idUsuario => session[:id])
                                 .where(:grupos__idGrupo => params[:num])
    #------------------------------
    #@usuarios = DB["Select * from usuarios usu1 where not exists (SELECT u.idUsuario, u.username FROM grupos g 
    #               inner join usuario_grupo ug on g.idGrupo = ug.idGrupo 
    #               inner join usuarios u on ug.idUsuario = u.idUsuario 
    #               where g.idUsuario = #{session[:id]} AND
    #               g.idGrupo = #{params[:num]} AND
    #               usu1.idUsuario = u.idUsuario)"]

    #@usuarios = DB[:usuarios]
    @usuarios_g = DB[:grupos].select(:usuarios__idUsuario,:usuarios__nombre,:usuarios__apellidos,
                                     :usuarios__username,:usuarios__email,:usuarios__imagen,
                                     :usuarios__password,:usuarios__fecha_creacion)
                                    .join(:usuario_grupo, :idGrupo => :idGrupo)
                                    .join(:usuarios, :idUsuario => :idUsuario)
                                    .where(:grupos__idUsuario => session[:id])
                                    .where(:grupos__idGrupo => params[:num])
    @usuarios = DB[:usuarios].except(@usuarios_g)
    #------------------------------

    #@grupo = DB["SELECT * FROM grupos WHERE idGrupo = #{params[:num]}"]
    @grupo = DB[:grupos].first(:idGrupo => "#{params[:num]}")

    haml :members
  else
    redirect '/'
  end
end

post '/grupos/miembros/:num' do
  begin
    puts "Estoy en post grupos miembros"
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

# Realización de un examen --------------------------------------
get '/examen/realizar/:num' do
  @actual = "examenes"
  if (session[:username])
    #puts params

    # Añadimos +1 de intento al usuario en el examen :num
    @update_usu_exa = DB[:usuario_examen].where(:idExamen => params[:num]).where(:idUsuario => session[:id])
    @update_usu_exa.update(:intento => "#{@update_usu_exa.first[:intento]}".to_i + 1)


    # Obtenemos preguntas de un examen
    @preguntasExamen = DB[:examenes].join(:examen_pregunta, :idExamen => :idExamen)
                                    .join(:preguntas, :idPregunta => :idPregunta)
                                    .join(:respuestas, :idPregunta => :idPregunta)
                                    .where(:examenes__idExamen => params[:num])
    @examen = DB[:examenes].first(:idExamen => params[:num])

    # Eliminamos registros guardados anteriormente en la tabla de ese usuario
    @usu_exa_resp = DB[:usuario_examen_respuesta].filter(:idExamen => params[:num]).filter(:idUsuario => session[:id]).delete
    
    haml :examination
  else
    redirect '/'
  end
end

post '/examen/realizar/:num' do
  begin
    puts params

    # Obtenemos los valores que nos interesan para añadirlos a la tabla
    @preguntasExamen = DB[:examenes].join(:examen_pregunta, :idExamen => :idExamen)
                                    .join(:preguntas, :idPregunta => :idPregunta)
                                    .join(:respuestas, :idPregunta => :idPregunta)
                                    .where(:examenes__idExamen => params[:num])
    
    # Para obtener el intento del usuario
    @usu_exa = DB[:usuario_examen].where(:idExamen => params[:num]).where(:idUsuario => session[:id])
    @usu_exa.update(:fecha => Time.now)
    
    # Almacenamos los valores en usuario_examen_respuesta
    preguntas = @preguntasExamen.count
    nota = 0
    @preguntasExamen.each do |pregunta|
      case pregunta[:tipo]
      when "corta"
        @respuestas = DB[:usuario_examen_respuesta].insert(:idUsuario => session[:id], 
                                                         :idExamen => params[:num],
                                                         :idPregunta => pregunta[:idPregunta], 
                                                         :idRespuesta => pregunta[:idRespuesta], 
                                                         :intento => @usu_exa.first[:intento],
                                                         :texto => params["idPregunta#{pregunta[:idPregunta]}"])
        if (pregunta[:texto] == params["idPregunta#{pregunta[:idPregunta]}"])
          # pregunta correcta
          nota = nota + 1
        end
      when "vf"
        @respuestas = DB[:usuario_examen_respuesta].insert(:idUsuario => session[:id], 
                                                         :idExamen => params[:num],
                                                         :idPregunta => pregunta[:idPregunta], 
                                                         :idRespuesta => pregunta[:idRespuesta], 
                                                         :intento => @usu_exa.first[:intento],
                                                         :texto => "",
                                                         :correcto => params["opciones#{pregunta[:idPregunta]}"])
        if (pregunta[:correcto].to_s == params["opciones#{pregunta[:idPregunta]}"])
          # pregunta correcta
          nota = nota + 1
        end
      end
    end

    nota_final = (nota * 10) / preguntas
    @nota = @usu_exa.update(:nota => nota_final)
    
    flash[:mensaje] = "Examen enviado correctamente."

  rescue Exception => e
    puts e.message
    flash[:mensajeRojo] = "No se ha podido guardar el examen. Inténtelo de nuevo más tarde."
  end
  redirect '/examenes'
end
# ---------------------------------------------------------------

get '/calificaciones' do
  if (session[:username])

  else
    redirect '/'
  end
end

get '/configuracion' do
  if (session[:username])

    haml :configuration
  else
    redirect '/'
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

error do
  haml :error, :layout => false
end
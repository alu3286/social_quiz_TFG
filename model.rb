#require 'sequel'
require 'sinatra/sequel'
require 'bcrypt'

# include MD5 gem, should be part of standard ruby install
require 'digest/md5'


#Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

#DB = Sequel.sqlite # memory database
#DB = Sequel.sqlite('myquiz.db') # no memory database (en local)
configure do
  #DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://database.db')
  #DB = Sequel.connect(:adapter => 'mysql', :database => 'sqlite://database.db')
  #DB = Sequel.connect("sqlite://#{Dir.pwd}/database.db")
  #DB = Sequel.connect(ENV['LOCAL_DATABASE_URL'] || 'sqlite://database.db')
  #DB = Sequel.sqlite('database.sqlite')
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://quiz.sqlite')
  #DB = Sequel.connect(ENV['RACK_ENV'] || 'sqlite://quiz.sqlite')

  DB.create_table? :usuarios do
    primary_key   :idUsuario
    String        :nombre
    String        :apellidos
    String        :username
    String        :email
    Text          :imagen
    String        :password
    DateTime      :fecha_creacion
  end

DB.create_table? :examenes do
  primary_key   :idExamen
  String        :titulo
  DateTime      :fecha_creacion
  DateTime      :fecha_apertura
  DateTime      :fecha_cierre
  foreign_key   :idUsuario, :usuarios
end

DB.create_table? :preguntas do
  primary_key   :idPregunta
  String        :titulo
  DateTime      :fecha_creacion
  String        :tags
  foreign_key   :idUsuario, :usuarios
end

DB.create_table? :grupos do
  primary_key   :idGrupo
  String        :nombre
  String        :descripcion
  DateTime      :fecha_creacion
  foreign_key   :idUsuario, :usuarios
end

DB.create_table? :usuario_grupo do
  primary_key   [:idGrupo, :idUsuario]
  foreign_key   :idGrupo, :grupos
  foreign_key   :idUsuario, :usuarios
end

DB.create_table? :respuestas do
  primary_key   :idRespuesta
  String        :texto
  Boolean       :correcto
  String        :tipo
  foreign_key   :idPregunta, :preguntas
end

DB.create_table? :examen_pregunta do
  primary_key   [:idExamen,:idPregunta]
  Float         :peso
  Integer       :obligatoria
  foreign_key   :idExamen, :examenes
  foreign_key   :idPregunta, :preguntas
end

# DB.create_table! :usuario_examen do
#   primary_key   :idUsuario
#   primary_key   :idExamen
#   primary_key   :intento
#   Time          :tiempo
#   Float         :nota
#   Integer       :numero_fallo
#   Float         :puntuacion
#   String        :titulo
#   DateTime      :fecha
#   foreign_key   :idUsuario, :usuarios
#   foreign_key   :idExamen, :examenes
# end

# DB.create_table! :usuario_examen_respuesta do
#   primary_key   :idUsuario
#   primary_key   :idExamen
#   primary_key   :idRespuesta
#   primary_key   :idPregunta
#   primary_key   :intento
#   String        :texto

#   foreign_key   :idUsuario, :usuario_examen
#   foreign_key   :idExamen, :usuario_examen
#   foreign_key   :intento, :usuario_examen

#   #foreign_key   :idExamen, :examen_pregunta
#   #foreign_key   :idPregunta, :examen_pregunta

#   foreign_key   :idRespuesta, :respuestas
#   foreign_key   :idPregunta, :respuestas
# end





 
# get the email from URL-parameters or what have you and make lowercase
#email_address = params[:email].downcase
 
# create the md5 hash
#hash = Digest::MD5.hexdigest(email_address)
hash = Digest::MD5.hexdigest("eaculed@gmail.com")
puts hash
 
# compile URL which can be used in <img src="RIGHT_HERE"...
image_src = "http://www.gravatar.com/avatar/#{hash}"
puts image_src



user = DB[:usuarios] # Create a dataset
if DB[:usuarios].count == 0
  user.insert(:idUsuario => 1, :username => 'edu', :nombre => 'Eduardo', :apellidos => 'Acuña', :email => 'eaculed@gmail.com', 
            :password => BCrypt::Password.create('edu'), :imagen => image_src, :fecha_creacion => Time.now)
  user.insert(:idUsuario => 2, :username => 'juan', :nombre => 'Juan', :apellidos => 'Acuña', :email => 'juan@gmail.com', 
            :password => BCrypt::Password.create('juan'), :imagen => 'http://i.imgur.com/lEZ3n1E.jpg', :fecha_creacion => Time.now)
  user.insert(:idUsuario => 3, :username => 'pepe', :nombre => 'Pepe', :apellidos => 'Acuña', :email => 'pepe@gmail.com', 
            :password => BCrypt::Password.create('pepe'), :imagen => 'http://i.imgur.com/lEZ3n1E.jpg', :fecha_creacion => Time.now)
  user.insert(:idUsuario => 4, :username => 'antonio', :nombre => 'Antonio', :apellidos => 'Acuña', :email => 'antonio@gmail.com', 
            :password => BCrypt::Password.create('antonio'), :imagen => 'http://i.imgur.com/lEZ3n1E.jpg', :fecha_creacion => Time.now)
end

examen = DB[:examenes]
if DB[:examenes].count == 0
  examen.insert(:titulo => 'Examen primero', :fecha_creacion => '2015-05-29 12:00:00', :fecha_apertura => '2015-05-29 12:00:00', :fecha_cierre => '2015-05-29 12:00:00', :idUsuario => 1)
  examen.insert(:titulo => 'Examen segundo', :fecha_creacion => '2015-05-29 12:00:00', :fecha_apertura => '2015-05-29 12:00:00', :fecha_cierre => '2015-05-29 12:00:00', :idUsuario => 1)
  examen.insert(:titulo => 'Examen tercero', :fecha_creacion => '2015-05-29 12:00:00', :fecha_apertura => '2015-05-29 12:00:00', :fecha_cierre => '2015-05-29 12:00:00', :idUsuario => 1)
end

pregunta = DB[:preguntas]
if DB[:preguntas].count == 0
  pregunta.insert(:idPregunta => 1, :titulo => '¿Cuánto vale $3x+5$ si $x=3$?', :fecha_creacion => '2015-05-29 12:00:00', :tags => 'math', :idUsuario => 1)
  pregunta.insert(:idPregunta => 2, :titulo => '¿Cuánto vale $10x+5$ si $x=3$?', :fecha_creacion => '2015-05-29 12:00:00', :tags => 'math', :idUsuario => 1)
  pregunta.insert(:idPregunta => 3, :titulo => '¿Cuánto vale $50x+5$ si $x=3$?', :fecha_creacion => '2015-05-29 12:00:00', :tags => 'math', :idUsuario => 1)
  pregunta.insert(:idPregunta => 4, :titulo => '¿$<5$ es mayor que $<3$?', :fecha_creacion => '2015-05-29 12:00:00', :tags => 'math', :idUsuario => 1)
end

grupo = DB[:grupos]
if DB[:grupos].count == 0
  grupo.insert(:nombre => 'Calculo', :descripcion => 'Asignatura de Cálculo', :fecha_creacion => '2015-05-14 12:55:07.194097', :idUsuario => 1)
  grupo.insert(:nombre => 'Programacion', :descripcion => 'Asignatura de Programación', :fecha_creacion => '2015-05-14 12:55:07.194097', :idUsuario => 1)
  grupo.insert(:nombre => 'Computabilidad', :descripcion => 'Asignatura de Computabilidad', :fecha_creacion => '2015-05-14 12:55:07.194097', :idUsuario => 1)
  grupo.insert(:nombre => 'Tecnologías', :descripcion => 'Asignatura de Tecnologías', :fecha_creacion => '2015-05-14 12:55:07.194097', :idUsuario => 1)
end

usuario_grupo = DB[:usuario_grupo]
if DB[:usuario_grupo].count == 0
  usuario_grupo.insert(:idGrupo => 1, :idUsuario => 2)
  usuario_grupo.insert(:idGrupo => 1, :idUsuario => 3)
  usuario_grupo.insert(:idGrupo => 2, :idUsuario => 4)
  usuario_grupo.insert(:idGrupo => 3, :idUsuario => 2)
  usuario_grupo.insert(:idGrupo => 4, :idUsuario => 4)
end

respuesta = DB[:respuestas]
if DB[:respuestas].count == 0
  respuesta.insert(:texto => '14', :correcto => 1, :tipo => 'corta', :idPregunta => 1)
  respuesta.insert(:texto => '35', :correcto => 1, :tipo => 'corta', :idPregunta => 2)
  respuesta.insert(:texto => '155', :correcto => 1, :tipo => 'corta', :idPregunta => 3)
  respuesta.insert(:texto => '', :correcto => 0, :tipo => 'vf', :idPregunta => 4)
end

ex_pre = DB[:examen_pregunta]
if DB[:examen_pregunta].count == 0
  ex_pre.insert(:idExamen => 1, :idPregunta => 1, :peso => '', :obligatoria => 1)
  ex_pre.insert(:idExamen => 1, :idPregunta => 2, :peso => '', :obligatoria => 1)
  ex_pre.insert(:idExamen => 2, :idPregunta => 3, :peso => '', :obligatoria => 1)
  ex_pre.insert(:idExamen => 2, :idPregunta => 4, :peso => '', :obligatoria => 1)
  ex_pre.insert(:idExamen => 3, :idPregunta => 1, :peso => '', :obligatoria => 1)
  ex_pre.insert(:idExamen => 3, :idPregunta => 2, :peso => '', :obligatoria => 1)
  ex_pre.insert(:idExamen => 3, :idPregunta => 3, :peso => '', :obligatoria => 1)
  ex_pre.insert(:idExamen => 3, :idPregunta => 4, :peso => '', :obligatoria => 1)
end

# Print out the number of records
#puts "Usuarios: #{user.count}"

# Print out the average price
#puts "The average price is: #{items.avg(:price)}"

end


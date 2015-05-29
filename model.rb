require 'sequel'
require 'sinatra/sequel'
require 'bcrypt'
#Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

#DB = Sequel.sqlite # memory database
#DB = Sequel.sqlite('myquiz.db') # no memory database (en local)
configure do
  #DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://database.db')
  #DB = Sequel.connect(:adapter => 'mysql', :database => 'sqlite://database.db')
  DB = Sequel.connect("sqlite://#{Dir.pwd}/database.db")

  DB.create_table! :usuarios do
    primary_key   :idUsuario
    String        :nombre
    String        :apellidos
    String        :username
    String        :email
    Text          :imagen
    String        :password
    DateTime      :fecha_creacion
  end
end

# DB.create_table! :usuario_grupo do
#   primary_key   [:idGrupo, :idUsuario]
#   foreign_key   :idGrupo, :grupos
#   foreign_key   :idUsuario, :usuarios
# end

# DB.create_table! :grupos do
#   primary_key   :idGrupo
#   String        :nombre
#   String        :descripcion
#   DateTime      :fecha_creacion
#   foreign_key   :idUsuario, :usuarios
# end

# DB.create_table! :respuestas do
#   primary_key   :idRespuesta
#   String        :texto
#   Boolean       :correcto
#   String        :tipo
#   foreign_key   :idPregunta, :preguntas
# end

# DB.create_table! :examen_pregunta do
#   primary_key   :idExamen
#   primary_key   :idPregunta
#   Float         :peso
#   Integer       :obligatoria
#   foreign_key   :idExamen, :examenes
#   foreign_key   :idPregunta, :preguntas
# end

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

# DB.create_table! :preguntas do
#   primary_key   :idPregunta
#   String        :titulo
#   DateTime      :fecha_creacion
#   String        :tags
#   foreign_key   :idUsuario, :usuarios
# end

# DB.create_table! :examenes do
#   primary_key   :idExamen
#   String        :titulo
#   DateTime      :fecha_creacion
#   DateTime      :fecha_apertura
#   DateTime      :fecha_cierre
#   foreign_key   :idUsuario, :usuarios
# end

# DB.create_table! :usuarios do
#   primary_key 	:idUsuario
#   String 		    :nombre
#   String 		    :apellidos
#   String        :username
#   String 		    :email
#   Text 			    :imagen
#   String        :password
#   DateTime		  :fecha_creacion
# end

# user = DB[:usuarios] # Create a dataset
# if DB[:usuarios].count == 0
#   user.insert(:username => 'edu', :nombre => 'Eduardo', :apellidos => 'Acuña', :email => 'eaculed@gmail.com', 
#             :password => BCrypt::Password.create('edu'), :imagen => '', :fecha_creacion => Time.now)
#   user.insert(:username => 'juan', :nombre => 'Juan', :apellidos => 'Acuña', :email => 'juan@gmail.com', 
#             :password => BCrypt::Password.create('juan'), :imagen => '', :fecha_creacion => Time.now)
#   user.insert(:username => 'pepe', :nombre => 'Pepe', :apellidos => 'Acuña', :email => 'pepe@gmail.com', 
#             :password => BCrypt::Password.create('pepe'), :imagen => '', :fecha_creacion => Time.now)
#   user.insert(:username => 'antonio', :nombre => 'Antonio', :apellidos => 'Acuña', :email => 'antonio@gmail.com', 
#             :password => BCrypt::Password.create('antonio'), :imagen => '', :fecha_creacion => Time.now)
# end

# grupo = DB[:grupos]
# if DB[:grupos].count == 0
#   grupo.insert(:nombre => 'Calculo', :descripcion => 'Asignatura de Cálculo', :fecha_creacion => '2015-05-14 12:55:07.194097', :idUsuario => 1)
#   grupo.insert(:nombre => 'Programacion', :descripcion => 'Asignatura de Programación', :fecha_creacion => '2015-05-14 12:55:07.194097', :idUsuario => 1)
#   grupo.insert(:nombre => 'Computabilidad', :descripcion => 'Asignatura de Computabilidad', :fecha_creacion => '2015-05-14 12:55:07.194097', :idUsuario => 1)
#   grupo.insert(:nombre => 'Tecnologías', :descripcion => 'Asignatura de Tecnologías', :fecha_creacion => '2015-05-14 12:55:07.194097', :idUsuario => 1)
# end

# usuario_grupo = DB[:usuario_grupo]
# if DB[:usuario_grupo].count == 0
#   usuario_grupo.insert(:idGrupo => 1, :idUsuario => 2)
#   usuario_grupo.insert(:idGrupo => 1, :idUsuario => 3)
#   usuario_grupo.insert(:idGrupo => 2, :idUsuario => 4)
#   usuario_grupo.insert(:idGrupo => 3, :idUsuario => 2)
#   usuario_grupo.insert(:idGrupo => 4, :idUsuario => 4)
# end

# pregunta = DB[:preguntas]

# if DB[:preguntas].count == 0
#   pregunta.insert()
#   pregunta.insert()
#   pregunta.insert()
# end

# Print out the number of records
#puts "Usuarios: #{user.count}"

# Print out the average price
#puts "The average price is: #{items.avg(:price)}"


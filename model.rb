require 'sequel'
require 'bcrypt'
#Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

#DB = Sequel.sqlite # memory database
#DB = Sequel.sqlite('myquiz.db') # no memory database (en local)
DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://database.db')

if !DB.table_exists?(:usuarios)
  DB.create_table :usuarios do
    primary_key 	:idUsuario
    String 		    :nombre
    String 		    :apellidos
    String        :username
    String 		    :email
    Text 			    :imagen
    #BCryptHash 	:password
    String        :password
    DateTime		  :fecha_creacion
  end
end

if !DB.table_exists?(:grupos)
  DB.create_table :grupos do
    primary_key   :idGrupo
    String        :nombre
    String        :username
    DateTime      :fecha_creacion
  end
end

if !DB.table_exists?(:usuario_grupo)
  DB.create_table :usuario_grupo do
    primary_key   :idGrupo
    primary_key   :idUsuario
    foreign_key   :idGrupo, :grupos
    foreign_key   :idUsuario, :usuarios
  end
end

if !DB.table_exists?(:preguntas)
DB.create_table :preguntas do
  primary_key   :idPregunta
  String        :titulo
  DateTime      :fecha_creacion
  String        :tags
  foreign_key   :idUsuario, :usuarios
end
end

if !DB.table_exists?(:respuestas)
DB.create_table :respuestas do
  primary_key   :idRespuesta
  String        :texto
  Boolean       :correcto
  String        :tipo
  foreign_key   :idPregunta, :preguntas
end
end

if !DB.table_exists?(:examenes)
DB.create_table :examenes do
  primary_key   :idExamen
  String        :titulo
  DateTime      :fecha_creacion
  DateTime      :fecha_apertura
  DateTime      :fecha_cierre
  foreign_key   :idUsuario, :usuarios
end
end

if !DB.table_exists?(:examen_pregunta)
DB.create_table :examen_pregunta do
  primary_key   :idExamen
  primary_key   :idPregunta
  Float         :peso
  Integer       :obligatoria
  foreign_key   :idExamen, :examenes
  foreign_key   :idPregunta, :preguntas
end
end

if !DB.table_exists?(:usuario_examen)
DB.create_table :usuario_examen do
  primary_key   :idUsuario
  primary_key   :idExamen
  primary_key   :intento
  Time          :tiempo
  Float         :nota
  Integer       :numero_fallo
  Float         :puntuacion
  String        :titulo
  DateTime      :fecha
  foreign_key   :idUsuario, :usuarios
  foreign_key   :idExamen, :examenes
end
end

if !DB.table_exists?(:usuario_examen_respuesta)
DB.create_table :usuario_examen_respuesta do
  primary_key   :idUsuario
  primary_key   :idExamen
  primary_key   :idRespuesta
  primary_key   :idPregunta
  primary_key   :intento
  String        :texto

  foreign_key   :idUsuario, :usuario_examen
  foreign_key   :idExamen, :usuario_examen
  foreign_key   :intento, :usuario_examen

  #foreign_key   :idExamen, :examen_pregunta
  #foreign_key   :idPregunta, :examen_pregunta

  foreign_key   :idRespuesta, :respuestas
  foreign_key   :idPregunta, :respuestas
end
end

#user = DB[:usuarios] # Create a dataset

# Populate the table
#user.insert(:nombre => 'edu', :apellidos => 'acuña', :username => 'edualedesma', :email => 'eaculed@gmail.com', 
#			:imagen => 'edu.jpg', :password => BCrypt::Password.create('edu'), :created_at => Time.now)

# Print out the number of records
#puts "Usuarios: #{user.count}"

# Print out the average price
#puts "The average price is: #{items.avg(:price)}"


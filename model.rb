#DB = Sequel.sqlite # memory database
DB = Sequel.sqlite('myquiz.db') # no memory database

if !DB.table_exists?(:usuarios)
  DB.create_table :usuarios do
    primary_key 	:idUsuario
    String 		    :nombre
    String 		    :apellidos
    String        :username
    String 		    :email
    Text 			    :imagen
    BCryptHash 	  :password
    DateTime		  :fecha_creacion
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
  primary_key :idExamen
  String :name
  Float :price
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


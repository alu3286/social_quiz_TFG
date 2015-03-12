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
    DateTime		  :created_at
  end
end

if !DB.table_exists?(:examenes)
DB.create_table :examenes do
  primary_key :idExamen
  String :name
  Float :price
end
end

if !DB.table_exists?(:preguntas)
DB.create_table :preguntas do
  primary_key :idPregunta
  String :name
  Float :price
end
end

if !DB.table_exists?(:respuestas)
DB.create_table :respuestas do
  primary_key :idRespuesta
  String :name
  Float :price
end
end

user = DB[:usuarios] # Create a dataset

# Populate the table
#user.insert(:nombre => 'edu', :apellidos => 'acuña', :username => 'edualedesma', :email => 'eaculed@gmail.com', 
#			:imagen => 'edu.jpg', :password => BCrypt::Password.create('edu'), :created_at => Time.now)

#items.insert(:name => 'def', :price => rand * 100)
#items.insert(:name => 'ghi', :price => rand * 100)

# Print out the number of records
puts "Usuarios: #{user.count}"

# Print out the average price
#puts "The average price is: #{items.avg(:price)}"


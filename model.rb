require ''
require ''

class Usuarios
	include DataMapper::Resource
	property :id, 			Serial
	property :nombre,		String
	property :apellidos,	String
	property :email,		String
	property :imagen,		Text
	property :created_at,	DateTime
end

class Preguntas
	include DataMapper::Resource
	property :id,			Serial
	property :titulo,		Text
	property :tipo,			String
	property :cuerpo,		Text
	property :tema,			String
	property :id_usuario,	Integer
	property :created_at,	DateTime
end

class Examenes
	include DataMapper::Resource
	property :id,				Serial
	property :titulo,			Integer		
	property :fecha_apertura,	DateTime
	property :fecha_cierre,		DateTime		
	property :created_at,		DateTime

	has n, :preguntas
	has n, :usuarios
end
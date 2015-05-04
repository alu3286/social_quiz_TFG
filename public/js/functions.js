$(document).ready(function() 
{
  $("#mensaje-pass").hide();
  $("#pass2").keyup(function() {
    pass1 = $("#pass1").val();
    pass2 = $("#pass2").val();
    $("#mensaje-pass").show();
	if (pass2 == pass1) {
	  $("#mensaje-pass").hide();
	  //$("#mensaje-pass").html("Ok. Las contraseñas coinciden.");	
	}
	else {
	  $("#mensaje-pass").html("Las contraseñas deben coincidir.");
	}
  });

  $("#form-signup").submit(function() 
  {
  	if ($("#pass1").val() != $("#pass2").val()) {
  	  return false;
  	}
  	else
  		return true;
  });

  /*$("#eliminar").click(function(){
    alert("quieres eliminar el elemento.");
    alert(document.getElementById("p" + $(this).attr('data')));
    //alert(document.getElementById("p1"));
    //alert($(#fila));
      //Recogemos la id del contenedor padre
      var parent = $(this).parent().attr('id');
      //Recogemos el valor del servicio
      var service = $(this).attr('data');

      var dataString = 'id='+service;


      $.ajax({
          type: "POST",
          url: "preguntas/delete",
          data: dataString,
          success: function() {            
              $('#delete-ok').empty();
              $('#delete-ok').append('<div>Se ha eliminado correctamente el servicio con id='+service+'.</div>').fadeIn("slow");
              //$('#'+parent).remove();
              $("#p1").remove();
          }
      });
  });*/

  $("#resp-corta").click(function() {
    $("#respuesta-corta").show();
    $("#respuesta-multiple").hide();
    $("#respuesta-vf").hide();
  });
  $("#resp-multiple").click(function() {
    $("#respuesta-corta").hide();
    $("#respuesta-multiple").show();
    $("#respuesta-vf").hide();
  });
  $("#resp-vf").click(function() {
    $("#respuesta-corta").hide();
    $("#respuesta-multiple").hide();
    $("#respuesta-vf").show();
  });


  // Para el CRUD de las tablas (Eliminar) ---------------
  $("#mytable").click(function () {
    $("[data-toggle=tooltip]").tooltip();
  });
  // -----------------------------------------------------


});
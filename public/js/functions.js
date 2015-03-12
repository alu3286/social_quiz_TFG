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


  //$("#posts").scrollTop(50000000000);
  $("#btn-post").click(function() {
    $("#posts").scrollTop(5000000000000);
    //tam = $("#posts").css("height");
    //alert(tam);
    //$("#posts").scrollTop(tam * 1000);
  });

});
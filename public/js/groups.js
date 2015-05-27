$(document).ready(function(){

  $("#add-user-link").css("visibility", 'hidden');
  $("#add-usuario").css('visibility', 'hidden');



  $("#lista-gr li").each(function() {
    $(this).click(function() {
      var datos = $(this).attr('id').substr(3);
      $("#oculto").val(datos);
      //Actualizo el enlace de añadir/eliminar usuarios
      $("#add-user-link").attr('href', "/grupos/miembros/" + datos);
      //var datos = { id: '1','2','3' };
      $.ajax({
        url: "/dameusuarios",
        method: "post",
        data: { id: datos}
      }).done(function(datosdevueltos) {
        
        var us = $.parseJSON(datosdevueltos);

        var lista = '<ul id="lista-usr">';
        $.each( us, function( key, value ) {
          //alert( key + ": " + value );
          lista = lista + '<li id=' + key + '>' + value + '</li>';
        });
        lista = lista + '</ul>';
        $("#lista-usuarios").html(lista);

      })
    });
  });


  // $("#add-user-link").click(function(){
  //   //alert($("#oculto").val());
  //   var datos = $("#oculto").val();
  //     //var datos = { id: '1','2','3' };
  //   $.ajax({
  //     url: "/grupos/miembros/",
  //     method: "get",
  //     data: { id: datos}
  //   }).done(function(datosdevueltos) {
  //       console.log(datosdevueltos);
  //       //window.location.href = "/grupos/miembros";
  //       /*
  //       var us = $.parseJSON(datosdevueltos);

  //       var lista = '<ul id="lista-usr">';
  //       $.each( us, function( key, value ) {
  //         //alert( key + ": " + value );
  //         lista = lista + '<li id=' + key + '>' + value + '</li>';
  //       });
  //       lista = lista + '</ul>';
  //       $("#lista-usuarios").html(lista);
  //       */
  //   })

  //});


  /*$("#lista-gr li").each(function() {
    $(this).click(function() {
      $("#add-user-link").css("visibility", 'visible');
      $(this).css("font-weight", "bold");
      //alert("Has hecho click en el grupo: "+$(this).attr("id"));
    });
    //console.log($(this).attr("id"));
  });*/


  
  

  var li = $("#lista-gr li"), forEach = Array.prototype.forEach;
  //var li = document.getElementsByTagName("li"), forEach = Array.prototype.forEach;

  window.addEventListener("click", function(e){


    $("#add-user-link").css("visibility", 'hidden');
    $("#add-usuario").css('visibility', 'hidden');
    forEach.call(li, function(a){
    	if (a === e.target) {
    		a.className = "active";
    		$("#add-user-link").css("visibility", 'visible');
        $("#add-usuario").css('visibility', 'visible');

    	}
    	else {
    		a.className = "";
    		
    	}
    });
}, false);

});
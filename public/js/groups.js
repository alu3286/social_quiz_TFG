$(document).ready(function(){
    
  /* Modal de eliminación de preguntas */
  $('#myModalTrash.modal').on('show.bs.modal', function (event) {
    
    var button = $(event.relatedTarget) // Button that triggered the modal
    var recipient = button.data('whatever') // Extract info from data-* attributes
    // If necessary, you could initiate an AJAX request here (and then do the updating in a callback).
    // Update the modal's content. We'll use jQuery here, but you could use a data binding library or other methods instead.
    var modal = $(this)
    //modal.find('.modal-title').text('New message to ' + recipient)
    modal.find('.modal-body p').text('¿Quiere realmente eliminar el grupo ' + recipient + '?')

    modal.find(botonEliminar).data('id', recipient);
    //alert(modal.find(botonEliminar).data( 'id' ) );

  })

  $('button.btn.btn-danger').on('click', function(event) {
  //$('#botonEliminar').on('click', function(event) {
    datos = $(this).data('id');

    // Llamar a AJAX para que lance un POST y borre el registro
    $.ajax({
      url: "/eliminaGrupo",
      method: "post",
      data: { ids: datos}
      //data: { ids: datos, titulo, fecha_apertura, fecha_cierre}
    }).done(function() {
      $('#myModalTrash').modal('hide');
      //redirigir a donde quiera
      //$("#formulario2-grupos").submit();
      window.location.href = "/grupos";
    })

  });


  $("#add-user-link").css("visibility", 'hidden');
  $("#add-usuario").css('visibility', 'hidden');


  $("#edit-group-link").css('visibility', 'hidden');
  $("#delete-group-link").css('visibility', 'hidden');


  $("#lista-gr li").each(function() {
    $(this).click(function() {
      var datos = $(this).attr('id').substr(3);
      $("#oculto").val(datos);
      
      //Actualizo el enlace de añadir/eliminar usuarios
      $("#add-user-link").attr('href', "/grupos/miembros/" + datos);
      
      //Actualizo enlace para editar el grupo
      $("#edit-group-link").attr('href', "/grupo/" + datos);

      //Actualizo atributos botón eliminar
      $("#delete-group-link").attr('data', datos);
      $("#delete-group-link").attr('data-whatever', datos);

      //var datos = { id: '1','2','3' };
      $.ajax({
        url: "/dameusuarios",
        method: "post",
        data: { id: datos}
      }).done(function(datosdevueltos) {
        
        var us = $.parseJSON(datosdevueltos);

        var lista = '<ul id="lista-usr" class="list-group">';
        $.each( us, function( key, value ) {
          //alert( key + ": " + value );
          lista = lista + '<li id=' + key + ' class="list-group-item">' + value + '</li>';
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
    $("#edit-group-link").css('visibility', 'hidden');
    $("#delete-group-link").css('visibility', 'hidden');
    forEach.call(li, function(a){
    	if (a === e.target) {
    		a.className = "list-group-item active";
    		$("#add-user-link").css("visibility", 'visible');
        $("#add-usuario").css('visibility', 'visible');
        $("#edit-group-link").css('visibility', 'visible');
        $("#delete-group-link").css('visibility', 'visible');

    	}
    	else {
    		a.className = "list-group-item";
    		
    	}
    });
}, false);

});
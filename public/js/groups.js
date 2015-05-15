$(document).ready(function(){

  $("#add-user-link").css("visibility", 'hidden');
  $("#lista-gr li").each(function() {
    $(this).click(function() {
      $("#add-user-link").css("visibility", 'visible');
      //alert("Has hecho click en el grupo: "+$(this).attr("id"));
    });
    //console.log($(this).attr("id"));
  });

});
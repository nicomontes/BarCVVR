//= require cable
//= require_self


function raz(drink) {
  document.getElementById(drink).innerHTML = '0.000'

  if (drink == 'blonde') {
    var url = "/beerflows/1";
    var data = { beerflow:{quantity:0,drink_id:1}, _method:'put' }
  }
  else if (drink == 'special') {
    var url = "/beerflows/2";
    var data = { beerflow:{quantity:0,drink_id:9}, _method:'put' }
  }

  $.ajax({
    type: "PUT",
    dataType: "script",
    url: url,
    contentType: 'application/json',
    data: JSON.stringify(data),
    success: function (data) {
            console.log('OK');
        }
}).done(function( msg ){});
}

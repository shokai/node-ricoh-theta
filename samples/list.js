var Theta = require(__dirname+'/../');
// var Theta = require('ricoh-theta');

var theta = new Theta();
theta.connect('192.168.1.1');

theta.on('connect', function(){
  console.log('connect!!');

  theta.listPictures(function(err, object_handles){
    if(err) return console.error(err);
    console.log("Object Handles: " + JSON.stringify(object_handles));
    console.log(object_handles.length + " pictures");
    theta.disconnect();
  });
});

var Theta = require(__dirname+'/../');
// var Theta = require('ricoh-theta');

var theta = new Theta();
theta.connect('192.168.1.1');

theta.on('connect', function(){
  console.log('connect!!');

  theta.listPictures(function(err, object_ids){
    if(err) return console.error(err);
    console.log("Object IDs: " + JSON.stringify(object_ids));
    console.log(object_ids.length + " pictures");
    theta.disconnect();
  });
});

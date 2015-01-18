var fs = require('fs');

var Theta = require(__dirname+'/../');
// var Theta = require('ricoh-theta');

var theta = new Theta();
theta.connect('192.168.1.1');

theta.on('connect', function(){
  console.log('connect!!');
  theta.capture(function(err){
    if(err) return console.error(err);
    console.log('capture success');
  });
});

theta.on('objectAdded', function(object_id){
  console.log('getting picture..');
  theta.getPicture(object_id, function(err, picture){
    fs.writeFile('tmp.jpg', picture, function(err){
      console.log('picture saved => tmp.jpg');
      theta.disconnect();
    });
  });
});

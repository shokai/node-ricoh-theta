var Theta = require(__dirname+'/../');
// var Theta = require('ricoh-theta');

var theta = new Theta();
theta.connect('192.168.1.1');

theta.on('connect', function(){
  console.log('connect!!');
  theta.getBatteryLevel(function(err, res){
    if(err) return console.error(err);
    console.log("BatteryLevel: "+res.dataPacket.array[0]);
    theta.disconnect();
  });
});

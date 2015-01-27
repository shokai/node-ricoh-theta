var Theta = require(__dirname+'/../');
// var Theta = require('ricoh-theta');

var theta = new Theta();
theta.connect('192.168.1.1');

theta.on('connect', function(){
  console.log('connect!!');

  // https://developers.theta360.com/ja/docs/ptpip_reference/property/audio_volume.html
  theta.getProperty(0x502C, function(err, res){
    if(err) return console.error(err);
    console.log("AudioVolume: "+res.dataPacket.array[0]);

    theta.setProperty(0x502C, 0, function(err, res){ // no sound
      if(err) return console.error(err);
      theta.disconnect();
    });

  });
});

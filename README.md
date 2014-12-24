# ricoh-theta npm
controll RICOH THETA 360-degree camera

- https://github.com/shokai/node-ricoh-theta
- https://www.npmjs.com/package/ricoh-theta


## Install

    % npm install ricoh-theta


## Usage

```javascript
var Theta = require('ricoh-theta');

var theta = new Theta();
theta.connect('192.168.1.1');

theta.on('connect', function(){
  console.log('connect!!');
  theta.capture(function(err){
    if(err) return console.error(err);
    console.log('captured');
    theta.disconnect();
  });
});
```


Contributing
------------
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

var page = require('webpage').create();
page.onConsoleMessage = function(str) {
   console.log(str);
}
page.open('http://phantomjs.org/api/phantom/', function(status) {
   page.render('beforeclick.png');
   console.log(page.url);

   var element = page.evaluate(function() {
      return document.querySelector('img[src = "http://phantomjs.org/img/phantomjslogo.png"]');
   });
   page.sendEvent('click', element.offsetLeft, element.offsetTop, 'left');

   window.setTimeout(function () {
      console.log(page.url);
      page.render('afterclick.png');
      phantom.exit();
   }, 5000);
   console.log('element is ' + element);
});
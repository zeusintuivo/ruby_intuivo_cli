var page = require('webpage').create();
page.onConsoleMessage = function(str) {
   console.log(str);
}
page.open('https://www.dropbox.com/install-linux', function(status) {
   page.render('.dropbox_beforeclickbeforeclick.png');
   console.log(page.url);

   var element = page.evaluate(function() {
      return document.querySelector('a[href = "/download?dl=packages/fedora/nautilus-dropbox-2020.03.04-1.fedora.x86_64.rpm"]');
   });
   page.sendEvent('click', element.offsetLeft, element.offsetTop, 'left');

   window.setTimeout(function () {
      console.log(page.url);
      page.render('.dropbox_afterclick.png');
      phantom.exit();
   }, 5000);
   console.log('element is ' + element);
});
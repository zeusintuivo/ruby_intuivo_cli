var page = require('webpage').create();
var websiteAddress = 'https://www.dropbox.com/install-linux';
//viewportSize being the actual size of the headless browser
page.viewportSize = { width: 1680, height: 1050 };
//the clipRect is the portion of the page you are taking a screenshot of
page.clipRect = { top: 0, left: 0, width: 1680, height: 1050 };

// Open website
page.open(websiteAddress, function(status) {
    // Show some message in the console
    console.log("Status:  " + status);
    console.log("Loaded:  " + page.url);

    page.render('dropbox.png');
    phantom.exit();
});

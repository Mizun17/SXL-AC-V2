// ANTI NUI-DEVTOOLS (DON'T TOUCH ANYTHING OF THIS, OTHERWISE IT WON'T WORK) 

var _antidevtools = new Image;

_antidevtools.__defineGetter__("id", function() {
    $.post('http://SXL-AC/antinuidevtools', JSON.stringify({}));
    console.log("Bye, don't open Devtools");
});

console.log(_antidevtools, "SXL-AC INITIALIZED")

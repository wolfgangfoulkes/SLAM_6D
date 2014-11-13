
rate = 1000;
cx = 0;
cy = 0;
ox = 0;
oy = 0;

isReady = false;

setXY = function()
{
    var ct =
    {
        bottom: (cy.toString() + "%"),
        left: (cx.toString() + "%")
    };
    
    var ot =
    {
        bottom: (oy.toString() + "%"),
        left: (ox.toString() + "%")
    };

    
    $("#camera").css(ct);
    $("#object").css(ot);
    
    
    var _cy = $("#camera").css("bottom");
    var _cx = $("#camera").css("left");
    
    var _oy = $("#object").css("bottom");
    var _ox = $("#object").css("left");
    
    console.log("camera: " + _cx + ", " + _cy);
    console.log("object: " + _ox + ", " + _oy);

};


jQuery(document).ready(function(){
//    $("#xy-outer").css("background-color", "blue");
    isReady = true;
    setInterval(setXY, rate);
    });
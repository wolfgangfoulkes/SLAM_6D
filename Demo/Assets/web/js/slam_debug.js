
rate = 240;
printToScreen = false;
Pose = function()
{
    this.t = {x: 0, y:0, z:0};
    this.r = {x: 0, y:0, z:0};
};
c = new Pose;
o = new Pose;

poses = {}

isReady = false;

update = function()
{
    setXY();
    setReadout();
}

setReadout = function()
{
    if (!printToScreen) {return;}
    var $ctx = $(".cam .t .x");
    var $cty = $(".cam .t .y");
    var $ctz = $(".cam .t .z");
    var $crx = $(".cam .r .x");
    var $cry = $(".cam .r .y");
    var $crz = $(".cam .r .z");
    
    var $otx = $(".obj .t .x");
    var $oty = $(".obj .t .y");
    var $otz = $(".obj .t .z");
    var $orx = $(".obj .r .x");
    var $ory = $(".obj .r .y");
    var $orz = $(".obj .r .z");
    
    $ctx.text(c.t.x.toPrecision(6));
    $cty.text(c.t.y.toPrecision(6));
    $ctz.text(c.t.z.toPrecision(6));
    $crx.text(c.r.x.toPrecision(6));
    $cry.text(c.r.y.toPrecision(6));
    $crz.text(c.r.z.toPrecision(6));
    
    $otx.text(o.t.x.toPrecision(6));
    $oty.text(o.t.y.toPrecision(6));
    $otz.text(o.t.z.toPrecision(6));
    $orx.text(o.r.x.toPrecision(6));
    $ory.text(o.r.y.toPrecision(6));
    $orz.text(o.r.z.toPrecision(6));
}

setXY = function()
{
    var ct =
    {
        bottom: ((50. + c.t.y/50).toString() + "%"),
        left: ((50. + c.t.x/50).toString() + "%"),
        transform: "rotateZ(" + c.r.y + "deg)"
    };
    
    var ot =
    {
        bottom: ((50. + o.t.z/50).toString() + "%"),
        left: ((50. + o.t.x/50).toString() + "%"),
        transform: "rotateZ(" + c.r.y + "deg)"
        
    };

    
    $("#camera").css(ct);
    $("#object").css(ot);
    
    
//    var _cy = $("#camera").css("bottom");
//    var _cx = $("#camera").css("left");
//    
//    var _oy = $("#object").css("bottom");
//    var _ox = $("#object").css("left");
    
    //console.log("camera: " + _cx + ", " + _cy);
    //console.log("object: " + _ox + ", " + _oy);

};


jQuery(document).ready(function(){
//    $("#xy-outer").css("background-color", "blue");
    isReady = true;
    setInterval(update, rate);
    });
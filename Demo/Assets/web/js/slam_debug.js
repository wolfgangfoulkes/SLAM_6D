
rate = 240;
printToScreen = false;
Pose = function()
{
    this.t = {x: 0, y:0, z:0};
    this.r = {x: 0, y:0, z:0};
};
c = new Pose;
o = new Pose;

poses = {};

COS =
{
    idx: 0,
    state: "UNINIT"
};

log = [];
print_log = false;

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
    
    var $cos_idx = $(".cos .idx");
    var $cos_state = $(".cos .state");
    $cos_idx.text(COS.idx);
    $cos_state.text(COS.state);
    
    if (print_log)
    {
        printLog();
    }
}

setXY = function()
{
    var ct =
    {
        bottom: ((50. + c.t.y/25).toString() + "%"),
        left: ((50. + c.t.x/25).toString() + "%"),
        transform: "rotateZ(" + c.r.z + "deg)"
    };
    
    var ot =
    {
        bottom: ((50. + o.t.z/25).toString() + "%"),
        left: ((50. + o.t.x/25).toString() + "%"),
        transform: "rotateZ(" + c.r.y + "deg)"
        
    };

    
    $("#camera").css(ct);
    $("#object").css(ot);
};

printLog = function()
{
    var $log_dom = $(".log");
    $log_dom.empty();
    for (i = 0; i < log.length; i++)
    {
        var log_entry = "<div class='log-entry'>" + i + ": " + log[i] + "</div>";
        $log_dom.prepend(log_entry);
    }
};


jQuery(document).ready(function(){
//    $("#xy-outer").css("background-color", "blue");
    isReady = true;
    setInterval(update, rate);
    console.log("javascript is ready!");
    $(".printLog").click(function(){
        print_log = !print_log;

        $(".log").toggleClass("hidden", !print_log);
        $(this).toggleClass("active", print_log);
    });
});
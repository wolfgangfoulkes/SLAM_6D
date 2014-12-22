rate = 240;
printToScreen = true;
Pose = function()
{
    this.t = {x: 0, y:0, z:0};
    this.r = {x: 0, y:0, z:0};
};
c = new Pose;
o = new Pose;
db = new Pose;
touch = new Pose;
init = new Pose;

poses = {};

COS =
{
    idx: 0,
    state: "UNINIT"
};

log = [];
print_log = false;

isReady = false;

setP = false;
setPInit = false;

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
    
    var $itx = $(".init .t .x");
    var $ity = $(".init .t .y");
    var $itz = $(".init .t .z");
    var $irx = $(".init .r .x");
    var $iry = $(".init .r .y");
    var $irz = $(".init .r .z");
    
    var $tchtx = $(".touch .t .x");
    var $tchty = $(".touch .t .y");
    var $tchtz = $(".touch .t .z");
    var $tchrx = $(".touch .r .x");
    var $tchry = $(".touch .r .y");
    var $tchrz = $(".touch .r .z");
    
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
    
    $itx.text(init.t.x.toPrecision(6));
    $ity.text(init.t.y.toPrecision(6));
    $itz.text(init.t.z.toPrecision(6));
    $irx.text(init.r.x.toPrecision(6));
    $iry.text(init.r.y.toPrecision(6));
    $irz.text(init.r.z.toPrecision(6));
    
    $tchtx.text(touch.t.x.toPrecision(6));
    $tchty.text(touch.t.y.toPrecision(6));
    $tchtz.text(touch.t.z.toPrecision(6));
    $tchrx.text(touch.r.x.toPrecision(6));
    $tchry.text(touch.r.y.toPrecision(6));
    $tchrz.text(touch.r.z.toPrecision(6));
    
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
        bottom: ((50. + c.t.y/10).toString() + "%"),
        left: ((50. + c.t.x/10).toString() + "%"),
        transform: "rotateZ(" + c.r.z + "deg)"
    };
    
    var ot =
    {
        bottom: ((50. + o.t.y/10).toString() + "%"),
        left: ((50. + o.t.x/10).toString() + "%"),
        transform: "rotateZ(" + o.r.z + "deg)"
        
    };
    
    var axes =
    {
        
        bottom: ((50. + init.t.y/10).toString() + "%"),
        left: ((50. + init.t.x/10).toString() + "%"),
        transform: "rotateZ(" + init.r.z + "deg)"
    };
    
    var tch =
    {
        
        bottom: ((50. + touch.t.y/10).toString() + "%"),
        left: ((50. + touch.t.x/10).toString() + "%"),
        transform: "rotateZ(" + touch.r.z + "deg)"
    };

    if (setPInit) { $(".axes.touch").css(tch); }
    $(".axes.init").css(axes);
    $("#touch").css(tch);
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

getXY = function($node, e)
{
    var position = $node.offset();
    var n_width = $node.innerWidth();
    var n_height = $node.innerHeight();
    var handlers = {
        vmousemove : function(e){
            var normX =  (e.pageX - position.left) / n_width;
            var normY =  (e.pageY - position.top) / n_height;
            
            db.t.x = normX.toPrecision(6);
            db.t.y = normY.toPrecision(6);
        },
        vmouseup : function(e){
            $(this).off(handlers);   
        }
    };
    $(document).on(handlers);
};

whichDevice = function()
{
    	var isPhone = (/android|webos|iphone/i.test(navigator.userAgent.toLowerCase()));
        var isTablet = (/ipad/i.test(navigator.userAgent.toLowerCase()));
        var _which = "unknown";
        _which = (isPhone && (!isTablet)) || (!(isPhone) && isTablet) ? "phone" : "tablet";
        return _which;
}


jQuery(document).ready(function(){
//    $("#xy-outer").css("background-color", "blue");
    isReady = true;
    setInterval(update, rate);
    $.vmouse.moveDistanceThreshold = 1000000;
    console.log("javascript is ready!");

    var device = whichDevice();
    $("body").addClass(device);

    $(".printLog").click(function(){
        print_log = !print_log;

        $(".log").toggleClass("hidden", !print_log);
        $(this).toggleClass("active", print_log);
    });
    
    $(".setP").click(function()
    {
        setP = !setP;
        $(this).toggleClass("active", setP);
    });
    
    $(".setPInit").click(function()
    {
        setPInit = !setPInit;
        $(this).toggleClass("active", setPInit);
    });
    
    $(".rLeft").click(function()
    {
        if (setP || setPInit)
        {
            db.r.z = db.r.z - 10;
        }
    });
    
    $(".rRight").click(function()
    {
        if (setP || setPInit)
        {
            db.r.z = db.r.z + 10;
        }
    });

    $("#xy-outer").on("vmousedown", function(e)
    {
        if (setP || setPInit)
        {
            getXY($(this), e);
        }
    }
    );
});
rate = 240;
printToScreen = true;
Pose = function()
{
    this.t = {x: 0, y:0, z:0};
    this.r = {x: 0, y:0, z:0};
};

//set internally
db = new Pose();
db.t = {x: 0.5, y: 0.5, z: 0.5};

//set externally
c = new Pose();
o = new Pose();
touch = new Pose();
init = new Pose();

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

scale_xy = 1.0;

update = function()
{
    setXY();
    setReadout();
}

printPose = function(name, pose)
{
    var tx = name + " .t .x";
    var ty = name + " .t .y";
    var tz = name + " .t .z";
    var rx = name + " .r .x";
    var ry = name + " .r .y";
    var rz = name + " .r .z";
    $(tx).text(pose.t.x.toPrecision(6));
    $(ty).text(pose.t.y.toPrecision(6));
    $(tz).text(pose.t.z.toPrecision(6));
    $(rx).text(pose.r.x.toPrecision(6));
    $(ry).text(pose.r.y.toPrecision(6));
    $(rz).text(pose.r.z.toPrecision(6));
}

setXYItem = function(name, x_, y_, angle_)
{
    var _css =
    {
        left: ((50. + x_ ).toString() + "%"),
        bottom: ((50. + y_).toString() + "%"),
        transform: "rotateZ(" + angle_ + "deg)"
    };
    
    $(name).css(_css);
}

setReadout = function()
{
    if (!printToScreen) {return;}
    printPose(".cam", c);
    printPose(".obj", o);
    printPose(".init", init)
    printPose(".touch", touch);
    
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
    setXYItem("#touch", touch.t.x, touch.t.y, touch.r.z);
    setXYItem(".axes.init", init.t.x, init.t.z, init.r.y);
    setXYItem("#camera",    c.t.x, c.t.z, c.r.y);
    setXYItem("#object",    o.t.x, o.t.z, o.r.y);
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
            
            db.t.x = normX.toPrecision(6) - 0.5;
            db.t.y = normY.toPrecision(6) - 0.5;
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
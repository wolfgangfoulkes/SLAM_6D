

isReady = false;

setXY = function(otx, oty, ctx, cty)
    {
        var ct =
        {
            bottom: cty.toString() + "%",
            left: ctx.toString() + "%"
        }
        
        var ot =
        {
            bottom: oty.toString() + "%",
            left: otx.toString() + "%"
        }
    
        
        $("#camera").css(ct);
        $("#object").css(ot);
        
        var _cty = $("#camera").css("bottom");
        var _ctx = $("#camera").css("left");
        
        var _oty = $("#object").css("bottom");
        var _otx = $("#object").css("left");
        
        console.log("camera: " + ctx + ", " + cty);
        console.log("object: " + otx + ", " + oty);

    };


jQuery(document).ready(function(){
//    $("#xy-outer").css("background-color", "blue");
    isReady = true;
    
    });
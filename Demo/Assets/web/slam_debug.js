jQuery(document).ready(function(){
    $("#camera").css("border-bottom-color", "blue");
    setXY = function(otx, oty, ctx, cty)
    {
        var ct =
        {
            bottom: cty,
            left: ctx
        }
        
        var ot =
        {
            bottom: oty,
            left: otx
        }
        
        $("#camera").css(ct);
        $("#object").css(ot);
    };

});
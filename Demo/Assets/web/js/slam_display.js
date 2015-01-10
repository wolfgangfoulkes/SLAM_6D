//Pose = function (){
//    this.t = {x: 0, y:0, z:0};
//    this.r = {x: 0, y:0, z:0};
//};
//
//Object = function(){
//    this.pose = new Pose();
//    this.path = " ";
//    this.object = null;
//};

//display = new function()
//{
//    this.$container = $(".display");
//    this.window_size =
//    {
//        x: 0,
//        y: 0
//    }
////    
////    this.animate = false;
////    this.objects = [];
////    this.objects[0] = new Object();
////    this.cam = new Pose();
//    
//    this.init = function()
//    {
////        display.scene = new THREE.Scene();
////        display.camera = new THREE.PerspectiveCamera(75, display.window_size.x / display.window_size.y, 0.1, 10000);
////        display.renderer = new THREE.WebGLRenderer();
////        display.renderer.setSize( display.window_size.x, display.window_size.y );
////        display.$container.appendChild( display.renderer.domElement );
////        setInterval(display.update, 240);
//    };
//    
//    this.update = function()
//    {
//        console.log(this.window_size.x);
//    };
//    
//    /***CALLBACKS***/
//    this.onWindowResize = function()
//    {
//        window_size.x = display.$container.width();
//        window_size.y = display.$container.height();
//    };
//};
//
//jQuery(document).ready(function(){
//    console.log("display did load");
//    $(window).resize(display.onWindowResize);
//    display.init();
//});
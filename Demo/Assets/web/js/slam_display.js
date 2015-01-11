defaultOr = function(arg_, default_)
{
    return (typeof arg_ !== "undefined") ? arg_ : default_;
}

Pose = function(){
    this.t = {x: 0, y:0, z:0};
    this.r = {x: 0, y:0, z:0, w:0};
    this.scale = {x: 0, y:0, z:0};
};

Model = function(){
    this.pose = new Pose();
    this.path = " ";
    this.model = 0;
};

display = new function()
{
    
    this.animate = false;
    this.models = []; //replace with object, so you can access by name
    this.cam = new Pose();
    
    this.init = function()
    {
        var $container = $(".display");
        display.scene = new THREE.Scene();
        display.camera = new THREE.PerspectiveCamera(750, $container.innerWidth() / $container.innerHeight(), 0.1, 100000);
        display.camera.useQuaternion = true;
        display.renderer = new THREE.WebGLRenderer();
        display.renderer.setSize( $container.innerWidth(), $container.innerHeight() );
        $container.append( display.renderer.domElement );
        setInterval(display.update, 1000/30);
    };
    
    this.update = function()
    {
        var $container = $(".display");
        display.camera.position.x = display.cam.t.x;
        display.camera.position.y = display.cam.t.y;
        display.camera.position.z = display.cam.t.z;
        display.camera.quaternion.x = display.cam.r.x;
        display.camera.quaternion.y = display.cam.r.y;
        display.camera.quaternion.z = display.cam.r.z;
        display.camera.quaternion.w = display.cam.r.w;
        
        display.renderer.render(display.scene, display.camera);
        display.models[0].model.rotation.y += 0.1;
    };
    
    this.addBox = function(x_, y_, z_, rx_, ry_, rz_, color_)
    {
        x_ = defaultOr(x_, 0);
        y_ = defaultOr(y_, 0);
        z_ = defaultOr(z_, 0);
        rx_ = defaultOr(rx_, 0);
        ry_ = defaultOr(ry_, 0);
        rz_ = defaultOr(rz_, 0);
        color_ = defaultOr(color_, 0);
        
        var pose_ = new Pose();
        pose_.t.x = x_;
        pose_.t.y = y_;
        pose_.t.z = z_;
        pose_.r.x = rx_;
        pose_.r.y = ry_;
        pose_.r.z = rz_;
        
        color_ = parseInt(color_.toString(16), 16);
        
        var geometry = new THREE.BoxGeometry(100, 100, 100);
        var material = new THREE.MeshBasicMaterial({ color: color_});
        var cube = new THREE.Mesh(geometry, material);
        cube.position.x = x_;
        cube.position.y = y_;
        cube.position.z = z_;
        display.scene.add(cube);
        
        var model = new Model();
        model.model = cube;
        model.pose = pose_;
        display.models[display.models.length] = model;
    }
    
//    this.addOBJ = function(path_, x_, y_, z_, rx_, ry_, rz_, rw_, scale, color_)
//    {
//        x_ = defaultOr(x_, 0);
//        y_ = defaultOr(y_, 0);
//        z_ = defaultOr(z_, 0);
//        rx_ = defaultOr(rx_, 0);
//        ry_ = defaultOr(ry_, 0);
//        rz_ = defaultOr(rz_, 0);
//        rw_ = defaultOr(rw_, 0);
//        color_ = defaultOr(color_, 0);
//        
//        var pose_ = new Pose();
//        pose_.t.x = x_;
//        pose_.t.y = y_;
//        pose_.t.z = z_;
//        pose_.r.x = rx_;
//        pose_.r.y = ry_;
//        pose_.r.z = rz_;
//        pose_.r.w = rw_;
//        
//        color_ = parseInt(color_.toString(16), 16);
//        
//        display.loadOBJ(path_,
//            function(object)
//            {
//                object.position.x = x_;
//                object.position.y = y_;
//                object.position.z = z_;
//                
//                object.quaternion.x = x_;
//                object.quaternion.y = y_;
//                object.quaternion.z = z_;
//                object.quaternion.w = w_;
//                
//                object.traverse(function (child) {
//                        if ( child instanceof THREE.Mesh )
//                        {
//                            child.material.color = color_;
//                            //child.material.map = texture;
//                        }
//                    }
//                );
//                
//                object.scale.x = scale_;
//                object.scale.y = scale_;
//                object.scale.z = scale_;
//                
//                display.scene.add(object);
//                
//                var model = new Model();
//                model.model = object;
//                model.pose = pose_;
//            }
//        );
//    };
//    
//    this.loadOBJ = function(path_, callback_)
//    {
//        var manager = new THREE.LoadingManager();
//        manager.onProgress = function (item, loaded, total)
//        {
//            console.log( item, loaded, total );
//        };
//        
//        var onProgress = function ( xhr )
//        {
//            if ( xhr.lengthComputable )
//            {
//                var percentComplete = xhr.loaded / xhr.total * 100;
//                console.log( Math.round(percentComplete, 2) + "% downloaded" );
//            }
//        };
//
//        var onError = function ( xhr )
//        {
//        };
//    
//        var loader = new THREE.OBJLoader( manager );
//        loader.load( path_, callback_, onProgress, onError );
//    };
};

jQuery(document).ready(function(){
    display.init();
});
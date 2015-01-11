defaultOr = function(arg_, default_)
{
    return (typeof arg_ !== 'undefined') ? arg_ : default_;
}

Pose = function(){
    this.t = {x: 0, y:0, z:0};
    this.r = {x: 0, y:0, z:0, w:0};
    
//    this.set = function(three_v_, three_r_)
//    {
//        three_v_ = defaultOr(three_v_, new THREE.Vector3(0, 0, 0));
//        three_r_ = defaultOr(three_r_, new THREE.Euler(0, 0, 0));
//        this.t.x = three_v_.x;
//        this.t.y = three_v_.y;
//        this.t.z = three_v_.z;
//        this.r.x = three_r_.x;
//        this.r.y = three_r_.y;
//        this.r.z = three_r_.z;
//    }
//    this.getVec3 = function()
//    {
//        return new THREE.Vector3(this.t.x, this.t.y, this.t.z);
//    }
//    
//    this.getEuler = function()
//    {
//        return new THREE.Euler(this.r.x, this.r.y, this.r.z);
//    }
};

Model = function(){
    this.pose = new Pose();
    this.path = " ";
    this.model = 0;
};

display = new function()
{
    
    this.animate = false;
    this.models = [];
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
        rx_ = defaultOr(x_, 0);
        ry_ = defaultOr(y_, 0);
        rz_ = defaultOr(z_, 0);
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
};

jQuery(document).ready(function(){
    display.init();
});

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

function buildAxes( length ) {
    var axes = new THREE.Object3D();

    axes.add( buildAxis( new THREE.Vector3( 0, 0, 0 ), new THREE.Vector3( length, 0, 0 ), 0xFF0000, false ) ); // +X, red, solid
    axes.add( buildAxis( new THREE.Vector3( 0, 0, 0 ), new THREE.Vector3( -length, 0, 0 ), 0xFF0000, true) ); // -X, red, dashed
    axes.add( buildAxis( new THREE.Vector3( 0, 0, 0 ), new THREE.Vector3( 0, length, 0 ), 0x00FF00, false ) ); // +Y, green, solid
    axes.add( buildAxis( new THREE.Vector3( 0, 0, 0 ), new THREE.Vector3( 0, -length, 0 ), 0x00FF00, true ) ); // -Y, green, dashed
    axes.add( buildAxis( new THREE.Vector3( 0, 0, 0 ), new THREE.Vector3( 0, 0, length ), 0x0000FF, false ) ); // +Z, blue, solid
    axes.add( buildAxis( new THREE.Vector3( 0, 0, 0 ), new THREE.Vector3( 0, 0, -length ), 0x0000FF, true ) ); // -Z, blue, dashed

    return axes;

}

function buildAxis( src, dst, colorHex, dashed ) {
    var geom = new THREE.Geometry(),
        mat; 

    if(dashed) {
        mat = new THREE.LineDashedMaterial({ linewidth: 3, color: colorHex, dashSize: 3, gapSize: 3 });
    } else {
        mat = new THREE.LineBasicMaterial({ linewidth: 3, color: colorHex });
    }

    geom.vertices.push( src.clone() );
    geom.vertices.push( dst.clone() );
    geom.computeLineDistances(); // This one is SUPER important, otherwise dashed lines will appear as simple plain lines

    var axis = new THREE.Line( geom, mat, THREE.LinePieces );

    return axis;

}

display = new function()
{
    
    this.models = {}; //replace with object, so you can access by name
    this.cam = new Pose();
    this.scene = null;
    this.camera = null;
    this.renderer = null;
    this.axes = null;
    this.animate = false;
    this.draw_axes = false;
    
    this.init = function()
    {
        console.log("init!");
        var $container = $(".display");
        display.scene = new THREE.Scene();
        display.camera = new THREE.PerspectiveCamera(750, $container.innerWidth() / $container.innerHeight(), 0.1, 100000);
        display.camera.useQuaternion = true;
        
        var ambient = new THREE.AmbientLight( 0xffffff );
		display.scene.add( ambient );
        display.renderer = new THREE.WebGLRenderer();
        display.renderer.setSize( $container.innerWidth(), $container.innerHeight() );
        
        $container.append( display.renderer.domElement );
        setInterval(display.update, 1000/30);
        
        // Add axes
        display.axes = buildAxes( 1000 );
        display.axes.visible = false;
        display.scene.add( display.axes );
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
        
        display.axes.visible = display.draw_axes;
        
        display.renderer.render(display.scene, display.camera);
    };
    
    
    this.addOBJ = function(name, obj_path_, x_, y_, z_, rx_, ry_, rz_, rw_, scale_)
    {
        x_ = defaultOr(x_, 0);
        y_ = defaultOr(y_, 0);
        z_ = defaultOr(z_, 0);
        rx_ = defaultOr(rx_, 0);
        ry_ = defaultOr(ry_, 0);
        rz_ = defaultOr(rz_, 0);
        rw_ = defaultOr(rw_, 0);
        scale_ = defaultOr(scale_, 1.0);
        
        //console.log("addOBJ:" + x_.toString() + ", " + y_.toString() + ", " + z_.toString());

        var pose_ = new Pose();
        pose_.t.x = x_;
        pose_.t.y = y_;
        pose_.t.z = z_;
        pose_.r.x = rx_;
        pose_.r.y = ry_;
        pose_.r.z = rz_;
        pose_.r.w = rw_;
        pose_.scale.x = scale_;
        pose_.scale.y = scale_;
        pose_.scale.z = scale_;

        /***** shared *****/
        var manager = new THREE.LoadingManager();
        manager.onProgress = function (item, loaded, total)
        {
            console.log( item, loaded, total );
        };
        var onProgress = function ( xhr )
        {
            if ( xhr.lengthComputable )
            {
                var percentComplete = xhr.loaded / xhr.total * 100;
                console.log( Math.round(percentComplete, 2) + "% downloaded" );
            }
        };
        var onError = function ( xhr )
        {
            console.log("error loading object!");
        };

        /***** load OBJ *****/
        var loaderOBJ = new THREE.OBJLoader( manager );
        var callbackOBJ = function (object)
        {
        	object.position.x = x_;
            object.position.y = y_;
            object.position.z = z_;
            //console.log("object position:" + object.position.x.toString() + ", " + object.position.y.toString() + ", " + object.position.z.toString());
            //object.position.set(x_, y_, z_);

            object.useQuaternion = true;
            
            object.quaternion.x = rx_;
            object.quaternion.y = ry_;
            object.quaternion.z = rz_;
            object.quaternion.w = rw_;
            //console.log("object quaternion:" + object.quaternion.x.toString() + ", " + object.quaternion.y.toString() + ", " + object.quaternion.z.toString() + object.quaternion.w.toString());
            //object.quaternion.set(rx_, ry_, rz_, rw_);
            
           object.scale.x = scale_;
           object.scale.y = scale_;
           object.scale.z = scale_;
           //console.log("object scale:" + object.scale.x.toString() + ", " + object.scale.y.toString() + ", " + object.scale.z.toString());
           //object.scale.set(scale_, scale_, scale_);

           object.traverse(function (child) {
				if ( child instanceof THREE.Mesh ) 
				{
					child.material.wireframe = true;
				}
			});

           	display.scene.add(object);
			
		/*** create new Model for OBJ ***/
			display.models[name] = new Model();
        	display.models[name].model = object;
       		display.models[name].pose = pose_;
        }
        loaderOBJ.load(obj_path_, callbackOBJ, onProgress, onError);
    };
    
    //can replace this with 2 functions, one that takes an object, and traverses and maps tex to obj
    this.addTexturedOBJ = function(name, obj_path_, image_path_, x_, y_, z_, rx_, ry_, rz_, rw_, scale_)
    {
        
        x_ = defaultOr(x_, 0);
        y_ = defaultOr(y_, 0);
        z_ = defaultOr(z_, 0);
        rx_ = defaultOr(rx_, 0);
        ry_ = defaultOr(ry_, 0);
        rz_ = defaultOr(rz_, 0);
        rw_ = defaultOr(rw_, 0);
        scale_ = defaultOr(scale_, 1.0);
        
        //console.log("addTexturedOBJ:" + x_.toString() + ", " + y_.toString() + ", " + z_.toString());

        var pose_ = new Pose();
        pose_.t.x = x_;
        pose_.t.y = y_;
        pose_.t.z = z_;
        pose_.r.x = rx_;
        pose_.r.y = ry_;
        pose_.r.z = rz_;
        pose_.r.w = rw_;
        pose_.scale.x = scale_;
        pose_.scale.y = scale_;
        pose_.scale.z = scale_;

        /***** shared *****/
        var manager = new THREE.LoadingManager();
        manager.onProgress = function (item, loaded, total)
        {
            console.log( item, loaded, total );
        };
        var onProgress = function ( xhr )
        {
            if ( xhr.lengthComputable )
            {
                var percentComplete = xhr.loaded / xhr.total * 100;
                console.log( Math.round(percentComplete, 2) + "% downloaded" );
            }
        };
        var onError = function ( xhr )
        {
            console.log("error loading object!");
        };

        /***** create texture to map onto object *****/
        var texture = new THREE.Texture(); 

        /***** load OBJ *****/
        var loaderOBJ = new THREE.OBJLoader( manager );
        var callbackOBJ = function (object)
        {
            object.position.x = x_;
            object.position.y = y_;
            object.position.z = z_;
            //object.position.set(x_, y_, z_);
            
            //console.log("textured object position:" + object.position.x.toString() + ", " + object.position.y.toString() + ", " + object.position.z.toString());

            object.useQuaternion = true;
            
            object.quaternion.x = rx_;
            object.quaternion.y = ry_;
            object.quaternion.z = rz_;
            object.quaternion.w = rw_;
            //console.log("textured object quaternion:" + object.quaternion.x.toString() + ", " + object.quaternion.y.toString() + ", " + object.quaternion.z.toString() + object.quaternion.w.toString());
            //object.quaternion.set(rx_, ry_, rz_, rw_);
            
           object.scale.x = scale_;
           object.scale.y = scale_;
           object.scale.z = scale_;
           //console.log("textured object scale:" + object.scale.x.toString() + ", " + object.scale.y.toString() + ", " + object.scale.z.toString());
           //object.scale.set(scale_, scale_, scale_);

           object.traverse(function (child) {
                if ( child instanceof THREE.Mesh ) 
                {
                    child.material.map = texture;
                }
            });

            display.scene.add(object);
			
		/*** create new Model for OBJ ***/
			display.models[name] = new Model();
        	display.models[name].model = object;
       		display.models[name].pose = pose_;
        }
        loaderOBJ.load(obj_path_, callbackOBJ, onProgress, onError);

       	var loaderImage = new THREE.ImageLoader(manager);
       	var callbackImage = function (image) 
       	{
       		texture.image = image;
	        texture.needsUpdate = true;
       	}
       	loaderImage.load(image_path_, callbackImage, onProgress, onError);
    };
};

jQuery(document).ready(function(){
});
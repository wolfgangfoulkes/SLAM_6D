

#import "DebugHandler.h"
#import <iostream>

DebugHandler::DebugHandler()
{
    jsIsInit = false;
    jsIsReady = false;
    this->show = false;
    printLog = false;
    
    pose = nil;
    t_touch = metaio::Vector2d(0, 0);
    COS = -1;
    tracking_state = "unknown";
    called = 0;
}

void DebugHandler::initJS(JSContext * ctx_)
{
    ctx = ctx_;
    
    [ctx setExceptionHandler:^(JSContext *context, JSValue *value) {
        NSLog(@"%@", value);
    }];
    
    ctx[@"console"][@"log"] = ^(JSValue *msg)
    {
        NSLog(@"JavaScript %@ log message: %@", [JSContext currentContext], msg);
    }; //works for all console.log messages
    
    this->initGL();
    
    ctx[@"SCALE_COEFF"] = @(SCALE_COEFF);
    
    jsIsInit = true;
}

void DebugHandler::update()
{
    if (!jsIsInit)
    {
        return;
    }

    if (!jsIsReady)
    {
        jsIsReady = ctx[@"isReady"].toBool;
        return;
    }
    
    if (!this->pose)
    {
        return;
    }
    
    this->getJS();
    
    ctx[@"printToScreen"] = @(this->show);
    if (this->show)
    {
        this->updateReadout();
    }
    
    this->updateGL();
    
    if (printLog)
    {
        ctx[@"log"] = this->log;
    }
}

void DebugHandler::updateReadout()
{
    metaio::Vector3d SCALE(X_COEFF, Y_COEFF, Z_COEFF);
    
    metaio::Vector3d _offs = metaio::Vector3d(this->pose->t_offs); _offs = round(_offs, SIG_FIGS);  _offs = scale(_offs, SCALE);
    metaio::Vector3d _cam = metaio::Vector3d(this->pose->t_p);      _cam = round(_cam, SIG_FIGS);    _cam = scale(_cam, SCALE);
    metaio::Vector3d _obj = metaio::Vector3d(this->pose->t_last);   _obj = round(_obj, SIG_FIGS);    _obj = scale(_obj, SCALE);
//    metaio::Vector3d _obj1 = this->pose->r_last.rotatePoint(this->o_t) + this->pose->t_last;
    //_obj1 = round(_obj1, SIG_FIGS);  _obj1 = scale(_obj1, SCALE);
    
    metaio::Vector3d _obj1_t = this->pose->r_last.rotatePoint(this->o_t) + this->pose->t_last;
    double a = 0;
    double e = 0;
    double d = 0;
    cartesianToSpherical(_obj1_t, this->pose->r_last, a, e, d);
    metaio::Vector3d _obj1 = metaio::Rotation(0, dToR(a), 0).rotatePoint(metaio::Vector3d(0, 0, d));
    _obj1 = round(_obj1, SIG_FIGS);  _obj1 = scale(_obj1, SCALE);
    //logMA([NSString stringWithFormat:@"%f, %f, %f", a, e, d], this->log);
    
    metaio::Vector3d _cf_acc = metaio::Vector3d(this->cf_acc);   _cf_acc = round(_cf_acc, SIG_FIGS);
    
    updatePose(@"init", _offs, this->pose->r_offs);
    updatePose(@"c", _cam , this->pose->r_p);
    updatePose(@"o", _obj , this->pose->r_last);
    updatePose(@"o1", _obj1 , this->pose->r_last);
    updatePose(@"sensors", this->acc, this->gyr);
    updatePose(@"filter", this->cf_acc, this->cf_gyr);
    
    ctx[@"COS"][@"idx"] = @(COS); //@(this->pose->COS);
    ctx[@"COS"][@"state"] = [NSString stringWithFormat:@"%s", tracking_state.c_str()];
}

void DebugHandler::initGL()
{
    JSValue * display_init = ctx[@"display"][@"init"];
    
    [display_init callWithArguments:@[]];
    
    ctx[@"display"][@"draw_axes"] = @(DRAW_AXES);
}

void DebugHandler::updateGL()
{
    //scale rotation? looks OK now. it's very possible that rotation is scale-independent (for the camera)
    metaio::Vector3d _scaled = metaio::Vector3d(this->pose->t_p);
    _scaled.x *= SCALE_COEFF;
    _scaled.y *= SCALE_COEFF;
    _scaled.z *= SCALE_COEFF;
    this->updateCamera(_scaled, this->pose->r_p);
}

void DebugHandler::getJS()
{
    
    printLog = [ctx[@"printLog"] toBool];
    
    if (TOUCH)
    {
    
        metaio::Vector3d _t(0, 0, 0);
        metaio::Rotation _r; _r.setNoRotation();

        double t_x = [ctx[@"db"][@"t"][@"x"] toDouble];
        double t_y = [ctx[@"db"][@"t"][@"y"] toDouble];
        double r_y = [ctx[@"db"][@"r"][@"y"] toDouble];
        
        t_touch.x = t_x;
        t_touch.y = t_y;
        
        _t.x = t_x * TOUCH_X_COEFF;
        _t.y = t_y * TOUCH_Y_COEFF;
        
        _r = metaio::Rotation(dToR(0), dToR(r_y), dToR(0));
        
        r_touch = _r;

        updatePose(@"touch", _t, _r);
        
        SCALE_COEFF = [ctx[@"SCALE_COEFF"] toDouble];
    }
}

void DebugHandler::updatePose(NSString * pose_, metaio::Vector3d t_, metaio::Rotation r_)
{
    metaio::Vector3d r_e_ = r_.getEulerAngleDegrees();

    ctx[pose_][@"t"][@"x"] = @(t_.x);
    ctx[pose_][@"t"][@"y"] = @(t_.y);
    ctx[pose_][@"t"][@"z"] = @(t_.z);
    
    ctx[pose_][@"r"][@"x"] = @(r_e_.x);
    ctx[pose_][@"r"][@"y"] = @(r_e_.y);
    ctx[pose_][@"r"][@"z"] = @(r_e_.z);
}

void DebugHandler::setPose()
{
    metaio::Vector3d _t;
    metaio::Rotation _r;
    double r_y = ctx[@"db"][@"r"][@"z"].toDouble;
    _r.setFromEulerAngleDegrees(metaio::Vector3d(0, r_y, 0));
    
    _t.x = t_touch.x * TOUCH_X_COEFF * (1/X_COEFF);
    _t.z = t_touch.y * TOUCH_Y_COEFF * (1/Y_COEFF);
    if (ctx[@"setPInit"].toBool)
    {
        pose->setOffs(_t, _r);
    }
    if (ctx[@"setP"].toBool)
    {
        pose->updateP(_t, _r, 0);
    }
}

void DebugHandler::addOBJ(NSString * name_, NSString * obj_path_, metaio::Vector3d t_, metaio::Rotation r_, float scale_)
{
    Object3D * obj = new Object3D();
    t_.x *= SCALE_COEFF;
    t_.y *= SCALE_COEFF;
    t_.z *= SCALE_COEFF;
    obj->init(name_.UTF8String, obj_path_.UTF8String, t_, r_, scale_);
    this->things.push_back(obj);
    
    metaio::Vector4d qu_ = r_.getQuaternion();
    JSValue * addOBJJS = ctx[@"display"][@"addOBJ"];
    [addOBJJS callWithArguments:@[
        [NSString stringWithString: name_],
        [NSString stringWithString: obj_path_],
        @(t_.x), @(t_.y), @(t_.z), @(qu_.x), @(qu_.y), @(qu_.z), @(qu_.w), @(scale_)]];
}

void DebugHandler::addOBJ(NSString * name_, NSString * obj_path_, NSString * tex_path_, metaio::Vector3d t_, metaio::Rotation r_, float scale_)
{
    Object3D * obj = new Object3D();
    obj->init(name_.UTF8String, obj_path_.UTF8String, t_, r_, scale_);
    this->things.push_back(obj);
    
    metaio::Vector4d qu_ = r_.getQuaternion();
    JSValue * addOBJJS = ctx[@"display"][@"addTexturedOBJ"];
    [addOBJJS callWithArguments:@[
        [NSString stringWithString: name_],
        [NSString stringWithString: obj_path_],
        [NSString stringWithString: tex_path_],
        @(t_.x), @(t_.y), @(t_.z), @(qu_.x), @(qu_.y), @(qu_.z), @(qu_.w), @(scale_)]];
}

Thing * DebugHandler::getThing(std::string name_)
{
    for (int i = 0; i < things.size(); i++)
    {
        Thing * _thing = things[i];
        if (_thing->name == name_)
        {
            return _thing;
        }
    }
    return NULL;
}

Thing * DebugHandler::getThing(NSString * name_)
{
    return this->getThing(name_.UTF8String);
}

Object3D * DebugHandler::getOBJ(std::string name_)
{
    for (int i = 0; i < things.size(); i++)
    {
        Thing * _thing = things[i];
        if ((_thing->type == "Object3D") && (_thing->name == name_))
        {
            return dynamic_cast<Object3D *>(_thing);
        }
    }
    
    return NULL;
}

Object3D * DebugHandler::getOBJ(NSString * name_)
{
    return this->getOBJ(name_.UTF8String);
}

void DebugHandler::setOBJVisibility(NSString * name_, bool visibility_)
{
    Object3D * obj = this->getOBJ(name_);
    if (!obj) { return; }
    
    obj->is_render = visibility_;
    JSValue * model = ctx[@"display"][@"models"][name_][@"model"];
    model[@"visible"] = @(visibility_);
//    if ([model[@"visible"] toBool])
//    {
//        printf("%s %s", [name_ UTF8String], "is visible!");
//    }
//    else
//    {
//        printf("%s %s", [name_ UTF8String], "is not visible!");
//    }
}

void DebugHandler::updateCamera(metaio::Vector3d t_, metaio::Rotation r_)
{
    metaio::Vector4d qu_ = r_.getQuaternion();
//    ctx[@"display"][@"cam"][@"t"][@"x"] = @(t_.x);
//    ctx[@"display"][@"cam"][@"t"][@"y"] = @(t_.y);
//    ctx[@"display"][@"cam"][@"t"][@"z"] = @(t_.z);
//    ctx[@"display"][@"cam"][@"r"][@"x"] = @(qu_.x);
//    ctx[@"display"][@"cam"][@"r"][@"y"] = @(qu_.y);
//    ctx[@"display"][@"cam"][@"r"][@"z"] = @(qu_.z);
//    ctx[@"display"][@"cam"][@"r"][@"w"] = @(qu_.w);
    ctx[@"display"][@"cam"] = toDict(t_, qu_);
}


//- (void)addPose: (int)name ToDebugContextT: (metaio::Vector4d)obj_t andR:(metaio::Rotation)obj_r
//{
//      metaio::Vector3d obj_e = obj_r.getEulerAngleDegrees();
//    /*http://www.bignerdranch.com/blog/objective-c-literals-part-1/*/
//    /*simpler to do this by creating a new version of an existing object with params?*/
//    ctx[@"poses"][[NSString stringWithFormat:@"%d", name]] =
//    @{
//        @"t" : @{ @"x" : @(obj_t.x), @"y" : @(obj_t.y), @"z" : @(obj_t.z) },
//        @"r" : @{ @"x" : @(obj_e.x), @"y" : @(obj_e.y), @"z" : @(obj_e.z) }
//        };
//}




#import "DebugHandler.h"
#import <iostream>

DebugHandler::DebugHandler()
{
    jsIsInit = false;
    jsIsReady = false;
    print = false;
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
    
    jsIsInit = true;
}

void DebugHandler::getJS()
{
    
    printLog = [ctx[@"printLog"] toBool];
    
    metaio::Vector3d _t(0, 0, 0);
    metaio::Rotation _r; _r.setNoRotation();

    double t_x = [ctx[@"db"][@"t"][@"x"] toDouble];
    double t_y = [ctx[@"db"][@"t"][@"y"] toDouble];
    double r_z = [ctx[@"db"][@"r"][@"z"] toDouble];
    
    t_touch.x = t_x;
    t_touch.y = t_y;
    
    _t.x = t_x * TOUCH_X_COEFF;
    _t.y = t_y * TOUCH_Y_COEFF;
    
    _r = metaio::Rotation(dToR(0), dToR(0), dToR(r_z));

    updatePose(@"touch", _t, _r);
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
    
    if (!pose || !this->print)
    {
        return;
    }
    
    ctx[@"printToScreen"] = @(this->print);
    
    getJS();
    
    metaio::Vector3d SCALE(X_COEFF, Y_COEFF, Z_COEFF);
    metaio::Vector3d _offs = metaio::Vector3d(this->pose->t_offs); _offs = round(_offs, SIG_FIGS);  _offs = scale(_offs, SCALE);
    metaio::Vector3d _cam = metaio::Vector3d(this->pose->t_p);      _cam = round(_cam, SIG_FIGS);    _cam = scale(_cam, SCALE);
    metaio::Vector3d _obj = metaio::Vector3d(this->pose->t_last);   _obj = round(_obj, SIG_FIGS);    _obj = scale(_obj, SCALE);
    
    metaio::Vector3d _cf_acc = metaio::Vector3d(this->cf_acc);   _cf_acc = round(_cf_acc, SIG_FIGS);
    
    updatePose(@"init", _offs, this->pose->r_offs);
    updatePose(@"c", _cam , this->pose->r_p);
    updatePose(@"o", _obj , this->pose->r_last);
    updatePose(@"sensors", this->acc, this->gyr);
    updatePose(@"filter", this->cf_acc, this->cf_gyr);
    
    ctx[@"COS"][@"idx"] = @(COS); //@(this->pose->COS);
    ctx[@"COS"][@"state"] = [NSString stringWithFormat:@"%s", tracking_state.c_str()];
    
    if (printLog)
    {
        ctx[@"log"] = this->log;      
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


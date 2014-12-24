

#import "DebugHandler.h"
#import <iostream>

DebugHandler::DebugHandler()
{
    jsIsInit = false;
    jsIsReady = false;
    print = false;
    printLog = false;
    
    pose = nil;
    t1_out = t0_out = metaio::Vector3d(0, 0, 0);
    t_touch = metaio::Vector2d(0, 0);
    r0_out.setNoRotation();
    r1_out.setNoRotation();
    COS = -1;
    tracking_state = "unknown";
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
    
    updatePose(@"init", _offs, this->pose->r_offs);
    updatePose(@"c", _cam , this->pose->r_p);
    updatePose(@"o", _obj , this->pose->r_last);
    
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


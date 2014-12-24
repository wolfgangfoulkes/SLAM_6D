

#import "DebugHandler.h"
#import <iostream>

DebugHandler::DebugHandler()
{
    jsIsInit = false;
    jsIsReady = false;
    print = false;
    printLog = false;
    
    t1_out = t0_out = t_touch = metaio::Vector3d(0, 0, 0);
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
    
    bool setP = [ctx[@"setP"] toBool];
    bool setPInit = [ctx[@"setPInit"] toBool];
    printLog = [ctx[@"printLog"] toBool];
    
    metaio::Vector3d _t(0, 0, 0);
    metaio::Rotation _r; _r.setNoRotation();

    double t_x = [ctx[@"db"][@"t"][@"x"] toDouble] - 0.5;
    double t_y = [ctx[@"db"][@"t"][@"y"] toDouble] - 0.5;
    double t_z = [ctx[@"db"][@"t"][@"z"] toDouble] - 0.5;
    double r_x = [ctx[@"db"][@"r"][@"x"] toDouble];
    double r_y = [ctx[@"db"][@"r"][@"y"] toDouble];
    double r_z = [ctx[@"db"][@"r"][@"z"] toDouble];
    
    t_touch.x = t_x;
    t_touch.y = t_y;
    t_touch.z = t_z;
    
    _t.x = t_x * TOUCH_X_COEFF;
    _t.y = t_y * TOUCH_Y_COEFF;
    _t.z = t_z * TOUCH_Z_COEFF;
    
    _r = metaio::Rotation(dToR(r_x), dToR(r_y), dToR(r_z));

    
    updatePose(@"touch", _t, _r);
    
    if (setPInit)
    {
        this->pose.initP(_t, _r, 1);
    }
    
    if (setP)
    {
        this->pose.updateP(_t, _r);
    }
}

void DebugHandler::reset()
{
    metaio::Vector3d _t(0, 0, 0);
    metaio::Rotation _r; _r.setNoRotation();
    metaio::Vector3d _t_db(0.5, 0.5, 0.5);
    
    this->pose = Pose();
    this->t_touch.setZero();
    updatePose(@"db", _t_db, _r);
}

void DebugHandler::update()
{
    if (!jsIsInit)
    {
        return;
    }

//    jsIsReady = ctx[@"isReady"].toBool;
    if (!jsIsReady)
    {
        jsIsReady = ctx[@"isReady"].toBool;
        return;
    }

    getJS();
    
    updatePose(@"init", this->pose.t_offs, this->pose.r_offs);
    
    ctx[@"printToScreen"] = @(this->print);
    
    if (this->print)
    {
        updatePose(@"c", t0_out, r0_out);
        updatePose(@"o", t1_out, r1_out);
        ctx[@"COS"][@"idx"] = @(COS);
        ctx[@"COS"][@"state"] = [NSString stringWithFormat:@"%s", tracking_state.c_str()];

    }
    
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


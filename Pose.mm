
#import "common.h"
#import "Pose.h"


Pose::Pose()
{
    t_p.setZero();
    t_last.setZero();
    t_offs.setZero();
    t_world.setZero();
    
    r_p.setNoRotation();
    r_last.setNoRotation();
    r_offs.setNoRotation();
    r_world.setNoRotation();
    
    isTracking = false;
    hasInitPose = false;
    COS = 0;
}

Pose::Pose(metaio::Vector3d t_, metaio::Rotation r_) : Pose()
{
    t_world = metaio::Vector3d(t_);
    r_world = metaio::Rotation(r_);
}

void Pose::initP(metaio::Vector3d t_, metaio::Rotation r_, int cos_)
{
    metaio::Vector3d t_p_ = r_.inverse().rotatePoint(mult(t_, -1.0f));
    r_offs = r_.inverse() * r_last;
    t_offs = r_.inverse().rotatePoint(t_last) + t_p_;
    
    COS = cos_;

    hasInitPose = true;
    isTracking = true;
}

void Pose::initP(metaio::TrackingValues tv_)
{
    metaio::Vector3d t_ = tv_.translation;
    metaio::Rotation r_ = tv_.rotation;
    int cos_ = tv_.coordinateSystemID;
    initP(t_, r_, cos_);
}

void Pose::updateP(metaio::Vector3d t_, metaio::Rotation r_)
{
    metaio::Vector3d _t(0, 0, 0);
    metaio::Rotation _r; _r.setNoRotation();
    
    _t = t_ + r_.rotatePoint(t_offs);
    t_last = _t;
    //t_last =  loPassXYZ(t_last, _t);
    
    _r = r_ * r_offs;
    r_last = _r; //lo-pass this too, this especially
    
    t_p = _r.inverse().rotatePoint(mult(_t, -1.));
    r_p = _r.inverse();
}


void Pose::updateP(metaio::TrackingValues tv_)
{
    if (tv_.coordinateSystemID != COS)
    {
        hasInitPose = false;
    }
    
    if (tv_.quality > 0.) //not lost, could be extrapolated
    {
        if (!hasInitPose)
        {
            initP(tv_);
        }
        metaio::Vector3d t_ = tv_.translation;
        metaio::Rotation r_ = tv_.rotation;

        updateP(t_, r_);
    }
    else
    {
        hasInitPose = false;
        isTracking = false;
    }
    
}

#import "common.h"
#import "Pose.h"


Pose::Pose()
{
    this->t_p.setZero();
    this->t_last.setZero();
    this->t_offs.setZero();
    this->t_world.setZero();
    
    this->r_p.setNoRotation();
    this->r_last.setNoRotation();
    this->r_offs.setNoRotation();
    this->r_world.setNoRotation();
    
    this->hasTracking = false;
    this->hasOffs = false;
    this->COS = 0;
}

Pose::Pose(metaio::Vector3d t_, metaio::Rotation r_) : Pose()
{
    this->t_world = metaio::Vector3d(t_);
    this->r_world = metaio::Rotation(r_);
}

void Pose::setInitOffs(metaio::Vector3d t_, metaio::Rotation r_, int cos_)
{
}

void Pose::setInitOffs(metaio::TrackingValues tv_)
{
}

void Pose::setOffs(metaio::Vector3d t_, metaio::Rotation r_)
{
    metaio::Vector3d t_p_ = r_.inverse().rotatePoint(mult(t_, -1.0f));
    this->r_offs = r_.inverse() * this->r_last;
    this->t_offs = r_.inverse().rotatePoint(this->t_last) + t_p_;

    this->hasOffs = true;
}

void Pose::setOffs(metaio::TrackingValues tv_)
{
    metaio::Vector3d t_ = tv_.translation;
    metaio::Rotation r_ = tv_.rotation;
    this->setOffs(t_, r_);
}

void Pose::updateP(metaio::Vector3d t_, metaio::Rotation r_, int cos_)
{
    if (!this->hasTracking) {this->hasTracking = true;}
    metaio::Vector3d _t(0, 0, 0);
    metaio::Rotation _r; _r.setNoRotation();
    
    _t = t_ + r_.rotatePoint(this->t_offs);
    this->t_last = _t; //this->t_last =  loPassXYZ(this->t_last, _t);
    
    _r = r_ * this->r_offs;
    this->r_last = _r; //lo-pass this too, this especially
    
    this->t_p = _r.inverse().rotatePoint(mult(this->t_last, -1.0f));
    this->r_p = _r.inverse();
    
    this->COS = cos_;
}


void Pose::updateP(metaio::TrackingValues tv_)
{
    this->updateP(tv_.translation, tv_.rotation, tv_.coordinateSystemID);
}
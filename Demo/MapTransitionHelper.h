#ifndef __MapTransitionHelper__
#define __MapTransitionHelper__

#include <metaioSDK/Common/TrackingValues.h>
#include <metaioSDK/Common/SensorValues.h>

namespace metaio
{
	
/**  MapTransitionHelper
*
* This class helps us to keep moving from one SLAM map to the next one 
* (e.g. when we loose tracking in between)
* and to do this without the user noticing the transition.
*
* This class is layered between the metaio SDK and the client app, i.e. the
* poses out of this one are going to be used in the display.
*
* Copyright 2007-2014 metaio GmbH. All rights reserved.
*/
class MapTransitionHelper
{
	public:
	
	MapTransitionHelper()
	{
		reset();
	}
	
	void reset()
	{
		m_offset_newCOS_from_oldCOS.rotation.setNoRotation();
		m_offset_newCOS_from_oldCOS.translation.setZero();
		
		m_last_camera_pose.rotation.setNoRotation();
		m_last_camera_pose.translation.setZero();
		
		m_last_camera_pose_valid = false;
		m_recompute_offset_after_next_initialized = false;
	}
	
	/** Call this method when we can expect the transition to a new SLAM map soon (i.e. old map is abandoned) */
	void prepareForTransitionToNewMap()
	{
		m_recompute_offset_after_next_initialized = true;
	}
	
	/** Update the internal state with the latest tracking values from the SDK.
	 * \param trackingValues the latest tracking values.
	 */
	void update(const metaio::TrackingValues& trackingValues,
				const metaio::SensorValues& sensorValues)
	{
		// agenda:
		// 1) if we are still tracking:
		//		  just update the 4x4 field and exit.
		// 2) if we are currently lost (tracking):
		//        use the attitude/orientation of the last pose until we can re-initialize SLAM
		//
		if (trackingValues.quality > 0 &&
			 trackingValues.state != metaio::ETS_INITIALIZATION_FAILED)
		{
			
			// frame was tracked - now we might have the special situation that a
			// new SLAM map was started, so that we have to update our offsets:
			if (m_recompute_offset_after_next_initialized && m_last_camera_pose_valid)
			{
				// this is the offset, assuming the same scale.
				 m_offset_newCOS_from_oldCOS.rotation = trackingValues.rotation.inverse() * m_last_camera_pose.rotation;
				 m_offset_newCOS_from_oldCOS.translation =
					trackingValues.rotation.inverse().rotatePoint(m_last_camera_pose.translation) +
					trackingValues.getInverseTranslation();
					
				m_recompute_offset_after_next_initialized = false;
			}
			
			
			// frame can be tracked -> compute the 4x4 matrix directly.
			// now go from the current SLAM map to the global origin:
			metaio::TrackingValues global_camera_pose;
			global_camera_pose = trackingValues;
			
			global_camera_pose.rotation = trackingValues.rotation * m_offset_newCOS_from_oldCOS.rotation;
			global_camera_pose.translation = trackingValues.translation +
				trackingValues.rotation.rotatePoint(m_offset_newCOS_from_oldCOS.translation);
			  
			m_last_camera_pose = global_camera_pose;
			m_last_camera_pose_valid = true;
		}
		else
		{
			// not tracking, -> extrapolate with attitude/orientation
			
			// part to be used when last pose is not valid:
			if (m_last_camera_pose_valid)
			{
				// we once did successfully track, so we can use this for bridging
				// the current initialization attempt:
				const metaio::SensorValues& sv = sensorValues;
				
				// compute the relative rotation (similar to the SmoothingFuser)
				metaio::Rotation current_from_last_frame = sv.attitude * m_last_sensor_values.attitude.inverse();
				
                // apply it to the pose:
				metaio::Rotation current_camera_pose_R = current_from_last_frame * m_last_camera_pose.rotation;
				metaio::Vector3d current_camera_pose_t = current_from_last_frame.rotatePoint(m_last_camera_pose.translation);
				
				// we save it to our member that holds the last pose.
				m_last_camera_pose.rotation = current_camera_pose_R;
				m_last_camera_pose.translation = current_camera_pose_t;
			}
		}
		
		m_last_sensor_values = sensorValues;
		
	};
	
	/** \return the translation of the "fused" camera pose
	 */
	metaio::Vector3d getTranslationCameraFromWorld() const
	{
		return m_last_camera_pose.translation;
	}

	/** \return rotation of the "fused" camera pose
	 */
	metaio::Rotation getRotationCameraFromWorld() const
	{
		return m_last_camera_pose.rotation;
	}
	
	/** \returns true when the last frame could be tracked successfully */
	bool lastFrameWasTracked() const
	{
		return (m_last_camera_pose.quality > 0 &&
				m_last_camera_pose.state != metaio::ETS_INITIALIZATION_FAILED);
	}
    
    // storing the last pose and attitude/orientation to update the pose while initializing.
	bool m_last_camera_pose_valid;
	
	// to stay in the same cos, we need one cos offset (6DoF only, scale is not being considered for now).
	metaio::TrackingValues m_offset_newCOS_from_oldCOS;
	bool m_recompute_offset_after_next_initialized;

	metaio::TrackingValues m_last_camera_pose;
	metaio::SensorValues m_last_sensor_values;
	
private:
	
	
	
	
};
	
} // namespace metaio


#endif 

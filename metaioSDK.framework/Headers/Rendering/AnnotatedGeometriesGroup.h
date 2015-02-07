// Copyright 2007-2013 metaio GmbH. All rights reserved.
#ifndef _AS_ANNOTATEDGEOMETRIESGROUP_H_
#define _AS_ANNOTATEDGEOMETRIESGROUP_H_

#include <Common/Logging.h>
#include <Rendering/IAnnotatedGeometriesGroup.h>
#include <Common/Cpp11Macros.h>

#include <Irrlicht/matrix4.h>

#include <map>
#include <vector>

namespace metaio
{
namespace common
{
class IMonotonicTimer;
}
class IMetaioSDK;
class IMetaioSDKPrivate;
struct SensorValues;

/**
 * Implementation of IAnnotatedGeometriesGroup
 */
class AnnotatedGeometriesGroup : public IAnnotatedGeometriesGroup
{
public:
	/**
	 * constructor
	 */
	AnnotatedGeometriesGroup(IMetaioSDK* sdk, IMetaioSDKPrivate* sdkPrivate);
	virtual ~AnnotatedGeometriesGroup();

	// IAnnotatedGeometriesGroup BEGIN
	virtual bool addGeometry(IGeometry* geometry, void* userData) AS_CPP11_OVERRIDE;
	virtual IGeometry* getAnnotationForGeometry(IGeometry* geometry) AS_CPP11_OVERRIDE;
	virtual void registerCallback(IAnnotatedGeometriesGroupCallback* callback) AS_CPP11_OVERRIDE;
	virtual void removeGeometry(IGeometry* geometry) AS_CPP11_OVERRIDE;
	virtual void setBottomPadding(unsigned int value) AS_CPP11_OVERRIDE;
	virtual void setConnectingLineColorForGeometry(IGeometry* geometry, int red, int green, int blue, int alpha) AS_CPP11_OVERRIDE;
	virtual void setDefaultConnectingLineColor(int red, int green, int blue, int alpha) AS_CPP11_OVERRIDE;
	virtual void setMaximumNumberOfAnnotatedGeometries(int count) AS_CPP11_OVERRIDE;
	virtual void setMaximumNumberOfAnnotationRows(int count) AS_CPP11_OVERRIDE;
	virtual void setSelectedGeometry(IGeometry* geometry) AS_CPP11_OVERRIDE;
	virtual void triggerAnnotationUpdate(IGeometry* geometry) AS_CPP11_OVERRIDE;
	// IAnnotatedGeometriesGroup END

	/**
	 * Adds geometry to the group
	 *
	 * \param geometry Geometry to add. A geometry pointer may not be added twice (leads to error).
	 *                 Caller is responsible for removing the geometry and destroying it.
	 * \param userData Will be passed to callback along with the geometry pointer
	 * \param userDataIsJavaObject bool specifying if the userData carries a java object
	 * \return True on success, false if geometry could not be added
	 */
	bool addGeometry(IGeometry* geometry, void* userData, bool userDataIsJavaObject);

	/**
	 * Remove a geometry and optionally omit error in case it was not part of the group
	 *
	 * Caller is responsible for destroying both the geometry and its annotation (which is not used
	 * anymore by this class after this call) after calling this method!
	 *
	 * \param geometry Geometry to remove
	 * \param omitNotFoundError If true and the geometry is not part of the group, no error will be logged
	 */
	void removeGeometry(IGeometry* geometry, bool omitNotFoundError);

	/**
	 * Updates the group using a fairly complex "algorithm" that determines which annotations can
	 * be placed and where.
	 *
	 * Should be called after the SDK has updated all geometries using
	 * Geometry::updateTranslationFromLLA() in order to use the correct translation value.
	 * The mono display calibration should be set while this is called, so that geometries' screen
	 * position is returned for the mono case by IMetaioSDK::getViewportCoordinatesFrom3DPosition.
	 *
	 * Before rendering, the annotation positions must be updated for the current screen space
	 * projection matrix using updateAnnotationPositionsWithProjectionMatrix.
	 *
	 * \sa updateAnnotationPositionsWithProjectionMatrix
	 */
	void update();

	/**
	 * Updates the annotation positions using the given screen space projection matrix
	 *
	 * \param projectionMatrix	Screen space projection matrix (not camera projection matrix!) that
	 *							will be used for rendering
	 * \param nearCP			Near clipping plane of the projection matrix
	 * \param isStereoRendering	Defines whether this call is done before a draw call for either left
	 *							or right eye in case of stereo rendering. This is used to decide
	 *							whether X viewport coordinates must be multiplied by 2 or not, and
	 *							whether the geometry position must be recalculated.
	 */
	void updateAnnotationPositionsWithProjectionMatrix(const irr::core::matrix4& projectionMatrix,
		float nearCP, bool isStereoRendering);

private:

	struct GeometryWithAnnotation
	{
		GeometryWithAnnotation();

		/// Geometry to use as annotation
		IGeometry*				annotation;

		/// Annotation dimensions (only valid if annotation loaded)
		Vector2di				annotationDim;

		/// Current annotation position in viewport pixel coordinates
		Vector2di				annotationPos;

		/**
		 * Preferred X annotation position in case an annotation was removed and we will attempt to
		 * reinsert it right away. The value std::numeric_limits<int>::min() means no preference.
		 */
		int						backupAnnotationPosX;

		/**
		 * Preferred row index in case an annotation was removed and we will attempt to reinsert it
		 * right away. -1 means no preference.
		 */
		int						backupRowIndex;

		/// Previous focus state (used for state change detection)
		EGEOMETRY_FOCUS_STATE	previousFocusState;

		/// Current focus state
		EGEOMETRY_FOCUS_STATE	focusState;

		/// Geometry connected to the annotation
		IGeometry*				geometry;

		/// Application-specific user data pointer (passed to callback interface)
		void*					userData;

		/// Whether userData is actually of type jobject and holds a global reference to a Java object
		bool					userDataIsJavaObject;

		/// Connecting line color (range 0-255)
		int						connectingLineColorRGBA[4];

		/**
		 * Defines whether the item currently has a space in any row. Used only while selection
		 * algorithm is performed
		 */
		bool					currentlyExistsInARow;

		/// Used only while selection algorithm is performed
		bool					currentlyInFocusArea;

		/// Current distance of geometry in meters
		float					geoDistance;

		/// LLA position of the geometry, only altitude used in annotation placement algorithm
		Vector3d				geoPointInLocationCOS;

		/**
		 * LLA position fully transformed into screen space (i.e. model-view-projection applied).
		 * Used to find at which Z coordinate the geometry is rendered, so that the line is drawn
		 * at the same depth.
		 */
		Vector3d				geoPointProjectedToNDCSpace;

		/// Viewport pixel coordinate of the origin of geometry
		Vector2d				geoPosInViewport;

		/**
		 * Minimum allowed value for annotationPos.x, used as constraint in placement algorithm.
		 * Non-negative, int type is to avoid signed/unsigned issues. Only applicable if item is
		 * placed in a row, then it can be expected to be valid even after call to update().
		 */
		int						minPosX;

		/**
		 * Maximum allowed value for annotationPos.x, used as constraint in placement algorithm
		 * \sa minPosX
		 */
		int						maxPosX;

		/**
		 * Timestamp in seconds, determines how long the geometry was continuously inside the
		 * area in which geometries are considered for being annotated (i.e. inside part of the
		 * viewport's width, see updateSelectionStates for details)
		 */
		float					timeEnteredFocusArea;

		/**
		 * Maximum time until the item is forcefully removed in order to try and make space for
		 * other annotations which may correspond to closer POIs/geometries.
		 *
		 * It's defined as "maximum time" because the further the geometry is away from the screen
		 * center (horizontally), the faster this value decrements, so that central geometries will
		 * be preferred.
		 */
		float					timeToRemoval;

		/**
		 * Whether state change should be triggered at beginning of next update() call. This is done
		 * in update() because onFocusStateChanged should always be called from renderer thread.
		 */
		bool					triggerFocusStateChangedCallback;

		/// For assertions
		bool					validPosAndMaxMoveValues;

		/// Triggers annotation update when update() is called next time
		bool					wantsAnnotationUpdate;
	};

	typedef std::vector<GeometryWithAnnotation*> Row;

	void adjustMinMaxToLeftAndRightItem(GeometryWithAnnotation& item, GeometryWithAnnotation* itemToLeft, GeometryWithAnnotation* itemToRight, bool afterwardsAssertValidPosition);

	/**
	 * Checks if two items intersect, considering their current position, dimension and the required
	 * padding between two adjecent items
	 *
	 * \param a First item
	 * \param b Second item
	 * \return True on intersection, else false
	 */
	bool AS_MUST_CHECK_RETVAL boxesIntersectHorizontally(GeometryWithAnnotation& a, GeometryWithAnnotation& b);

	/**
	 * Calculates maximum number of geometries to annotate at once (counting them all together,
	 * independent of number of rows etc.)
	 *
	 * \param viewportWidth Viewport width
	 * \param displayDensity Display density in PPI
	 * \return Maximum number of geometries to annotate at once
	 */
	unsigned int AS_MUST_CHECK_RETVAL calcMaxItems(int viewportWidth, float displayDensity);

	/**
	 * Calculates maximum number of rows to fill with annotations
	 *
	 * \param viewportHeight Viewport height
	 * \param displayDensity Display density in PPI
	 * \return Maximum number of rows to fill with annotations
	 */
	unsigned int AS_MUST_CHECK_RETVAL calcMaxRows(int viewportHeight, float displayDensity);

	/**
	 * Recalculates minPosX/maxPosX and clamps annotationPos.x to valid range
	 *
	 * \return True if item can be placed on viewport, false if it's too far outside (in latter case,
	 *         none of the position and maxMoveToLeft/Right values are valid after the call)
	 */
	bool AS_MUST_CHECK_RETVAL calcPosAndMaxMove(GeometryWithAnnotation& item, int horizontalMarginFromViewportEdge);

	/**
	 * Calculates Y position of annotation for the specified row
	 *
	 * \param rowIndex Row index, counting from 0 (bottom row), 1 (second from bottom), ...
	 * \param displayDensity Display density in PPI
	 * \return Y position
	 */
	int AS_MUST_CHECK_RETVAL calcVerticalPosForRow(unsigned int rowIndex, int maxAnnotHeight, float displayDensity);

	void createOrUpdateAnnotation(GeometryWithAnnotation& item);

	void getGeometryPositionInViewport(const metaio::SensorValues& sensorValues, GeometryWithAnnotation& item);

	static Vector2di AS_MUST_CHECK_RETVAL getPixelDimensions(IGeometry* annotation);

	/// Calculates number of pixels (non-negative result) that item may move to the left
	static int AS_MUST_CHECK_RETVAL maxMoveToLeft(const GeometryWithAnnotation& item);

	/// Calculates number of pixels (non-negative result) that item may move to the right
	static int AS_MUST_CHECK_RETVAL maxMoveToRight(const GeometryWithAnnotation& item);

	/**
	 * Positions the annotation's center at the given pixel position in the viewport
	 *
	 * \param x X position in pixels
	 * \param y Y position in pixels
	 * \param projectionMatrix Projection matrix which will be used for rendering
	 * \param nearCP Near clipping plane of the projection matrix
	 */
	void positionAnnotationCenter(IGeometry* annotation, int x, int y, const irr::core::matrix4& projectionMatrix, float nearCP);

	/**
	 * Must be called after those annotations have been loaded which could potentially be displayed
	 * (focused/selected state)
	 */
	void positionAnnotations(const metaio::SensorValues& sensorValues);

	void removeItemFromRow(GeometryWithAnnotation& item);

	void sanityCheckRowOverlaps(const Row& row);

	/**
	 * Tries to sort annotations so that nearest geometries are annotated on top row, furthest
	 * geometries are annotated on bottom rows
	 */
	void sortVertically();

	/**
	 * \return Whether a place was found in the given row and the annotation was inserted
	 */
	bool AS_MUST_CHECK_RETVAL tryInsertIntoRow(GeometryWithAnnotation& item,
		std::vector<Row>::size_type rowIndex, Row::size_type atIndex, bool mustResolveOverlap,
		int overlapAmountLeft, int overlapAmountRight);

	/**
	 * \return Whether a place was found in the given row and the annotation was inserted
	 */
	bool AS_MUST_CHECK_RETVAL tryPlaceAnnotationIntoRow(GeometryWithAnnotation& item,
		std::vector<Row>::size_type rowIndex);

	/**
	 * Helper method for sortVertically: tries to swap the two items in the different rows
	 *
	 * If items can be swapped (there must be enough space), they are also inserted into the
	 * respective row vector.
	 *
	 * \return True if items were swapped
	 */
	bool trySwapItems(GeometryWithAnnotation& itemA, GeometryWithAnnotation& itemB, Row& rowA, Row& rowB);

	/// Bottom padding
	unsigned int									m_bottomPadding;

	/// Default connecting line color (range 0-255)
	int												m_defaultConnectingLineColorRGBA[4];

	/// Display density in PPI (stored to avoid repeated function calls)
	float											m_displayDensity;

	/// Enforced margin from left/right viewport edges
	int												m_horizontalMarginFromViewportEdge;

	/// Items in this group - all of them will be considered for annotation placement
	std::vector<GeometryWithAnnotation*>			m_items;

	/// Time in seconds when update() was called last time
	float											m_lastUpdateTime;

	/// Cache maximum annotation height (available after update())
	unsigned int									m_maxAnnotHeight;

	/// Maximum number of geometries to annotate at once (-1 to calculate this with default formula)
	int												m_maxItemsToAnnotate;

	/// Maximum number of rows (-1 to calculate this with default formula)
	int												m_maxRows;

	/// Required padding in pixels between adjacent annotations (on viewport's X axis)
	int												m_paddingBetweenAdjacentAnnotations;

	/// Callback instance
	IAnnotatedGeometriesGroupCallback*				m_pCallback;

	/**
	 * Currently selected geometry (if any). This variable is only for fast lookup - we could also
	 * just use the first item with focusState==EGFS_SELECTED.
	 */
	IGeometry*										m_pCurrentlySelectedGeometry;

	/// SDK instance
	IMetaioSDK*										m_pMetaioSDK;

	/// SDK instance for internal methods
	IMetaioSDKPrivate*								m_pMetaioSDKPrivate;

	/// Timer that always runs, used in several places
	common::IMonotonicTimer*						m_pTimer;

	/// Viewport size in previous frame
	Vector2di										m_previousViewportSize;

	/**
	 * Whether all rows should be recreated (e.g. if maximum number of rows/annotations changed
	 * at runtime)
	 */
	bool											m_removeAllRowsInNextUpdate;

	/// Rows (row 0 is at the bottom, each row sorted left-to-right!)
	std::vector<Row>								m_rows;

	/// Cached real viewport size used for screen-space calculations
	Vector2di										m_viewportSize;
};

} // end of namespace metaio

#endif

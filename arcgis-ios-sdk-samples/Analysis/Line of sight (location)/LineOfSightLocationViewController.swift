// Copyright 2017 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import ArcGIS

class LineOfSightLocationViewController: UIViewController, AGSGeoViewTouchDelegate {
    
    @IBOutlet weak var sceneView: AGSSceneView!
    @IBOutlet weak var observerInstructionLabel: UILabel!
    @IBOutlet weak var targetInstructionLabel: UILabel!
    
    private var lineOfSight: AGSLocationLineOfSight!
    
    private var observerSet:Bool = false {
        didSet {
            observerInstructionLabel.isHidden = observerSet
            targetInstructionLabel.isHidden = !observerSet
        }
    }
    
    private let ELEVATION_SERVICE_URL = URL(string: "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add the source code button item to the right of navigation bar
        (navigationItem.rightBarButtonItem as! SourceCodeBarButtonItem).filenames = ["LineOfSightLocationViewController"]
        
        // initialize the scene with an imagery basemap
        let scene = AGSScene(basemap: AGSBasemap.imagery())
        
        // initialize the elevation source with the service URL and add it to the base surface of the scene
        let elevationSrc = AGSArcGISTiledElevationSource(url: ELEVATION_SERVICE_URL)
        scene.baseSurface?.elevationSources.append(elevationSrc)
        
        // assign the scene to the scene view
        sceneView.scene = scene
        
        // set the viewpoint specified by the camera position
        let camera = AGSCamera(location: AGSPoint(x: -73.0815, y: -49.3272, z: 4059, spatialReference: AGSSpatialReference.wgs84()), heading: 11, pitch: 62, roll: 0)
        sceneView.setViewpointCamera(camera)
        
        // set touch delegate on scene view as self
        sceneView.touchDelegate = self

        // initialize the line of sight with arbitrary points (observer and target will be defined by the user)
        lineOfSight = AGSLocationLineOfSight(observerLocation: AGSPoint(x: 0.0 , y: 0.0, z: 0.0, spatialReference: AGSSpatialReference.wgs84()), targetLocation: AGSPoint(x: 0.0 , y: 0.0, z: 0.0, spatialReference: AGSSpatialReference.wgs84()))
        
        // set the line width (default 1.0). This setting is applied to all line of sight analysis in the view
        AGSLineOfSight.setLineWidth(2.0)
        
        // create an analysis overlay for the line of sight and add it to the scene view
        let analysisOverlay = AGSAnalysisOverlay()
        analysisOverlay.analyses.add(lineOfSight)
        sceneView.analysisOverlays.add(analysisOverlay)
    }
    
    // MARK: - AGSGeoViewTouchDelegate
    
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        guard !observerSet else {
            return
        }
        
        // define the observer location
        lineOfSight.observerLocation = mapPoint

        observerSet = true
    }
    
    func geoView(_ geoView: AGSGeoView, didLongPressAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        // check if user has set the observer location
        guard observerSet else {
            return
        }
        
        // update the target location
        lineOfSight.targetLocation = mapPoint
    }
    
    func geoView(_ geoView: AGSGeoView, didMoveLongPressToScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        // check if user has set the observer location
        guard observerSet else {
            return
        }
        
        // update the target location
        lineOfSight.targetLocation = mapPoint
    }
    
}

// Copyright 2019 Esri.
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

class ProjectViewController: UIViewController, AGSGeoViewTouchDelegate {
    @IBOutlet private weak var mapView: AGSMapView!
    @IBOutlet private weak var stackView: ProjectStackView!
    private var graphicsOverlay: AGSGraphicsOverlay!
    private var map: AGSMap!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize the map
        mapView.map = AGSMap(basemap: .nationalGeographic())
        mapView.touchDelegate = self
        mapView.setViewpointCenter(AGSPoint(x: -1.2e7, y: 5e6, spatialReference: .webMercator()), scale: 4e7)
        
        //initialize the graphic overlay
        let graphicsOverlay = AGSGraphicsOverlay()
        mapView.graphicsOverlays.add(graphicsOverlay)
        self.graphicsOverlay = graphicsOverlay
        
        //add the source code button item to the right of navigation bar
        (self.navigationItem.rightBarButtonItem as! SourceCodeBarButtonItem).filenames = ["ProjectViewController", "ProjectStackView"]
    }
    
    //make graphics
    private func makeGraphics(coord: AGSPoint) {
        let pointSymbol = AGSSimpleMarkerSymbol(style: .circle, color: .red, size: 5.0)
        pointSymbol.outline = AGSSimpleLineSymbol(style: .solid, color: .red, width: 2.0)
        let pointGraphic = AGSGraphic(geometry: coord, symbol: pointSymbol, attributes: nil)
        graphicsOverlay.graphics.add(pointGraphic)
    }
    
    // MARK: - AGSGeoViewTouchDelegate
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        if mapView.callout.isHidden {
            let customCallout = stackView!
            let projectedPoint = AGSGeometryEngine.projectGeometry(mapPoint, to: .wgs84()) as! AGSPoint
            customCallout.titleLabel.text = "Coordinates"
            customCallout.originalLabel.text = String(format: "Original: %.5f, %.5f", mapPoint.x, mapPoint.y)
            customCallout.projectedLabel.text = String(format: "Projected: %.5f, %.5f", projectedPoint.x, projectedPoint.y)
            mapView.callout.customView = customCallout
            mapView.callout.show(at: mapPoint, screenOffset: .zero, rotateOffsetWithMap: false, animated: true)
            makeGraphics(coord: mapPoint)
        } else {  //hide the callout
            graphicsOverlay.graphics.removeAllObjects()
            mapView.callout.dismiss()
        }
    }
}

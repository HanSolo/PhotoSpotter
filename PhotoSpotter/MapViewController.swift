//
//  ViewController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 27.03.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreGraphics
import Network
import CoreData
import CloudKit


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MapPinEventObserver, FoVController {
    var stateController : StateController?
    
    // Toolbar items
    @IBOutlet weak var mapButton           : UIBarButtonItem!
    @IBOutlet weak var camerasButton       : UIBarButtonItem!
    @IBOutlet weak var lensesButton        : UIBarButtonItem!
    @IBOutlet weak var viewsButton         : UIBarButtonItem!
    
    // View items
    @IBOutlet weak var mapView             : MKMapView!
    @IBOutlet weak var focalLengthSlider   : UISlider!
    @IBOutlet weak var focalLengthLabel    : UILabel!
    @IBOutlet weak var minFocalLengthLabel : UILabel!
    @IBOutlet weak var maxFocalLengthLabel : UILabel!
    @IBOutlet weak var apertureSlider      : UISlider!
    @IBOutlet weak var apertureLabel       : UILabel!
    @IBOutlet weak var minApertureLabel    : UILabel!
    @IBOutlet weak var maxApertureLabel    : UILabel!
    @IBOutlet weak var dofButton           : UIButton!
    @IBOutlet weak var placeButton         : UIButton!
    @IBOutlet weak var orientationButton   : UIButton!
    @IBOutlet weak var orientationLabel    : UILabel!
    @IBOutlet weak var mapTypeSelector     : UISegmentedControl!
    @IBOutlet weak var distanceLabel       : UILabel!
    @IBOutlet weak var widthLabel          : UILabel!
    @IBOutlet weak var heightLabel         : UILabel!
    @IBOutlet weak var moonButton          : UIButton!
    @IBOutlet weak var sunButton           : UIButton!
    @IBOutlet weak var showViewsButton     : UIButton!
    @IBOutlet weak var routingButton       : UIButton!
    @IBOutlet weak var cameraLabel         : UILabel!
    @IBOutlet weak var lensLabel           : UILabel!
    @IBOutlet weak var viewLabel           : UILabel!
    @IBOutlet weak var viewButton          : UIButton!
    @IBOutlet weak var elevationButton     : UIButton!
    @IBOutlet weak var infoButton          : UIButton!
    @IBOutlet weak var locateMeButton      : UIButton!
    
    @IBOutlet weak var distanceToViewLabel : UILabel!
    @IBOutlet weak var timeToViewLabel     : UILabel!
    @IBOutlet weak var routeInfoView       : UIStackView!
    
    @IBOutlet weak var elevationChartHeight: NSLayoutConstraint!
    @IBOutlet weak var infoViewHeight      : NSLayoutConstraint!
    
    @IBOutlet weak var navBar              : UINavigationBar!
    
    
    let monitor               : NWPathMonitor       = NWPathMonitor()
    var connected             : Bool                = false
    var locationManager       : CLLocationManager!
    var fovData               : FoVData?
    var cameraPin             : MapPin?
    var motifPin              : MapPin?
    var mapPins               : [MapPin]            = [MapPin]()
    var triangle              : Triangle?
    var minTriangle           : Triangle?
    var maxTriangle           : Triangle?
    var trapezoid             : Trapezoid?
    var fovTriangle           : MKPolygon?
    var minFovTriangle        : MKPolygon?
    var maxFovTriangle        : MKPolygon?
    var fovTriangleFrame      : MKPolygon?
    var fovCenterLine         : MKPolyline?
    var dofTrapezoid          : MKPolygon?
    var moonriseLine          : MKPolyline?
    var moonsetLine           : MKPolyline?
    var sunriseLine           : MKPolyline?
    var sunsetLine            : MKPolyline?
    var routePolylines        : [MKPolyline]        = []
    var data                  : FoVData?
    var fovVisible            : Bool                = true
    var dofVisible            : Bool                = false
    var moonVisible           : Bool                = false
    var sunVisible            : Bool                = false
    var viewsVisible          : Bool                = false
    var routeVisible          : Bool                = false
    var elevationChartVisible : Bool                = false
    var infoVisible           : Bool                = false
    var focalLength           : Double              = 50
    var aperture              : Double              = 2.8
    var orientation           : Orientation         = Orientation.landscape
    let sunMoonCalc           : SunMoon             = SunMoon()    
    var eventAngles           : Dictionary<String, (Double, Double)>?
    var pointsSunrise         : [MKMapPoint]        = []
    var pointsSunset          : [MKMapPoint]        = []
    var pointsMoonrise        : [MKMapPoint]        = []
    var pointsMoonset         : [MKMapPoint]        = []
    var viewAnnotations       : [MKPointAnnotation] = []
    var visibleArea           : MKMapRect?
    var heading               : CLLocationDirection?
    var elevationPoints       : [ElevationPoint]    = [] { didSet { drawElevationChart() } }
    var userLocation          : CLLocation?
    var distanceToView        : CLLocationDistance  = 0
    var timeToView            : TimeInterval        = TimeInterval()
    var selectedViewMapRect   : MKMapRect           = Constants.DEFAULT_VIEW.mapRect
    
    var cameraBodyButton      : UIButton?

    
    @IBOutlet weak var elevationChartView: ElevationChartView!
    @IBOutlet weak var infoView          : InfoView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.setNavBarTitle(navBar: navBar)
        
        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController
        
        monitor.pathUpdateHandler = { pathUpdateHandler in
            self.connected = pathUpdateHandler.status == .satisfied
            DispatchQueue.main.async { 
               self.elevationButton.isEnabled = self.connected
            }
        }
        let queue = DispatchQueue(label: "InternetConnectionMonitor")
        monitor.start(queue: queue)
        
        self.locateMeButton.layer.cornerRadius = 5
        
        self.mapView.mapType                = MKMapType.standard
        self.mapView.isZoomEnabled          = true
        self.mapView.isScrollEnabled        = true
        self.mapView.showsScale             = true
        self.mapView.showsCompass           = true
        self.mapView.showsUserLocation      = true
        
        self.triangle                       = Triangle()
        self.minTriangle                    = Triangle()
        self.maxTriangle                    = Triangle()
        self.trapezoid                      = Trapezoid()
        
        self.mapView.delegate               = self
                        
        let mapTypeSelectorTextAttr         = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let mapTypeSelectorTextAttrSelected = [NSAttributedString.Key.foregroundColor: UIColor.white]
        mapTypeSelector.setTitleTextAttributes(mapTypeSelectorTextAttr, for: .normal)
        mapTypeSelector.setTitleTextAttributes(mapTypeSelectorTextAttrSelected, for: .selected)
                
        mapView.showsCompass = false
        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        compassButton.compassVisibility = .adaptive
        mapView.addSubview(compassButton)
        let compassButtonConstraints  : [NSLayoutConstraint] = [
            compassButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 80),
            compassButton.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20)
        ]
        NSLayoutConstraint.activate(compassButtonConstraints)
        
        mapView.showsScale = false
        let scaleView = MKScaleView(mapView: mapView)
        scaleView.translatesAutoresizingMaskIntoConstraints = false
        scaleView.scaleVisibility = .adaptive
        mapView.addSubview(scaleView)
        let scaleViewConstraints : [NSLayoutConstraint] = [
            scaleView.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20),
            scaleView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20)
        ]
        NSLayoutConstraint.activate(scaleViewConstraints)
        
        routeInfoView.addBackground(color: Constants.TRANSLUCENT_GRAY)
        distanceToViewLabel.textColor = Constants.YELLOW
        timeToViewLabel.textColor     = Constants.YELLOW
        routeInfoView.isHidden = true
        
        setView(view: stateController!.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access iCloud container
        //let containerIdentifier = "iCloud.eu.hansolo.PhotoSpotter"
        //let container           = CKContainer(identifier: containerIdentifier)
        
        // Update data from iCloud
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            stateController!.loadCamerasFromCD(appDelegate: appDelegate)
            stateController!.loadLensesFromCD(appDelegate: appDelegate)
            stateController!.loadViewsFromCD(appDelegate: appDelegate)
        }
                
        createMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    // MARK: Navigation Event Handlers
    @IBAction func mapButtonPressed(_ sender: Any) {
    }
    @IBAction func camerasButtonPressed(_ sender: Any) {
        stateController!.setView(createView(name: "current", description: ""))
        stateController!.storeLocationToUserDefaults()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cameraVC = storyboard.instantiateViewController(identifier: "CameraViewController")
        show(cameraVC, sender: self)        
    }
    @IBAction func lensesButtonPressed(_ sender: Any) {
        stateController!.setView(createView(name: "current", description: ""))
        stateController!.storeLocationToUserDefaults()
        performSegue(withIdentifier: "mapViewToLensesView", sender: self)
    }
    @IBAction func viewsButtonPressed(_ sender: Any) {
        stateController!.storeLocationToUserDefaults()
        performSegue(withIdentifier: "mapViewToViewsView", sender: self)
    }
    
    // MARK: Event Handlers
    @IBAction func viewButtonPressed(_ sender: Any) {
        self.mapView.setVisibleMapRect(selectedViewMapRect, animated: true)
    }
    @IBAction func focalLengthChanged(_ sender: Any) {
        self.focalLengthLabel.text             = String(format: "%.0f mm", Double(round(focalLengthSlider!.value)))
        self.stateController!.view.focalLength = Double(round(focalLengthSlider!.value))
        
        updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation)
        updateDoFTrapezoid(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation)
        updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
        updateDragOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
    }
    
    @IBAction func apertureChanged(_ sender: Any) {
        self.apertureLabel.text = String(format: "f %.1f", Double(round(apertureSlider!.value * 10) / 10))
        stateController!.view.aperture = Double(round(apertureSlider!.value * 10) / 10)
        
        if dofVisible {
            updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation)
            updateDoFTrapezoid(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation)
            updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
        }
    }
    
    @IBAction func orientationChanged(_ sender: Any) {
        stateController!.view.orientation = Orientation.landscape == stateController!.view.orientation ? Orientation.portrait : Orientation.landscape
        switch stateController!.view.orientation {
            case .landscape:
                self.orientationButton.transform = CGAffineTransform.identity
                //self.orientationLabel.text!      = "Landscape"
                break
            case .portrait:
                self.orientationButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
                //self.orientationLabel.text!      = "Portrait"
                break
        }
        
        updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation)
        updateDoFTrapezoid(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation)
        updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
        updateDragOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
    }
    
    @IBAction func dofChanged(_ sender: Any) {
        if self.dofVisible {
            self.dofVisible = false
            dofButton.setImage(UIImage(systemName: "arrowtriangle.down"), for: UIControl.State.normal)
        } else {
            self.dofVisible = true
            dofButton.setImage(UIImage(systemName: "arrowtriangle.down.fill"), for: UIControl.State.normal)
        }
        updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
    }
        
    @IBAction func placeButtonPressed(_ sender: Any) {
        let dX = motifPin!.point().x - cameraPin!.point().x
        let dY = motifPin!.point().y - cameraPin!.point().y
        
        let cameraPoint :MKMapPoint = MKMapPoint(mapView.centerCoordinate)
        let motifPoint  :MKMapPoint = MKMapPoint(x: cameraPoint.x + dX, y: cameraPoint.y + dY)
        let mapRect     :MKMapRect  = self.mapView.visibleMapRect
        
        let newView :View = View(name: "current", description: stateController!.view.description, cameraPoint: cameraPoint, motifPoint: motifPoint,
                                 camera: stateController!.view.camera, lens: stateController!.view.lens, focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture,
                                 orientation: stateController!.view.orientation, country: stateController!.view.country, mapRect: mapRect)
        setView(view: newView)
    }
    
    @IBAction func mapTypeChanged(_ sender: Any) {
        switch mapTypeSelector.selectedSegmentIndex {
            case 0 : mapView.mapType = MKMapType.standard
            case 1 : mapView.mapType = MKMapType.satellite
            case 2 : mapView.mapType = MKMapType.hybrid
            default: mapView.mapType = MKMapType.standard
        }
        self.stateController!.updateMapType(mapTypeSelector.selectedSegmentIndex)
    }
    
    @IBAction func moonButtonPressed(_ sender: Any) {
        if self.moonVisible {
            self.moonVisible = false
            moonButton.setImage(UIImage(systemName: "moon"), for: UIControl.State.normal)
        } else {
            self.moonVisible = true
            moonButton.setImage(UIImage(systemName: "moon.fill"), for: UIControl.State.normal)
        }
        self.eventAngles = sunMoonCalc.getEventAngles(date: Date(), lat: (self.cameraPin?.coordinate.latitude)!, lon: (self.cameraPin?.coordinate.longitude)!)
        updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
    }
    
    @IBAction func sunButtonPressed(_ sender: Any) {
        if self.sunVisible {
            self.sunVisible = false
            sunButton.setImage(UIImage(systemName: "sun.max"), for: UIControl.State.normal)
        } else {
            self.sunVisible = true
            sunButton.setImage(UIImage(systemName: "sun.max.fill"), for: UIControl.State.normal)
        }
        self.eventAngles = sunMoonCalc.getEventAngles(date: Date(), lat: (self.cameraPin?.coordinate.latitude)!, lon: (self.cameraPin?.coordinate.longitude)!)
        updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
    }
    
    @IBAction func showViewsButtonPressed(_ sender: Any) {
        if self.viewsVisible {
            self.viewsVisible = false
            showViewsButton.setImage(UIImage(systemName: "mappin.circle"), for: UIControl.State.normal)
        } else {
            self.viewsVisible = true
            showViewsButton.setImage(UIImage(systemName: "mappin.circle.fill"), for: UIControl.State.normal)
        }
        updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
    }
    
    @IBAction func routingButtonPressed(_ sender: Any) {
        if self.routeVisible {
            self.routeVisible   = false
            self.distanceToView = 0
            self.timeToView     = TimeInterval()
            self.mapView.removeOverlays(self.routePolylines)
            self.routingButton.setImage(UIImage(systemName: "car"), for: UIControl.State.normal)
        } else {
            self.routeVisible = true
            self.routingButton.setImage(UIImage(systemName: "car.fill"), for: UIControl.State.normal)
        }
        showRoute(show: self.routeVisible)
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        if self.infoVisible {
            self.infoVisible = false
            self.infoButton.setImage(UIImage(systemName: "info.circle"), for: UIControl.State.normal)
        } else {
            self.infoVisible = true
            self.infoButton.setImage(UIImage(systemName: "info.circle.fill"), for: UIControl.State.normal)
        }
        showInfoView(show: self.infoVisible)
    }
    
    @IBAction func locateMeButtonPressed(_ sender: Any) {
        gotoCurrentLocation()
    }
    
    @IBAction func elevationButtonPressed(_ sender: Any) {
        if connected {
            if self.elevationChartVisible {
                self.elevationChartVisible = false
                self.elevationButton.setImage(UIImage(systemName: "arrow.up.and.down.circle"), for: UIControl.State.normal)
                showElevationChart(show: false)
            } else {
                self.elevationChartVisible = true
                self.elevationButton.setImage(UIImage(systemName: "arrow.up.and.down.circle.fill"), for: UIControl.State.normal)
                getElevation(camera: cameraPin!, motif: motifPin!)
            }
        }
    }
    
    
    func createMapView() {
        switch stateController!.mapType {
            case 0 : mapView.mapType = MKMapType.standard
            case 1 : mapView.mapType = MKMapType.satellite
            case 2 : mapView.mapType = MKMapType.hybrid
            default: mapView.mapType = MKMapType.standard
        }
        mapTypeSelector.selectedSegmentIndex = stateController!.mapType
                                
        mapView.visibleMapRect = visibleArea!
        mapView.centerCoordinate = stateController!.lastLocation.coordinate
        
        mapView.register(MapPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        #if targetEnvironment(macCatalyst)
            // Add zoom controls to mapview
            mapView.showsZoomControls = true
        #else
            
        #endif
        
        updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation)
        updateDoFTrapezoid(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation)
        updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
        updateDragOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
    }
    
    func gotoCurrentLocation() {
        locationManager                 = CLLocationManager()
        locationManager.delegate        = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
    }
    
        
    // MARK: CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
    }
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error \(error)")
    }
    
    
    // MARK: MKMapViewDelegate methods
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, didChange: MKAnnotationView.DragState, fromOldState: MKAnnotationView.DragState) {
        switch (didChange) {
            case .starting:
                if annotationView is MapPinAnnotationView {
                    annotationView.center.y -= 56
                    var center = MKMapPoint(mapView.centerCoordinate)
                    center.y += (mapView.visibleMapRect.height * 0.04941444)
                    mapView.setCenter(center.coordinate, animated: true)                    
                }
                break;
            case .dragging:
                break;
            case .ending, .canceling:
                if annotationView is MapPinAnnotationView {
                    annotationView.center.y += 56
                    var center = MKMapPoint(mapView.centerCoordinate)
                    center.y -= (mapView.visibleMapRect.height * 0.04941444)
                    mapView.setCenter(center.coordinate, animated: true)
                }
                self.eventAngles = sunMoonCalc.getEventAngles(date: Date(), lat: (self.cameraPin?.coordinate.latitude)!, lon: (self.cameraPin?.coordinate.longitude)!)
                updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation)
                updateDoFTrapezoid(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation)
                updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
                break;
            default: break
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MapPin {
            let mapPin : MapPin = annotation as! MapPin
            if mapPin.title == "Camera" || mapPin.title == "Motif" {
                let mapPinAnnotationView : MapPinAnnotationView = MapPinAnnotationView(annotation: annotation, reuseIdentifier: mapPin.title)
                mapPinAnnotationView.mapView = mapView
                mapPinAnnotationView.setOnMapPinEvent(observer: self)
                return mapPinAnnotationView
            }
        } else if annotation is ViewPinAnnotation {
            let viewPinAnnotation : ViewPinAnnotation = annotation as! ViewPinAnnotation
            let identifier = "Annotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout           = true
                annotationView!.isUserInteractionEnabled = true
                
                // Add items e.g. equipment, times, tags
                let itemsLabel : UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
                itemsLabel.numberOfLines  = 0
                itemsLabel.attributedText = Helper.getItemsTextFor(view: viewPinAnnotation.view!)
                itemsLabel.font           = itemsLabel.font.withSize(10)
                let width = NSLayoutConstraint(item: itemsLabel, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.lessThanOrEqual, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200)
                itemsLabel.addConstraint(width)
                let height = NSLayoutConstraint(item: itemsLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.lessThanOrEqual, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 90)
                itemsLabel.addConstraint(height)
                annotationView!.detailCalloutAccessoryView = itemsLabel
                
                // Add button
                let viewButton : UIButton = UIButton(type: .infoLight)
                let icon       : UIImage  = UIImage(systemName: "viewfinder.circle")!
                viewButton.setImage(icon, for: .normal)
                viewButton.tintColor = UIColor.systemTeal
                annotationView!.rightCalloutAccessoryView = viewButton
            } else {
                annotationView!.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Draw Overlays
        if let overlay = overlay as? Polygon {
            let polygonRenderer = MKPolygonRenderer(overlay: overlay)
            polygonRenderer.lineWidth = 1.0
            if overlay.id == "dof" && dofVisible {
                polygonRenderer.fillColor       = Constants.DOF_FILL
                polygonRenderer.strokeColor     = Constants.DOF_STROKE
                polygonRenderer.lineDashPattern = [10, 10]
                polygonRenderer.lineDashPhase   = 10
            } else if overlay.id == "maxFov" && fovVisible {
                polygonRenderer.fillColor   = Constants.MAX_FOV_FILL
                polygonRenderer.strokeColor = Constants.MAX_FOV_STROKE
            } else if overlay.id == "minFov" && fovVisible {
                polygonRenderer.fillColor   = Constants.MIN_FOV_FILL
                polygonRenderer.strokeColor = Constants.MIN_FOV_STROKE
            } else if overlay.id == "fov" && fovVisible {
                polygonRenderer.fillColor   = Constants.FOV_FILL
                polygonRenderer.strokeColor = Constants.FOV_STROKE
            } else if overlay.id == "fovFrame" && fovVisible {
                polygonRenderer.fillColor   = Constants.FOV_FRAME_FILL
                polygonRenderer.strokeColor = Constants.FOV_FRAME_STROKE
            }
            return polygonRenderer
        } else if let overlay = overlay as? Line {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            if overlay.id == "centerLine" && fovVisible {
                polylineRenderer.strokeColor = Constants.CENTER_LINE_STROKE
                polylineRenderer.lineWidth   = 1.0
            } else if overlay.id == "moonrise" && moonVisible {
                polylineRenderer.strokeColor = Constants.MOON_RISE_STROKE
                polylineRenderer.lineWidth   = 1.5
            } else if overlay.id == "moonset" && moonVisible {
                polylineRenderer.strokeColor = Constants.MOON_SET_STROKE
                polylineRenderer.lineWidth   = 1.5
            } else if overlay.id == "sunrise" && sunVisible {
                polylineRenderer.strokeColor = Constants.SUN_RISE_STROKE
                polylineRenderer.lineWidth   = 1.5
            } else if overlay.id == "sunset" && sunVisible {
                polylineRenderer.strokeColor = Constants.SUN_SET_STROKE
                polylineRenderer.lineWidth   = 1.5
            }
            return polylineRenderer
        } else {
            if routeVisible {
                let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
                polylineRenderer.strokeColor = Constants.BLUE
                polylineRenderer.lineWidth   = 1.5
                return polylineRenderer
            }
        }
        return MKPolylineRenderer()
    }
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        self.visibleArea              = mapView.visibleMapRect
        self.heading                  = mapView.camera.heading
        stateController!.view.mapRect = mapView.visibleMapRect
        stateController!.setLastLocation(CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude))        
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {}
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let annotationView = view as? MKPinAnnotationView {
                if let view = stateController!.views.filter({ $0.name == annotationView.annotation?.title }).first {
                    setView(view: view)
                }
            }
        }
    }

    @objc private func handleTap(sender: UITapGestureRecognizer) {
        guard let annotation = (sender.view as? MKPinAnnotationView)?.annotation as? ViewPinAnnotation else { return }
        stateController!.setView(annotation.view!)
        setView(view: annotation.view!)
    }
    
    
    // MapPin event handling
    func onMapPinEvent(evt: MapPinEvent) {
        if evt.src === cameraPin {
            stateController!.view.cameraPoint = MKMapPoint(evt.coordinate)
            updateFoVTriangle(cameraPoint: evt.point, motifPoint: self.motifPin!.point(), focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation)
            updateDragOverlay(cameraPoint: evt.point, motifPoint: self.motifPin!.point())
        } else if evt.src === motifPin {
            stateController!.view.motifPoint = MKMapPoint(evt.coordinate)
            updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: evt.point, focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation)
            updateDragOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: evt.point)
        }
    }
    
    
    // Set a view
    func setView(view: View) -> Void {
        self.routeVisible   = false
        self.routingButton.setImage(UIImage(systemName: "car"), for: UIControl.State.normal)
        self.distanceToView = 0
        self.timeToView     = TimeInterval()
        self.mapView.removeOverlays(routePolylines)
        
        stateController!.setView(view)
        stateController!.setLastLocation(CLLocation(latitude: view.cameraPoint.coordinate.latitude, longitude: view.cameraPoint.coordinate.longitude))
        
        self.selectedViewMapRect = view.mapRect
        
        self.cameraPin = MapPin(pinType: PinType.camera, coordinate: view.cameraPoint.coordinate)
        self.motifPin  = MapPin(pinType: PinType.motif, coordinate : view.motifPoint.coordinate)
        
        let lens        : Lens        = view.lens
        let camera      : Camera      = view.camera
        let focalLength : Double      = view.focalLength
        let aperture    : Double      = view.aperture
        let orientation : Orientation = view.orientation
        
        self.mapView.removeAnnotations(self.mapPins)
        self.mapPins.removeAll()
        self.mapPins.append(self.cameraPin!)
        self.mapPins.append(self.motifPin!)
        self.mapView.addAnnotations(mapPins)
        
        self.focalLengthSlider.maximumValue = Float(lens.maxFocalLength)
        self.focalLengthSlider.minimumValue = Float(lens.minFocalLength)
        self.focalLengthSlider.value        = Float(focalLength)
        self.focalLengthLabel.text          = String(format: "%.0f mm", Double(round(focalLength)))
        self.minFocalLengthLabel.text       = String(format: "%.0f", Double(round(lens.minFocalLength)))
        self.maxFocalLengthLabel.text       = String(format: "%.0f", Double(round(lens.maxFocalLength)))
                
        self.apertureSlider.maximumValue    = Float(lens.maxAperture)
        self.apertureSlider.minimumValue    = Float(lens.minAperture)
        self.apertureSlider.value           = Float(aperture)
        self.apertureLabel.text             = String(format: "f %.1f", Double(round(aperture * 10) / 10))
        self.minApertureLabel.text          = String(format: "%.1f", Double(round(lens.minAperture * 10) / 10))
        self.maxApertureLabel.text          = String(format: "%.1f", Double(round(lens.maxAperture * 10) / 10))
        
        switch orientation {
            case .landscape:
                self.orientationButton.transform = CGAffineTransform.identity
                //self.orientationLabel.text!      = "Landscape"
                break
            case .portrait:
                self.orientationButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
                //self.orientationLabel.text!      = "Portrait"
                break
        }
        
        self.cameraLabel.text = camera.name
        self.lensLabel.text   = lens.name
        self.viewLabel.text   = view.name
        self.eventAngles      = sunMoonCalc.getEventAngles(date: Date(), lat: (self.cameraPin?.coordinate.latitude)!, lon: (self.cameraPin?.coordinate.longitude)!)
        self.visibleArea      = view.mapRect
        
        self.mapView.visibleMapRect = self.visibleArea!
        
        updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: focalLength, aperture: aperture, sensorFormat: camera.sensorFormat, orientation: orientation)
        updateDoFTrapezoid(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: focalLength, aperture: aperture, sensorFormat: camera.sensorFormat, orientation: orientation)
        updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
        updateDragOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
    }
    
    
    // Update methods
    func updateFoVTriangle(cameraPoint: MKMapPoint, motifPoint: MKMapPoint, focalLength: Double, aperture: Double, sensorFormat: SensorFormat, orientation: Orientation) -> Void {
        let distance : CLLocationDistance = cameraPoint.distance(to: motifPoint)
        if distance < 0.01 || distance > 9999 { return }
        
        do {
        self.fovData = try Helper.calc(camera: cameraPoint, motif: motifPoint, focalLengthInMM: focalLength, aperture: aperture, sensorFormat: sensorFormat, orientation: orientation)
            Helper.setInfoLabel(label: distanceLabel!, image: UIImage(systemName: "arrow.up.left.and.arrow.down.right")!, imageColor: Constants.YELLOW, size: CGSize(width: 12, height: 12), text: "Distance: ", value1: fovData?.distance ?? 0, decimals1: 1, unit1: Constants.UNIT_LENGTH)
            Helper.setInfoLabel(label: widthLabel!, image: UIImage(named: "width.png")!, imageColor: Constants.YELLOW, size: CGSize(width: 12, height: 12), text: "Width: ", value1: fovData?.fovWidth ?? 0, decimals1: 1, unit1: Constants.UNIT_LENGTH, value2: Helper.toDegrees(radians: fovData?.fovWidthAngle ?? 0), decimals2: 1, unit2: Constants.UNIT_ANGLE)
            Helper.setInfoLabel(label: heightLabel!, image: UIImage(named: "height.png")!, imageColor: Constants.YELLOW, size: CGSize(width: 12, height: 12), text: "Height: ", value1: fovData?.fovHeight ?? 0, decimals1: 1, unit1: Constants.UNIT_LENGTH, value2: Helper.toDegrees(radians: fovData?.fovHeightAngle ?? 0), decimals2: 1, unit2: Constants.UNIT_ANGLE)
        } catch {
            print(error)
        }
        
        // Update FoV Triangle
        Helper.updateTriangle(camera: cameraPoint, motif: motifPoint, focalLengthInMM: focalLength, aperture: aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation, triangle: self.triangle!)
        let angle: Double = Helper.toRadians(degrees: Helper.calculateBearing(location1: cameraPoint, location2: motifPoint))
        self.triangle!.p2 = Helper.rotatePointAroundCenter(point: self.triangle!.p2, rotationCenter: cameraPoint, rad: angle)
        self.triangle!.p3 = Helper.rotatePointAroundCenter(point: self.triangle!.p3, rotationCenter: cameraPoint, rad: angle)
        
        // Update min FoV Triangle
        Helper.updateTriangle(camera: cameraPoint, motif: motifPoint, focalLengthInMM: stateController!.view.lens.maxFocalLength, aperture: aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation, triangle: self.minTriangle!)
        let minAngle: Double = Helper.toRadians(degrees: Helper.calculateBearing(location1: cameraPoint, location2: motifPoint))
        self.minTriangle!.p2 = Helper.rotatePointAroundCenter(point: self.minTriangle!.p2, rotationCenter: cameraPoint, rad: minAngle)
        self.minTriangle!.p3 = Helper.rotatePointAroundCenter(point: self.minTriangle!.p3, rotationCenter: cameraPoint, rad: minAngle)
        
        // Update max FoV Triangle
        Helper.updateTriangle(camera: cameraPoint, motif: motifPoint, focalLengthInMM: stateController!.view.lens.minFocalLength, aperture: aperture, sensorFormat: stateController!.view.camera.sensorFormat, orientation: stateController!.view.orientation, triangle: self.maxTriangle!)
        let maxAngle: Double = Helper.toRadians(degrees: Helper.calculateBearing(location1: cameraPoint, location2: motifPoint))
        self.maxTriangle!.p2 = Helper.rotatePointAroundCenter(point: self.maxTriangle!.p2, rotationCenter: cameraPoint, rad: maxAngle)
        self.maxTriangle!.p3 = Helper.rotatePointAroundCenter(point: self.maxTriangle!.p3, rotationCenter: cameraPoint, rad: maxAngle)
    }
    
    func updateDoFTrapezoid(cameraPoint: MKMapPoint, motifPoint: MKMapPoint, focalLength: Double, aperture: Double, sensorFormat: SensorFormat, orientation: Orientation) -> Void {
        let distance : CLLocationDistance = cameraPoint.distance(to: motifPoint)
        if distance < 0.01 || distance > 9999 { return }
        
        // Update DoF Trapzoid
        Helper.updateTrapezoid(camera: cameraPoint, motif: motifPoint, focalLengthInMM: focalLength, aperture: aperture, sensorFormat: sensorFormat, orientation: orientation, trapezoid: self.trapezoid!)

        let angle: Double = Helper.toRadians(degrees: Helper.calculateBearing(location1: cameraPoint, location2: motifPoint))
        trapezoid!.p1 = Helper.rotatePointAroundCenter(point: trapezoid!.p1, rotationCenter: cameraPoint, rad: angle)
        trapezoid!.p2 = Helper.rotatePointAroundCenter(point: trapezoid!.p2, rotationCenter: cameraPoint, rad: angle)
        trapezoid!.p3 = Helper.rotatePointAroundCenter(point: trapezoid!.p3, rotationCenter: cameraPoint, rad: angle)
        trapezoid!.p4 = Helper.rotatePointAroundCenter(point: trapezoid!.p4, rotationCenter: cameraPoint, rad: angle)
    }
    
    func updateDragOverlay(cameraPoint: MKMapPoint, motifPoint: MKMapPoint) -> Void {
        if let fovTriangleFrame = self.fovTriangleFrame {
            mapView.removeOverlay(fovTriangleFrame)
        }
        self.fovTriangleFrame = nil
        
        if let fovCenterLine = self.fovCenterLine {
            mapView.removeOverlay(fovCenterLine)
        }
        self.fovCenterLine = nil
        
        // Create coordinates for fov triangle frame
        let fovTriangleCoordinates = triangle!.getPoints().map({ $0.coordinate })
        let fovTriangleFrame = Polygon(coordinates: fovTriangleCoordinates, count: fovTriangleCoordinates.count)
        fovTriangleFrame.id = "fovFrame"
        mapView.addOverlay(fovTriangleFrame)
        self.fovTriangleFrame = fovTriangleFrame
        
        // Create coordinates for fov center line
        let fovCenterLineCoordinates = [cameraPoint, motifPoint].map({ $0.coordinate })
        let fovCenterLine = Line(coordinates: fovCenterLineCoordinates, count: fovCenterLineCoordinates.count)
        fovCenterLine.id = "centerLine"
        mapView.addOverlay(fovCenterLine)
        self.fovCenterLine = fovCenterLine
    }
    
    func updateOverlay(cameraPoint: MKMapPoint, motifPoint: MKMapPoint) -> Void {
        // View Annotations
        if !viewAnnotations.isEmpty {
            mapView.removeAnnotations(viewAnnotations)
        }
        viewAnnotations.removeAll()
        
        if viewsVisible {
            for view in self.stateController!.views {
                if view.cameraPoint.coordinate.latitude != self.cameraPin!.coordinate.latitude &&
                   view.cameraPoint.coordinate.longitude != self.cameraPin!.coordinate.longitude {
                    let viewAnnotation : ViewPinAnnotation = ViewPinAnnotation(view: view)
                    viewAnnotation.title = view.name
                                                        
                    viewAnnotation.coordinate = view.cameraPoint.coordinate
                    viewAnnotations.append(viewAnnotation)
                }
            }
            mapView.addAnnotations(viewAnnotations)
        }
        
        // Overlays
        var overlaysToRemove : [MKOverlay] = []
                
        if let minFovTriangle = self.minFovTriangle { overlaysToRemove.append(minFovTriangle) }
        self.minFovTriangle = nil
        
        if let maxFovTriangle = self.maxFovTriangle { overlaysToRemove.append(maxFovTriangle) }
        self.maxFovTriangle = nil
        
        if let fovTriangle = self.fovTriangle { overlaysToRemove.append(fovTriangle) }
        self.fovTriangle = nil

        if let fovCenterLine = self.fovCenterLine { overlaysToRemove.append(fovCenterLine) }
        self.fovCenterLine = nil
        
        if let dofTrapezoid = self.dofTrapezoid { overlaysToRemove.append(dofTrapezoid) }
        self.dofTrapezoid = nil
        
        if let moonriseLine = self.moonriseLine { overlaysToRemove.append(moonriseLine) }
        self.moonriseLine = nil
        
        if let moonsetLine = self.moonsetLine { overlaysToRemove.append(moonsetLine) }
        self.moonsetLine = nil
        
        if let sunriseLine = self.sunriseLine { overlaysToRemove.append(sunriseLine) }
        self.sunriseLine = nil
        
        if let sunsetLine = self.sunsetLine { overlaysToRemove.append(sunsetLine) }
        self.sunsetLine = nil
        
        // Remove all overlays at once
        mapView.removeOverlays(overlaysToRemove)
        
        // Update sunrise/sunset and moonrise/moonset
        pointsMoonrise.removeAll()
        pointsMoonrise.append(cameraPoint)
        pointsMoonset.removeAll()
        pointsMoonset.append(cameraPoint)
    
        pointsSunrise.removeAll()
        pointsSunrise.append(cameraPoint)
        pointsSunset.removeAll()
        pointsSunset.append(cameraPoint)
        
        for (event, angles) in eventAngles! {
            let startAngle : Double     = Helper.toDegrees(radians: angles.0) + 90.0
            let point      : MKMapPoint = Helper.getPointByAngle(point: cameraPoint, angleDeg: startAngle)
            switch event {
                case Constants.EPD_SUNRISE : pointsSunrise.append(point)
                case Constants.EPD_SUNSET  : pointsSunset.append(point)
                case Constants.EPD_MOONRISE: pointsMoonrise.append(point)
                case Constants.EPD_MOONSET : pointsMoonset.append(point)
                default: break
            }
        }
        
        // Create coordinates for moonrise line
        let moonriseLine :Line = Line(points: pointsMoonrise, count: pointsMoonrise.count)
        moonriseLine.id = "moonrise"
        self.moonriseLine = moonriseLine
        
        // Create coordinates for moonset line
        let moonsetLine :Line = Line(points: pointsMoonset, count: pointsMoonset.count)
        moonsetLine.id = "moonset"
        self.moonsetLine  = moonsetLine
        
        // Create coordinates for sunrise line
        let sunriseLine :Line = Line(points: pointsSunrise, count: pointsSunrise.count)
        sunriseLine.id = "sunrise"
        self.sunriseLine = sunriseLine
        
        // Create coordinates for sunset line
        let sunsetLine :Line = Line(points: pointsSunset, count: pointsSunset.count)
        sunsetLine.id = "sunset"
        self.sunsetLine  = sunsetLine
        
        
        // Create coordinates for min fov triangle
        let minFovTriangleCoordinates = minTriangle!.getPoints().map({ $0.coordinate })
        let minFovTriangle = Polygon(coordinates: minFovTriangleCoordinates, count: minFovTriangleCoordinates.count)
        minFovTriangle.id = "minFov"
        self.minFovTriangle = minFovTriangle
        
        // Create coordinates for max fov triangle
        let maxFovTriangleCoordinates = maxTriangle!.getPoints().map({ $0.coordinate })
        let maxFovTriangle = Polygon(coordinates: maxFovTriangleCoordinates, count: maxFovTriangleCoordinates.count)
        maxFovTriangle.id = "maxFov"
        self.maxFovTriangle = maxFovTriangle
    
        // Create coordinates for fov triangle
        let fovTriangleCoordinates = triangle!.getPoints().map({ $0.coordinate })
        let fovTriangle = Polygon(coordinates: fovTriangleCoordinates, count: fovTriangleCoordinates.count)
        fovTriangle.id = "fov"
        self.fovTriangle = fovTriangle
        
        // Create coordinates for fov center line
        let fovCenterLineCoordinates = [cameraPoint, motifPoint].map({ $0.coordinate })
        let fovCenterLine = Line(coordinates: fovCenterLineCoordinates, count: fovCenterLineCoordinates.count)
        fovCenterLine.id = "centerLine"
        self.fovCenterLine = fovCenterLine
        
        // Create coordinates for dof trapezoid
        let dofTrapezoidCoordinates = trapezoid!.getPoints().map({ $0.coordinate })
        let dofTrapezoid = Polygon(coordinates: dofTrapezoidCoordinates, count: dofTrapezoidCoordinates.count)
        dofTrapezoid.id = "dof"
        self.dofTrapezoid = dofTrapezoid
        
        // Add all overlays at once
        mapView.addOverlays([moonriseLine, moonsetLine, sunriseLine, sunsetLine, minFovTriangle, maxFovTriangle, fovTriangle, fovCenterLine, dofTrapezoid])
    }
    
    func createView(name: String, description: String) -> View {
        return View(name: name, description: description, cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), camera: stateController!.view.camera, lens: stateController!.view.lens, focalLength: Double(focalLengthSlider.value), aperture: Double(apertureSlider.value), orientation: stateController!.view.orientation, country: stateController!.view.country, mapRect: mapView.visibleMapRect)
    }
    
    func getElevation(camera: MapPin, motif: MapPin) -> Void {
        RestManager.loadElevationPoints(cameraPin: camera, motifPin: motif) { elevationPoints in
            return self.elevationPoints = elevationPoints!
        }
    }
    
    func showElevationChart(show: Bool) -> Void {
        if (show) {
            self.elevationChartView.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
                self.elevationChartHeight.constant = 200
                self.view.layoutIfNeeded()
            }, completion: { finished in
            })
        } else {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
                self.elevationChartHeight.constant = 0
                self.view.layoutIfNeeded()
            }, completion: { finished in
                self.elevationChartView.isHidden = true
            })
        }
    }
    
    func drawElevationChart() -> Void {
        showElevationChart(show: true)
        elevationChartView.cameraPin       = cameraPin?.point()
        elevationChartView.distance        = cameraPin?.point().distance(to: (motifPin?.point())!) ?? 0
        elevationChartView.elevationPoints = self.elevationPoints
        elevationChartView.setNeedsDisplay()        
    }

    func showRoute(show: Bool) -> Void {
        if (show) {
            let request                     = MKDirections.Request()
            request.source                  = MKMapItem(placemark: MKPlacemark(coordinate: self.userLocation?.coordinate ?? Constants.DEFAULT_POSITION.coordinate, addressDictionary: nil))
            request.destination             = MKMapItem(placemark: MKPlacemark(coordinate: self.stateController?.view.cameraPoint.coordinate ?? Constants.DEFAULT_VIEW.cameraPoint.coordinate, addressDictionary: nil))
            //request.requestsAlternateRoutes = true
            request.transportType           = .automobile
            
            let directions = MKDirections(request: request)

            directions.calculate { [unowned self] response, error in
                guard let unwrappedResponse = response else { return }
                self.routePolylines.removeAll()
                for route in unwrappedResponse.routes {
                    self.distanceToView = route.distance
                    self.timeToView     = route.expectedTravelTime
                    self.mapView.addOverlay(route.polyline)
                    self.routePolylines.append(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
                                
                let time  = Int(self.timeToView)
                let h = time / 3600
                let m = time / 60 % 60
                //let s = time % 60
                
                let title : String =  "Route to"
                var text   : String =  "\(self.stateController?.view.name ?? Constants.DEFAULT_VIEW.name)\n"
                text += "Distance: \(String(format:"%.0f km", self.distanceToView / 1000.0))\n"
                //text += "Time: \(String(format:"%02i:%02i:%02i", h, m, s))"
                text += "Time: \(String(format:"%02i:%02i", h, m))"
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left
                let msg = NSAttributedString(
                    string: text,
                    attributes: [
                        .paragraphStyle : paragraphStyle,
                        .foregroundColor: UIColor.lightGray
                        //.font           : UIFont.systemFont(ofSize: 12)
                ])
                
                self.setRouteInfoText(distance: self.distanceToView, time: self.timeToView)
                self.routeInfoView.isHidden   = false
                
                let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
                alert.setValue(msg, forKey: "attributedMessage")
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            self.routeInfoView.isHidden = true
        }
    }
    
    private func setRouteInfoText(distance: Double, time: TimeInterval) -> Void {
        let textAttributes  = [NSAttributedString.Key.foregroundColor: Constants.BLUE]
        let valueAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightText]
        
        let distanceText : String = "\(String(format:"%.0f km", distance / 1000.0))"
        let distanceToViewString  = NSMutableAttributedString(string: "")
        distanceToViewString.append(NSAttributedString(string: "Distance: ", attributes: textAttributes))
        distanceToViewString.append(NSAttributedString(string: distanceText, attributes: valueAttributes))
        self.distanceToViewLabel.attributedText = distanceToViewString
        
        let time              = Int(time)
        let hour              = time / 3600
        let minute            = time / 60 % 60
        let timeText : String = "\(String(format:"%02i:%02i", hour, minute))"
        let timeToViewString  = NSMutableAttributedString(string: "")
        timeToViewString.append(NSAttributedString(string: "Time: ", attributes: textAttributes))
        timeToViewString.append(NSAttributedString(string: timeText, attributes: valueAttributes))
        self.timeToViewLabel.attributedText = timeToViewString
    }
    
    func showInfoView(show: Bool) -> Void {
        if (show) {
            self.infoView.fovData = self.fovData
            self.infoView.isHidden = false
            self.infoView.setNeedsDisplay()
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
                self.infoViewHeight.constant = 200
                self.view.layoutIfNeeded()
            }, completion: { finished in
            })
        } else {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
                self.infoViewHeight.constant = 0
                self.view.layoutIfNeeded()
            }, completion: { finished in
                self.infoView.isHidden = true
            })
        }
    }
}


public enum PinType {
    case camera
    case motif
}

public class MapPin: NSObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D
    
    public let pinType  : PinType
    public var imageName: String? {
        switch pinType {
            case PinType.camera: return "camerapin.png"
            case PinType.motif : return "motifpin.png"
        }
    }
    public var title    : String? {
        switch pinType {
            case PinType.camera: return "Camera"
            case PinType.motif : return "Motif"
        }
    }
    
    
    convenience init(pinType: PinType, latitude: Double, longitude: Double) {
        self.init(pinType: pinType, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
    init(pinType: PinType, coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.pinType    = pinType
        super.init()
    }
    
    
    public func point() -> MKMapPoint {
        return MKMapPoint(coordinate)
    }
}


class MapPinAnnotationView: MKAnnotationView {
    var observers : [MapPinEventObserver] = []
    var mapPin    : MapPin?
    var mapView   : MKMapView?
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.isDraggable    = true
        self.canShowCallout = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var annotation: MKAnnotation? {
      willSet {
        guard let mapPin = newValue as? MapPin else { return }
        self.mapPin = mapPin
        canShowCallout            = false // enable/disable popups of pins
        calloutOffset             = CGPoint(x: -5, y: 5)
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

        if let imageName = mapPin.imageName {
            image = UIImage(named: imageName)
            self.centerOffset = CGPoint(x: 0, y: -image!.size.height / 2)        
        } else {
            image = nil
        }
      }
    }
    
    public func getMapPin() -> MapPin {
        return mapPin!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        setSelected(true, animated: true) // Needed to be able to directly drag annotation, needs to be selected first
        super.touchesBegan(touches, with: event)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mapView != nil {
            let anchorPoint: CGPoint                = CGPoint(x: self.center.x, y: self.center.y - self.centerOffset.y)
            let coordinate : CLLocationCoordinate2D = mapView!.convert(anchorPoint, toCoordinateFrom: mapView)
            fireMapPinEvent(evt: MapPinEvent(src: mapPin!, coordinate: coordinate))
            setDragState(MKAnnotationView.DragState.dragging, animated: false)
        }
    }
    
    
    override func setDragState(_ dragState: MKAnnotationView.DragState, animated: Bool) {
        super.setDragState(dragState, animated: animated)
        switch dragState {
            case .starting:
                startDragging()
            case .ending, .canceling:
                endDragging()
            case .none, .dragging:
                break
        @unknown default:
            fatalError("Unknown drag state")
        }
    }
    
    
    func startDragging() {
        setDragState(MKAnnotationView.DragState.dragging, animated: false)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.layer.opacity = 0.8
            //self.transform     = CGAffineTransform.identity.scaledBy(x: 1.25, y: 1.25)
        }, completion: nil)
        
        if #available(iOS 10.0, *) {
            let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
            hapticFeedback.impactOccurred()
        }
    }
    func endDragging() {
        /*
        transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.layer.opacity = 1
            self.transform     = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        }, completion: nil)
        */
        // Give the user more haptic feedback when they drop the annotation.
        if #available(iOS 10.0, *) {
            let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
            hapticFeedback.impactOccurred()
        }
        setDragState(MKAnnotationView.DragState.none, animated: false)
    }
    
    
    // Event handling
    func setOnMapPinEvent(observer: MapPinEventObserver) -> Void {
        if !observers.isEmpty {
            for i in 0..<observers.count {
                if observers[i] === observer { return }
            }
        }
        observers.append(observer)
    }
    func removeOnMapPinEvent(observer: MapPinEventObserver) -> Void {
        for i in 0..<observers.count {
            if observers[i] === observer {
                observers.remove(at: i)
                return
            }
        }
    }
    func fireMapPinEvent(evt: MapPinEvent) -> Void {
        observers.forEach { observer in observer.onMapPinEvent(evt: evt) }
    }
}


class MapPinEvent {
    var src       : MapPin
    var coordinate: CLLocationCoordinate2D
    var point     : MKMapPoint
        
    
    init(src: MapPin, coordinate: CLLocationCoordinate2D) {
        self.src        = src
        self.coordinate = coordinate
        self.point      = MKMapPoint(self.coordinate)
    }
}
protocol MapPinEventObserver : class {
    func onMapPinEvent(evt: MapPinEvent)
}


class Polygon: MKPolygon {
    var id: String?
}
class Line: MKPolyline {
    var id: String?
}


class ViewPinAnnotation: MKPointAnnotation {
    var view: View?
    
    init(view: View) {
        super.init()
        self.view = view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class MultiPolygon: NSObject, MKOverlay {
    var polygons: [MKPolygon]?

    var boundingMapRect: MKMapRect

    init(polygons: [MKPolygon]?) {
        self.polygons = polygons
        self.boundingMapRect = MKMapRect.null

        super.init()

        guard let pols = polygons else { return }
        for (index, polygon) in pols.enumerated() {
            if index == 0 { self.boundingMapRect = polygon.boundingMapRect; continue }
            boundingMapRect = boundingMapRect.union(polygon.boundingMapRect)
        }
    }

    var coordinate: CLLocationCoordinate2D {
        return MKMapPoint(x: boundingMapRect.midX, y: boundingMapRect.maxY).coordinate
    }
}

class MultiPolygonPathRenderer: MKOverlayPathRenderer {
    /**
     Returns a `CGPath` equivalent to this polygon in given renderer.

     - parameter polygon: MKPolygon defining coordinates that will be drawn.

     - returns: Path equivalent to this polygon in given renderer.
     */
    func polyPath(for polygon: MKPolygon?) -> CGPath? {
        guard let polygon = polygon else { return nil }
        let points = polygon.points()

        if polygon.pointCount < 3 { return nil }
        let pointCount = polygon.pointCount

        let path = CGMutablePath()

        if let interiorPolygons = polygon.interiorPolygons {
            for interiorPolygon in interiorPolygons {
                guard let interiorPath = polyPath(for: interiorPolygon) else { continue }
                path.addPath(interiorPath, transform: .identity)
            }
        }

        let startPoint = point(for: points[0])
        path.move(to: CGPoint(x: startPoint.x, y: startPoint.y), transform: .identity)

        for i in 1..<pointCount {
            let nextPoint = point(for: points[i])
            path.addLine(to: CGPoint(x: nextPoint.x, y: nextPoint.y), transform: .identity)
        }

        return path
    }

    /// Draws the overlay’s contents at the specified location on the map.
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        // Taken from: http://stackoverflow.com/a/17673411

        guard let multiPolygon = self.overlay as? MultiPolygon else { return }
        guard let polygons = multiPolygon.polygons else { return }

        for polygon in polygons {
            guard let path = self.polyPath(for: polygon) else { continue }
            self.applyFillProperties(to: context, atZoomScale: zoomScale)
            context.beginPath()
            context.addPath(path)
            context.drawPath(using: CGPathDrawingMode.eoFill)
            self.applyStrokeProperties(to: context, atZoomScale: zoomScale)
            context.beginPath()
            context.addPath(path)
            context.strokePath()
        }
    }
}

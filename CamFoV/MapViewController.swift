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


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MapPinEventObserver, UIPickerViewDataSource, UIPickerViewDelegate, FoVController {
    var stateController : StateController?
    
    // Toolbar items
    @IBOutlet weak var mapButton          : UIBarButtonItem!
    @IBOutlet weak var camerasButton      : UIBarButtonItem!
    @IBOutlet weak var lensesButton       : UIBarButtonItem!
    @IBOutlet weak var viewsButton        : UIBarButtonItem!
    
    // View items
    @IBOutlet weak var mapView            : MKMapView!
    @IBOutlet weak var focalLengthSlider  : UISlider!
    @IBOutlet weak var focalLengthLabel   : UILabel!
    @IBOutlet weak var minFocalLengthLabel: UILabel!
    @IBOutlet weak var maxFocalLengthLabel: UILabel!
    @IBOutlet weak var apertureSlider     : UISlider!
    @IBOutlet weak var apertureLabel      : UILabel!
    @IBOutlet weak var minApertureLabel   : UILabel!
    @IBOutlet weak var maxApertureLabel   : UILabel!    
    @IBOutlet weak var lensPicker         : UIPickerView!
    @IBOutlet weak var lensLabel          : UILabel!
    @IBOutlet weak var dofSwitch          : UISwitch!
    @IBOutlet weak var dofLabel           : UILabel!
    @IBOutlet weak var cameraButton       : UIButton!    
    @IBOutlet weak var orientationButton  : UIButton!
    @IBOutlet weak var mapTypeSelector    : UISegmentedControl!
    
    
    var locationManager  : CLLocationManager!
    var cameraPin        : MapPin?
    var motifPin         : MapPin?
    var mapPins          : [MapPin] = [MapPin]()
    var triangle         : Triangle?
    var minTriangle      : Triangle?
    var maxTriangle      : Triangle?
    var trapezoid        : Trapezoid?
    var fovTriangle      : MKPolygon?
    var minFovTriangle   : MKPolygon?
    var maxFovTriangle   : MKPolygon?
    var fovTriangleFrame : MKPolygon?
    var fovCenterLine    : MKPolyline?
    var dofTrapezoid     : MKPolygon?
    var data             : FoVData?
    var fovVisible       : Bool          = true
    var dofVisible       : Bool          = false
    var focalLength      : Double        = 50
    var aperture         : Double        = 2.8
    var orientation      : Orientation   = Orientation.landscape
    var camera           : Camera?
    var lens             : Lens?
    /*
    var lenses           : [Lens]        = [
        Constants.DEFAULT_LENS,
        Lens(name: "Tamron SP 15-30mm f2.8", minFocalLength: 15, maxFocalLength: 30, minAperture: 2.8, maxAperture: 22),
        Lens(name: "Tamron SP 24-70mm f2.8", minFocalLength: 24, maxFocalLength: 70, minAperture: 2.8, maxAperture: 22),
        Lens(name: "Tamron SP 35mm f1.8", focalLength: 35, minAperture: 1.8, maxAperture: 22),
        Lens(name: "Tamron SP 90mm f2.8 Macro", focalLength: 90, minAperture: 2.8, maxAperture: 32),
        Lens(name: "Sigma 14mm f1.8 ART", focalLength: 14, minAperture: 1.8, maxAperture: 22),
        Lens(name: "Sigma 105mm f1.4 ART", focalLength: 105, minAperture: 1.4, maxAperture: 22),
        Lens(name: "Tokina 50mm f1.4 Opera", focalLength: 50, minAperture: 1.4, maxAperture: 22),
        Lens(name: "Nikon 85mm f1.8", focalLength: 85, minAperture: 1.8, maxAperture: 22),
        Lens(name: "Nikon 24-70mm f2.8", minFocalLength: 24, maxFocalLength: 70, minAperture: 2.8, maxAperture: 22),
        Lens(name: "Nikon 70-200mm f2.8", minFocalLength: 70, maxFocalLength: 200, minAperture: 2.8, maxAperture: 22),
        Lens(name: "Nikon 200-500mm f5.6", minFocalLength: 200, maxFocalLength: 500, minAperture: 5.6, maxAperture: 22),
        Lens(name: "Irix 11mm f4", focalLength: 11, minAperture: 4, maxAperture: 22),
        Lens(name: "MAK 1000", focalLength: 1000, minAperture: 10, maxAperture: 10)
    ]
    */

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.stateController                = appDelegate.stateController
        
        mapView.mapType                     = MKMapType.standard
        mapView.isZoomEnabled               = true
        mapView.isScrollEnabled             = true
        mapView.showsScale                  = true
        mapView.showsCompass                = true
        mapView.showsUserLocation           = true
        
    
        self.triangle                       = Triangle()
        self.minTriangle                    = Triangle()
        self.maxTriangle                    = Triangle()
        self.trapezoid                      = Trapezoid()
        
        self.mapView.delegate               = self
        self.lensPicker.dataSource          = self
        self.lensPicker.delegate            = self
        
        self.camera                         = stateController!.view.camera
        self.lens                           = stateController!.view.lens
        self.focalLength                    = stateController!.view.focalLength
        self.aperture                       = stateController!.view.aperture
        self.orientation                    = stateController!.view.orientation
    
        self.cameraPin                      = MapPin(pinType: PinType.camera, coordinate: stateController!.view.cameraPoint.coordinate)
        self.motifPin                       = MapPin(pinType: PinType.motif, coordinate: stateController!.view.motifPoint.coordinate)
        mapPins.removeAll()
        mapPins.append(self.cameraPin!)
        mapPins.append(self.motifPin!)
        mapView.addAnnotations(mapPins)
        
        self.focalLengthSlider.minimumValue = Float(self.lens!.minFocalLength)
        self.focalLengthSlider.maximumValue = Float(self.lens!.maxFocalLength)
        self.focalLengthSlider.value        = Float(self.focalLength)
        self.focalLengthLabel.text          = String(format: "%.0f mm", Double(round(self.focalLengthSlider!.value)))
        self.minFocalLengthLabel.text       = String(format: "%.0f", Double(round(self.lens!.minFocalLength)))
        self.maxFocalLengthLabel.text       = String(format: "%.0f", Double(round(self.lens!.maxFocalLength)))
        
        self.apertureSlider.minimumValue    = Float(self.lens!.minAperture)
        self.apertureSlider.maximumValue    = Float(self.lens!.maxAperture)
        self.apertureSlider.value           = Float(self.aperture)
        self.apertureLabel.text             = String(format: "f %.1f", Double(round(self.apertureSlider!.value * 10) / 10))
        self.minApertureLabel.text          = String(format: "%.1f", Double(round(self.lens!.minAperture * 10) / 10))
        self.maxApertureLabel.text          = String(format: "%.1f", Double(round(self.lens!.maxAperture * 10) / 10))
        
        self.dofLabel.text                  = self.dofSwitch.isOn ? "DoF Visible" : "DoF Hidden"
                
        self.lensLabel.text                 = "Selected lens"
        
        let mapTypeSelectorTextAttr         = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let mapTypeSelectorTextAttrSelected = [NSAttributedString.Key.foregroundColor: UIColor.white]
        mapTypeSelector.setTitleTextAttributes(mapTypeSelectorTextAttr, for: .normal)
        mapTypeSelector.setTitleTextAttributes(mapTypeSelectorTextAttrSelected, for: .selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        createMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getCurrentLocation()
    }
    
    
    // MARK: Event Handlers
    @IBAction func mapButtonPressed(_ sender: Any) {
    }
    @IBAction func camerasButtonPressed(_ sender: Any) {
        stateController!.updateView(getView(name: "current", description: ""))
        stateController!.store()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let camerasVC = storyboard.instantiateViewController(identifier: "CamerasViewController")
        show(camerasVC, sender: self)
    }
    @IBAction func lensesButtonPressed(_ sender: Any) {
    }
    @IBAction func viewsButtonPressed(_ sender: Any) {
    }
    
    @IBAction func focalLengthChanged(_ sender: Any) {
        //print("focalLength: \(Double(round(focalLengthSlider!.value)))")
        self.focalLengthLabel.text = String(format: "%.0f mm", Double(round(focalLengthSlider!.value)))
        self.focalLength = Double(round(focalLengthSlider!.value))
        stateController!.view.focalLength = self.focalLength
        
        updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
        updateDoFTrapezoid(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
        updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
    }
    
    @IBAction func apertureChanged(_ sender: Any) {
        //print("aperture: \(Double(round(apertureSlider!.value * 10) / 10))")
        self.apertureLabel.text = String(format: "f %.1f", Double(round(apertureSlider!.value * 10) / 10))
        self.aperture = Double(round(apertureSlider!.value * 10) / 10)
        stateController!.view.aperture = self.aperture
        
        if dofVisible {
            updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
            updateDoFTrapezoid(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
            updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
        }
    }
    
    @IBAction func orientationChanged1(_ sender: Any) {
        self.orientation = Orientation.landscape == self.orientation ? Orientation.portrait : Orientation.landscape
        stateController!.view.orientation = self.orientation
        switch self.orientation {
            case .landscape:
                self.orientationButton.transform = CGAffineTransform.identity
                break
            case .portrait:
                self.orientationButton.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2.0)
                break
        }
        
        updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
        updateDoFTrapezoid(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
        updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
        updateDragOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
    }
    
    
    @IBAction func dofChanged(_ sender: Any) {
        self.dofLabel.text = dofSwitch.isOn ? "DoF visible" : "DoF hidden"
        self.dofVisible    = dofSwitch.isOn
        updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
    }
        
    @IBAction func cameraButtonPressed(_ sender: Any) {
        let dX = motifPin!.point().x - cameraPin!.point().x
        let dY = motifPin!.point().y - cameraPin!.point().y
        mapView.removeAnnotations(mapPins)
        self.cameraPin!.coordinate = mapView.centerCoordinate
        self.motifPin!.coordinate  = MKMapPoint(x: self.cameraPin!.point().x + dX, y: self.cameraPin!.point().y + dY).coordinate
        mapView.addAnnotations(mapPins)
        
        stateController!.view.cameraPoint = self.cameraPin!.point()
        stateController!.view.motifPoint = self.motifPin!.point()
        
        updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
        updateDoFTrapezoid(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
        updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
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
    
    
    
    
    func createMapView() {
        switch stateController!.mapType {
            case 0 : mapView.mapType = MKMapType.standard
            case 1 : mapView.mapType = MKMapType.satellite
            case 2 : mapView.mapType = MKMapType.hybrid
            default: mapView.mapType = MKMapType.standard
        }
        mapTypeSelector.selectedSegmentIndex = stateController!.mapType
        
        let span   = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: cameraPin!.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        mapView.register(MapPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
        updateDoFTrapezoid(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
        updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
    }
    
    func getCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            //locationManager.startUpdatingLocation()
        }
    }
    
    
    // UIPickerViewDataSource and UIPickerViewDelegate methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stateController?.lenses.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        if (pickerLabel == nil){
            pickerLabel                  = UILabel()
            pickerLabel?.font            = UIFont(name: "System", size: 17)
            pickerLabel?.textColor       = UIColor.systemTeal
            pickerLabel?.backgroundColor = UIColor.clear
            pickerLabel?.textAlignment   = NSTextAlignment.center
        }
        pickerLabel?.text = stateController!.lenses[row].name
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateLens(lens: stateController!.lenses[row])
        updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
        updateDoFTrapezoid(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
        updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
    }
    
    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        manager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        mapView.setRegion(region, animated: true)
        
        /* Drop a pin at user's Current Location
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        myAnnotation.title = "Current location"
        mapView.addAnnotation(myAnnotation)
        */
    }
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error \(error)")
    }
    
    
    // MKMapViewDelegate methods
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, didChange: MKAnnotationView.DragState, fromOldState: MKAnnotationView.DragState) {
        switch (didChange) {
            case .starting:
                break;
            case .dragging:
                break;
            case .ending, .canceling:
                updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
                updateDoFTrapezoid(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
                updateOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point())
                break;
            default: break
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MapPin {
            let mapPin : MapPin = annotation as! MapPin
            print("MapPin: \(String(describing: mapPin.title)) found")
            if mapPin.title == "Camera" || mapPin.title == "Motif" {
                let mapPinAnnotationView : MapPinAnnotationView = MapPinAnnotationView(annotation: annotation, reuseIdentifier: mapPin.title)
                mapPinAnnotationView.mapView = mapView
                mapPinAnnotationView.setOnMapPinEvent(observer: self)
                print("Observer added")
                return mapPinAnnotationView
            }
        }
        return nil
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Draw Overlays
        if let overlay = overlay as? Polygon {
            if overlay.id == "dof" && dofVisible {
                let polygonView             = MKPolygonRenderer(overlay: overlay)
                polygonView.fillColor       = UIColor.init(displayP3Red: 0.45490196, green: 0.80784314, blue: 1.0, alpha: 0.25)
                polygonView.strokeColor     = UIColor.init(displayP3Red: 0.45490196, green: 0.80784314, blue: 1.0, alpha: 1.0)
                polygonView.lineWidth       = 1.0
                polygonView.lineDashPattern = [10, 10]
                polygonView.lineDashPhase   = 10
                return polygonView
            } else if overlay.id == "maxFov" && fovVisible {
                let polygonView         = MKPolygonRenderer(overlay: overlay)
                polygonView.fillColor   = UIColor.init(displayP3Red: 0.0, green: 0.56078431, blue: 0.8627451, alpha: 0.15)
                polygonView.strokeColor = UIColor.init(displayP3Red: 0.0, green: 0.56078431, blue:  0.8627451, alpha: 1.0)
                polygonView.lineWidth   = 1.0
                return polygonView
            } else if overlay.id == "minFov" && fovVisible {
                let polygonView         = MKPolygonRenderer(overlay: overlay)
                polygonView.fillColor   = UIColor.clear
                polygonView.strokeColor = UIColor.init(displayP3Red: 0.0, green: 0.56078431, blue:  0.8627451, alpha: 1.0)
                polygonView.lineWidth   = 1.0
                return polygonView
            } else if overlay.id == "fov" && fovVisible {
                let polygonView         = MKPolygonRenderer(overlay: overlay)
                polygonView.fillColor   = UIColor.init(displayP3Red: 0.0, green: 0.56078431, blue: 0.8627451, alpha: 0.45)
                polygonView.strokeColor = UIColor.init(displayP3Red: 0.0, green: 0.56078431, blue:  0.8627451, alpha: 1.0)
                polygonView.lineWidth   = 1.0
                return polygonView
            } else if overlay.id == "fovFrame" && fovVisible {
                let polygonView         = MKPolygonRenderer(overlay: overlay)
                polygonView.fillColor   = UIColor.clear
                polygonView.strokeColor = UIColor.init(displayP3Red: 0.0, green: 0.56078431, blue:  0.8627451, alpha: 1.0)
                polygonView.lineWidth   = 1.0
                return polygonView
            } else {
                return MKPolylineRenderer()
            }
        } else if let overlay = overlay as? Line {
            if overlay.id == "centerLine" && fovVisible {
                let polylineView         = MKPolylineRenderer(overlay: overlay)
                polylineView.strokeColor = UIColor.init(displayP3Red: 0.0, green: 0.56078431, blue:  0.8627451, alpha: 1.0)
                polylineView.lineWidth   = 1.0
                return polylineView
            } else {
                return MKPolylineRenderer()
            }
        }
        return MKPolylineRenderer()
    }
    
    
    // MapPin event handling
    func onMapPinEvent(evt: MapPinEvent) {
        if evt.src === cameraPin {
            updateFoVTriangle(cameraPoint: evt.point, motifPoint: self.motifPin!.point(), focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
            updateDragOverlay(cameraPoint: evt.point, motifPoint: self.motifPin!.point())
        } else if evt.src === motifPin {
            updateFoVTriangle(cameraPoint: self.cameraPin!.point(), motifPoint: evt.point, focalLength: self.focalLength, aperture: self.aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation)
            updateDragOverlay(cameraPoint: self.cameraPin!.point(), motifPoint: evt.point)
        }
    }
    
    
    // Update methods
    func updateLens(lens: Lens) -> Void {
        self.lens! = lens        
        
        self.focalLength = lens.minFocalLength + (lens.maxFocalLength - lens.minFocalLength)
        self.aperture    = lens.minAperture + (lens.maxAperture - lens.minAperture)
        
        focalLengthSlider.minimumValue = Float(lens.minFocalLength)
        focalLengthSlider.maximumValue = Float(lens.maxFocalLength)
        focalLengthSlider.value        = focalLengthSlider.minimumValue + (focalLengthSlider.maximumValue - focalLengthSlider.minimumValue) / 2
        focalLengthLabel.text          = String(format: "%.0f mm", Double(round(focalLengthSlider!.value)))
        minFocalLengthLabel.text       = String(format: "%.0f", Double(round(lens.minFocalLength)))
        maxFocalLengthLabel.text       = String(format: "%.0f", Double(round(lens.maxFocalLength)))
        
        apertureSlider.minimumValue    = Float(lens.minAperture)
        apertureSlider.maximumValue    = Float(lens.maxAperture)
        apertureSlider.value           = apertureSlider.minimumValue + (apertureSlider.maximumValue - apertureSlider.minimumValue) / 2
        apertureLabel.text             = String(format: "f %.1f", Double(round(apertureSlider!.value * 10) / 10))
        minApertureLabel.text          = String(format: "%.1f", Double(round(lens.minAperture * 10) / 10))
        maxApertureLabel.text          = String(format: "%.1f", Double(round(lens.maxAperture * 10) / 10))
    }
    
    func updateFoVTriangle(cameraPoint: MKMapPoint, motifPoint: MKMapPoint, focalLength: Double, aperture: Double, sensorFormat: SensorFormat, orientation: Orientation) -> Void {
        let distance : CLLocationDistance = cameraPoint.distance(to: motifPoint)
        if distance < 0.01 || distance > 9999 { return }
        
        let oldData = self.data
        do {
            self.data = try Helper.calc(camera: cameraPoint, motif: motifPoint, focalLengthInMM: focalLength, aperture: aperture, sensorFormat: sensorFormat, orientation: orientation)
        } catch {
            self.data = oldData
        }
        
        // Update FoV Triangle
        Helper.updateTriangle(camera: cameraPoint, motif: motifPoint, focalLengthInMM: focalLength, aperture: aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation, triangle: self.triangle!)
        let angle: Double = Helper.toRadians(degrees: Helper.calculateBearing(location1: cameraPoint, location2: motifPoint))
        self.triangle!.p2 = Helper.rotatePointAroundCenter(point: self.triangle!.p2, rotationCenter: cameraPoint, rad: angle)
        self.triangle!.p3 = Helper.rotatePointAroundCenter(point: self.triangle!.p3, rotationCenter: cameraPoint, rad: angle)
        
        // Update min FoV Triangle
        Helper.updateTriangle(camera: cameraPoint, motif: motifPoint, focalLengthInMM: self.lens!.maxFocalLength, aperture: aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation, triangle: self.minTriangle!)
        let minAngle: Double = Helper.toRadians(degrees: Helper.calculateBearing(location1: cameraPoint, location2: motifPoint))
        self.minTriangle!.p2 = Helper.rotatePointAroundCenter(point: self.minTriangle!.p2, rotationCenter: cameraPoint, rad: minAngle)
        self.minTriangle!.p3 = Helper.rotatePointAroundCenter(point: self.minTriangle!.p3, rotationCenter: cameraPoint, rad: minAngle)
        
        // Update max FoV Triangle
        Helper.updateTriangle(camera: cameraPoint, motif: motifPoint, focalLengthInMM: self.lens!.minFocalLength, aperture: aperture, sensorFormat: self.camera!.sensorFormat, orientation: self.orientation, triangle: self.maxTriangle!)
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
        if let fovTriangleFrame = self.fovTriangleFrame {
            mapView.removeOverlay(fovTriangleFrame)
        }
        self.fovTriangleFrame = nil
        
        if let minFovTriangle = self.minFovTriangle {
            mapView.removeOverlay(minFovTriangle)
        }
        self.minFovTriangle = nil
        
        if let maxFovTriangle = self.maxFovTriangle {
            mapView.removeOverlay(maxFovTriangle)
        }
        self.maxFovTriangle = nil
        
        if let fovTriangle = self.fovTriangle {
            mapView.removeOverlay(fovTriangle)
        }
        self.fovTriangle = nil

        if let fovCenterLine = self.fovCenterLine {
            mapView.removeOverlay(fovCenterLine)
        }
        self.fovCenterLine = nil
        
        if let dofTrapezoid = self.dofTrapezoid {
            mapView.removeOverlay(dofTrapezoid)
        }
        self.dofTrapezoid = nil
        
        
        // Create coordinates for min fov triangle
        let minFovTriangleCoordinates = minTriangle!.getPoints().map({ $0.coordinate })
        let minFovTriangle = Polygon(coordinates: minFovTriangleCoordinates, count: minFovTriangleCoordinates.count)
        minFovTriangle.id = "minFov"
        mapView.addOverlay(minFovTriangle)
        self.minFovTriangle = minFovTriangle
        
        // Create coordinates for max fov triangle
        let maxFovTriangleCoordinates = maxTriangle!.getPoints().map({ $0.coordinate })
        let maxFovTriangle = Polygon(coordinates: maxFovTriangleCoordinates, count: maxFovTriangleCoordinates.count)
        maxFovTriangle.id = "maxFov"
        mapView.addOverlay(maxFovTriangle)
        self.maxFovTriangle = maxFovTriangle
    
        // Create coordinates for fov triangle
        let fovTriangleCoordinates = triangle!.getPoints().map({ $0.coordinate })
        let fovTriangle = Polygon(coordinates: fovTriangleCoordinates, count: fovTriangleCoordinates.count)
        fovTriangle.id = "fov"
        mapView.addOverlay(fovTriangle)
        self.fovTriangle = fovTriangle
        
        // Create coordinates for fov center line
        let fovCenterLineCoordinates = [cameraPoint, motifPoint].map({ $0.coordinate })
        let fovCenterLine = Line(coordinates: fovCenterLineCoordinates, count: fovCenterLineCoordinates.count)
        fovCenterLine.id = "centerLine"
        mapView.addOverlay(fovCenterLine)
        self.fovCenterLine = fovCenterLine
        
        // Create coordinates for dof trapezoid
        let dofTrapezoidCoordinates = trapezoid!.getPoints().map({ $0.coordinate })
        let dofTrapezoid = Polygon(coordinates: dofTrapezoidCoordinates, count: dofTrapezoidCoordinates.count)
        dofTrapezoid.id = "dof"
        mapView.addOverlay(dofTrapezoid)
        self.dofTrapezoid = dofTrapezoid
    }
    
    
    func getView(name: String, description: String) -> View {
        return View(name: name, description: description, cameraPoint: self.cameraPin!.point(), motifPoint: self.motifPin!.point(), camera: self.camera!, lens: self.lens!, focalLength: self.focalLength, aperture: self.aperture, orientation: self.orientation)
    }
    
    
    
    func getElevation(camera: MapPin, motif: MapPin) -> Void {
        getJson { (json) in
            print("finished")
        }
    }
    
    func getJson(completion: @escaping (Response) ->()) {
        var urlString = "https://api.elevationapi.com/api/Elevation/line/"
        urlString += String(format: "%.7f", Double((cameraPin?.coordinate.latitude)!))
        urlString += ","
        urlString += String(format: "%.7f", Double((cameraPin?.coordinate.longitude)!))
        urlString += ","
        urlString += String(format: "%.7f", Double((motifPin?.coordinate.latitude)!))
        urlString += ","
        urlString += String(format: "%.7f", Double((motifPin?.coordinate.longitude)!))
        urlString += "?dataSet=SRTM_GL3&reduceResolution=0"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, res, err in
                if let data = data {
                    print("hey")
                    
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(Response.self, from: data) {
                        completion(json)
                    }
                }
            }.resume()
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
    public var title: String? {
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dragState == MKAnnotationView.DragState.dragging {
            if mapView != nil {
                let anchorPoint: CGPoint                = CGPoint(x: self.center.x, y: self.center.y - self.centerOffset.y)
                let coordinate : CLLocationCoordinate2D = mapView!.convert(anchorPoint, toCoordinateFrom: mapView)
                fireMapPinEvent(evt: MapPinEvent(src: mapPin!, coordinate: coordinate))
                setDragState(MKAnnotationView.DragState.dragging, animated: false)
            }
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
            self.transform     = CGAffineTransform.identity.scaledBy(x: 1.25, y: 1.25)
        }, completion: nil)
        
        if #available(iOS 10.0, *) {
            let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
            hapticFeedback.impactOccurred()
        }
    }
    func endDragging() {
        transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.layer.opacity = 1
            self.transform     = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        }, completion: nil)

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


class Response: Codable {
    
}

//
//  Helper.swift
//  FoV
//
//  Created by Gerrit Grunwald on 20.03.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import MapKit
import SystemConfiguration


public class Helper {
    public static func isICloudAvailable() -> Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }
    
    public static func toDegrees(radians: Double) -> Double {
        return radians * 180 / .pi
    }

    public static func toRadians(degrees: Double) -> Double {
        return degrees * .pi / 180
    }
    
    public static func clamp(min: Double, max: Double, value: Double) -> Double {
        if value < min { return min }
        if value > max { return max }
        return value
    }
    
    public static func distance(x1: Double, y1: Double, x2: Double, y2: Double) -> Double {
        let ac: Double = abs(y2 - y1)
        let cb: Double = abs(x2 - x1)
        return hypot(ac, cb)
    }
    
    public static func calc(camera: MKMapPoint, motif: MKMapPoint, focalLengthInMM: Double, aperture: Double, sensorFormat: Int64, orientation: Orientation) throws -> FoVData {
        let distance : Double = camera.distance(to: motif)
        
        if focalLengthInMM < 8 || focalLengthInMM > 2400 { throw FoVError.invalidArgument(message: "Error, focal length must be between 8mm and 2400mm") }
        if aperture < 0.7 || aperture > 99 { throw FoVError.invalidArgument(message: "Error, aperture must be between f/0.7 and f/99"); }
        if distance < 0.01 || distance > 9999 { throw FoVError.invalidArgument(message: "Error, distance must be between 0.01m and 9999m"); }

        let format : SensorFormat = SensorFormat.allCases[Int(sensorFormat)]
        
        let cropFactor: Double = format.cropFactor

        // Do all calculations in metres (because that's sensible).
        let focalLength: Double = focalLengthInMM / 1000.0

        // Let the circle of confusion be 0.0290mm for 35mm film.
        let circleOfConfusion: Double = (0.0290 / 1000.0) / cropFactor

        let hyperFocal    : Double = (focalLength * focalLength) / (aperture * circleOfConfusion) + focalLength
        let nearLimit     : Double = ((hyperFocal - focalLength) * distance) / (hyperFocal + distance - 2 * focalLength);

        let infinite      : Bool   = (hyperFocal - distance) < 0.00000001

        let farLimit      : Double = ((hyperFocal - focalLength) * distance) / (hyperFocal - distance)
        let frontPercent  : Double = (distance - nearLimit) / (farLimit - nearLimit) * 100
        let behindPercent : Double = (farLimit - distance) / (farLimit - nearLimit) * 100
        let total         : Double = farLimit - nearLimit

        let d             : Double = sqrt((format.width * format.width) + (format.height * format.height))
        let diagonalAngle : Double = 2.0 * atan(d / (2.0 * focalLengthInMM))
        let diagonalLength: Double = ((distance * sin(diagonalAngle / 2.0)) / cos(diagonalAngle / 2.0)) * 2.0
        let phi           : Double = asin(2.0 / 3.605551)
        let fovWidth      : Double
        let fovHeight     : Double
        if Orientation.landscape == orientation {
            fovWidth  = cos(phi) * diagonalLength
            fovHeight = sin(phi) * diagonalLength
        } else {
            fovWidth  = sin(phi) * diagonalLength
            fovHeight = cos(phi) * diagonalLength
        }

        let halfFovWidth  : Double = fovWidth * 0.5
        let halfFovHeight : Double = fovHeight * 0.5

        let fovWidthAngle : Double = 2 * asin(halfFovWidth / sqrt((distance * distance) + (halfFovWidth * halfFovWidth)))
        let fovHeightAngle: Double = 2 * asin(halfFovHeight / sqrt((distance * distance) + (halfFovHeight * halfFovHeight)))
        let radius        : Double = sqrt((halfFovWidth * halfFovWidth) + (distance * distance))
                
        return FoVData(camera: camera, motif: motif, focalLength: focalLengthInMM, aperture: aperture, sensorFormat: sensorFormat, orientation: orientation, infinite: infinite, hyperFocal: hyperFocal, nearLimit: nearLimit, farLimit: farLimit, frontPercent: frontPercent, behindPercent: behindPercent, total: total, diagonalAngle: diagonalAngle, diagonalLength: diagonalLength, fovWidth: fovWidth, fovWidthAngle: fovWidthAngle, fovHeight: fovHeight, fovHeightAngle: fovHeightAngle, radius: radius)
    }
    
    public static func updateTriangle(camera: MKMapPoint, motif: MKMapPoint, focalLengthInMM: Double, aperture: Double, sensorFormat: Int64, orientation: Orientation, triangle: Triangle) {
        do {
            let data: FoVData = try calc(camera: camera, motif: motif, focalLengthInMM: focalLengthInMM, aperture: aperture, sensorFormat: sensorFormat, orientation: orientation)
            let trianglePoints: [MKMapPoint] = calcTrianglePoints(data: data)
            triangle.p1 = trianglePoints[0]
            triangle.p2 = trianglePoints[1]
            triangle.p3 = trianglePoints[2]
        } catch {
            // Handle error here
        }
    }
    
    public static func calcTrianglePoints(data: FoVData) -> [MKMapPoint] {
        let halfFovWidthAngle: Double = data.fovWidthAngle / 2.0
        let p1: MKMapPoint = MKMapPoint(CLLocationCoordinate2D(latitude: Double(data.camera.coordinate.latitude), longitude: Double(data.camera.coordinate.longitude)))
        let p2: MKMapPoint = calcCoord(start: data.camera, distance: data.radius, bearing: -halfFovWidthAngle)
        let p3: MKMapPoint = calcCoord(start: data.camera, distance: data.radius, bearing: halfFovWidthAngle)
        return [p1, p2, p3]
    }
    
    public static func updateTrapezoid(camera: MKMapPoint, motif: MKMapPoint, focalLengthInMM: Double, aperture: Double, sensorFormat: Int64, orientation: Orientation, trapezoid: Trapezoid) {
        do {
            let data: FoVData = try calc(camera: camera, motif: motif, focalLengthInMM: focalLengthInMM, aperture: aperture, sensorFormat: sensorFormat, orientation: orientation)
            let trapezoidPoints: [MKMapPoint] = calcTrapezoidPoints(data: data)
            trapezoid.p1 = trapezoidPoints[0]
            trapezoid.p2 = trapezoidPoints[1]
            trapezoid.p3 = trapezoidPoints[2]
            trapezoid.p4 = trapezoidPoints[3]
        } catch {
            // Handle error here
        }
    }
    
    public static func calcTrapezoidPoints(data: FoVData) -> [MKMapPoint] {
        let halfFovWidthAngle: Double = data.fovWidthAngle / 2.0
        let radius1          : Double = data.nearLimit / cos(halfFovWidthAngle)
        let radius2          : Double = data.farLimit / cos(halfFovWidthAngle)

        let p1: MKMapPoint = calcCoord(start: data.camera, distance: radius1, bearing: -halfFovWidthAngle)
        let p2: MKMapPoint = calcCoord(start: data.camera, distance: radius2, bearing: -halfFovWidthAngle)
        let p3: MKMapPoint = calcCoord(start: data.camera, distance: radius2, bearing: halfFovWidthAngle)
        let p4: MKMapPoint = calcCoord(start: data.camera, distance: radius1, bearing: halfFovWidthAngle)

        return  [ p1, p2, p3, p4 ]
    }
    
    public static func calculateBearing(location1: MKMapPoint, location2: MKMapPoint) -> Double {
        let lat1   : Double = toRadians(degrees: Double(location1.coordinate.latitude))
        let lon1   : Double = Double(location1.coordinate.longitude)
        let lat2   : Double = toRadians(degrees: Double(location2.coordinate.latitude))
        let lon2   : Double = Double(location2.coordinate.longitude)
        let dLon   : Double = toRadians(degrees: lon2 - lon1);
        let y      : Double = sin(dLon) * cos(lat2)
        let x      : Double = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing: Double = (toDegrees(radians: atan2(y, x)) + 360).truncatingRemainder(dividingBy: 360)
        return bearing
    }
    
    public static func calcCoord(start: MKMapPoint, distance: Double, bearing: Double) -> MKMapPoint {
        let lat1   = toRadians(degrees: Double(start.coordinate.latitude))
        let lon1   = toRadians(degrees: Double(start.coordinate.longitude))
        let radius = distance / Constants.EARTH_RADIUS

        let lat2 = asin(sin(lat1) * cos(radius) + cos(lat1) * sin(radius) * cos(bearing))
        var lon2 = lon1 + atan2(sin(bearing) * sin(radius) * cos(lat1), cos(radius) - sin(lat1) * sin(lat2))
        lon2 = (lon2 + 3 * .pi).truncatingRemainder(dividingBy: (2 * .pi)) - .pi

        return MKMapPoint(CLLocationCoordinate2D(latitude: toDegrees(radians: lat2), longitude: toDegrees(radians: lon2)))
    }
    
    public static func rotatePointAroundCenter(point: MKMapPoint, rotationCenter: MKMapPoint, rad: Double) -> MKMapPoint {
        let sinValue = sin(rad)
        let cosValue = cos(rad)
        let dx       = point.x - rotationCenter.x
        let dy       = point.y - rotationCenter.y
        return MKMapPoint(x: rotationCenter.x + (dx * cosValue) - (dy * sinValue), y: rotationCenter.y + (dx * sinValue) + (dy * cosValue))
    }
    
    public static func spotToDictionary(spot: Spot) -> Dictionary<String,String> {
        let jsonString : String = spot.toFlatJsonString()
        if let data = jsonString.data(using: String.Encoding.utf8) {
            do {
                let decoder = JSONDecoder()
                let jsonDictionary = try decoder.decode(Dictionary<String, String>.self, from: data)
                return jsonDictionary
            } catch {
                return Dictionary<String,String>()
            }
        }
        return Dictionary<String,String>()
    }
    
    public static func dictionaryToSpot(dictionary: Dictionary<String,String>) -> Spot {
        do {
            return try Spot(dictionary: dictionary)
        } catch {
            return Constants.DEFAULT_SPOT
        }
    }
    
    public static func viewToDictionary(view: View) -> Dictionary<String,String> {
        let jsonString : String = view.toFlatJsonString()
        if let data = jsonString.data(using: String.Encoding.utf8) {
            do {
                let decoder = JSONDecoder()
                let jsonDictionary = try decoder.decode(Dictionary<String, String>.self, from: data)
                return jsonDictionary
            } catch {
                return Dictionary<String,String>()
            }
        }
        return Dictionary<String,String>()
    }
    
    public static func dictionaryToView(dictionary: Dictionary<String,String>, cameras: [Camera], lenses: [Lens]) -> View {
        do {
            return try View(dictionary: dictionary, cameras: cameras, lenses: lenses)
        } catch {
            return Constants.DEFAULT_VIEW
        }
    }
    
    public static func getPointByAngle(point: MKMapPoint, angleDeg: Double) -> MKMapPoint {
        return rotatePointAroundCenter(point: MKMapPoint(CLLocationCoordinate2D(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude + .pi/2)), rotationCenter: point, rad: toRadians(degrees: angleDeg))
    }
    public static func getPointByAngle(point: MKMapPoint, angleDeg: Double, distance: Double) -> MKMapPoint {        
        return rotatePointAroundCenter(point: MKMapPoint(x: point.x, y: point.y + distance), rotationCenter: point, rad: toRadians(degrees: angleDeg))
    }
    
    public static func getLatLonByAngleAndDistance(lat :Double, lon :Double, distanceInMeters :Double, angleDeg: Double) -> (Double, Double){
        let earthRadius      :Double = Constants.EARTH_RADIUS // m 
        let radians          :Double = toRadians(degrees: angleDeg)
        
        let originLatRad     :Double = toRadians(degrees: lat)
        let originLonRad     :Double = toRadians(degrees: lon)
        
        let distanceToRadius :Double = distanceInMeters / earthRadius
        
        let targetLatRad     :Double = asin(sin(originLatRad) * cos(distanceToRadius) + cos(originLatRad) * sin(distanceToRadius) * cos(radians))
        let targetLonRad     :Double = originLonRad + atan2(sin(radians) * sin(distanceToRadius) * cos(originLatRad), cos(distanceToRadius) - sin(originLatRad) * sin(targetLatRad))
        
        let targetLat        :Double = toDegrees(radians: targetLatRad)
        let targetLon        :Double = toDegrees(radians: targetLonRad)
        
        return (targetLat, targetLon)
    }
    
    // return date string with given format e.g. "dd.MM.yyyy HH:mm:ss"
    public static func dateToString(fromDate date:Date, formatString :String) -> String {
        let dateFormatter        = DateFormatter()
        dateFormatter.timeZone   = TimeZone.current
        dateFormatter.dateFormat = formatString.isEmpty ? "dd.MM.yyyy HH:mm:ss" : formatString
        return dateFormatter.string(from: date)
    }
        
    public static func setupTextFieldWithAlertIcon(field: UITextField, gestureRecognizer: UITapGestureRecognizer) -> UIView {
        let iconView       = UIImageView(frame: CGRect(x: 0, y: 0, width: Constants.ATTENTION_ICON.size.width, height: Constants.ATTENTION_ICON.size.height))
        iconView.image     = Constants.ATTENTION_ICON
        iconView.tintColor = UIColor.red
        
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.ATTENTION_ICON.size.width + 5, height: Constants.ATTENTION_ICON.size.height))
        iconContainerView.addSubview(iconView)
        
        field.rightViewMode                        = .always
        
        field.rightView                            = iconContainerView
        iconContainerView.isHidden                 = true
        iconContainerView.tintColor                = UIColor.red
        iconContainerView.isUserInteractionEnabled = true
        iconContainerView.addGestureRecognizer(gestureRecognizer)
        
        return iconContainerView
    }
    
    public static func setInfoLabel(label: UILabel, image: UIImage, imageColor: UIColor, size: CGSize, text: String, value1: Double, decimals1: Int, unit1: String, value2: Double? = nil, decimals2: Int? = nil, unit2: String? = nil) -> Void {
        let value1Formatter = NumberFormatter()
        value1Formatter.minimumFractionDigits = decimals1
        value1Formatter.usesGroupingSeparator = true
        value1Formatter.groupingSeparator     = " "
        value1Formatter.groupingSize          = 3
        
        let fullString = NSMutableAttributedString(string: "")
                
        let imgAttachment = NSTextAttachment()
        imgAttachment.image  = image.resize(to: size).withTintColor(imageColor)
        imgAttachment.bounds = CGRect(x: 0, y: -2, width: size.width, height: size.height)
        
        let imgString = NSAttributedString(attachment: imgAttachment)
    
        let textAttributes = [NSAttributedString.Key.foregroundColor: Constants.YELLOW]
        
        fullString.append(imgString)
        fullString.append(NSAttributedString(string: " "))
        fullString.append(NSAttributedString(string: text, attributes: textAttributes))
        fullString.append(NSAttributedString(string: value1Formatter.string(from: NSNumber(value: value1))! + unit1))
        
        if let value2 = value2 {
            if let decimals2 = decimals2 {
                let value2Formatter = NumberFormatter()
                value2Formatter.minimumFractionDigits = decimals2
                value2Formatter.usesGroupingSeparator = true
                value2Formatter.groupingSeparator     = " "
                value2Formatter.groupingSize          = 3
                if let unit2 = unit2 {
                    fullString.append(NSAttributedString(string: " [" + value2Formatter.string(from: NSNumber(value: value2))! + unit2 + "]"))
                } else {
                    fullString.append(NSAttributedString(string: " [" + value2Formatter.string(from: NSNumber(value: value2))! + "]"))
                }
            }
        }
                
        label.attributedText = fullString
    }
    
    public static func tagToString(tag: (String,Int32)) -> String {
        return String(tag.1)
    }
    
    public static func itemInBitmask(item: (String, Int32), bitmask: Int32) -> Bool {
        return (bitmask & item.1) != 0
    }
    
    public static func setNavBarTitle(navBar: UINavigationBar) -> Void {
        navBar.topItem?.title = Constants.APP_TITLE
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor          = UIColor.darkGray
        appearance.titleTextAttributes      = [NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        navBar.standardAppearance           = appearance
    }
    
    
    // MARK: iCloud Documents related
    public static func getDocumentsFolder() -> URL? {
        var containerUrl: URL? {
            return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: containerUrl!, includingPropertiesForKeys: nil)
            for file in fileURLs {
                print("File: \(file.absoluteString)")
            }
        } catch {
            print("Error while enumerating files \(containerUrl!.path): \(error.localizedDescription)")
        }
        
        return containerUrl
    }
    
    public static func saveViewsToDocuments(views: [View]) -> Void {
        // Create json string from views
        var jsonTxt : String = "[\n"
        for view in views {            
            jsonTxt += view.toFlatJsonString()
            jsonTxt += ",\n"
        }
        jsonTxt.removeLast(2)
        jsonTxt += "\n]"
        
        let containerUrl: URL? = getDocumentsFolder()
        
        // check for container existence
        if let url = containerUrl, !FileManager.default.fileExists(atPath: url.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        // Store json file to documents
        let jsonUrl = containerUrl?.appendingPathComponent(Constants.JSON_FILE_NAME).appendingPathExtension(Constants.JSON_FILE_EXTENSION)
        
        if FileManager.default.fileExists(atPath: jsonUrl!.path) {
            do {
                //try FileManager.default.removeItem(atPath: jsonUrl!.path)
                try FileManager.default.removeItem(at: jsonUrl!)
            } catch {
                print(error)
            }
        }
        
        if let jsonUrl = jsonUrl {
            do {
                try jsonTxt.write(to: jsonUrl, atomically: true, encoding: .utf8)
                _ = try String(contentsOf: jsonUrl)
                print("Stored views to iCloud documents (\(jsonUrl.path))")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    public static func loadViewsFromDocuments() -> [View] {
        var views :[View] = []
        
        let containerUrl: URL? = getDocumentsFolder()
        
        // check for container existence
        if let url = containerUrl, !FileManager.default.fileExists(atPath: url.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        let jsonUrl = containerUrl?.appendingPathComponent(Constants.JSON_FILE_NAME).appendingPathExtension(Constants.JSON_FILE_EXTENSION)
        if let jsonUrl = jsonUrl {
            print("json file: \(jsonUrl.path)")
            if FileManager.default.fileExists(atPath: jsonUrl.path) {
                do {
                    let jsonTxt = try String(contentsOf: jsonUrl)
                    if let jsonData = jsonTxt.data(using: .utf8) {
                        let viewDataArray :[ViewData] = try! JSONDecoder().decode([ViewData].self, from: jsonData)
                        for viewData in viewDataArray {
                            views.append(View(viewData: viewData))
                        }
                        print("Loaded views from iCloud documents (\(jsonUrl.path))")
                    } else {
                        views.append(Constants.DEFAULT_VIEW)
                    }
                } catch {
                    print(error.localizedDescription)
                    views.append(Constants.DEFAULT_VIEW)
                }
            } else {
                print("File not found")
                views.append(Constants.DEFAULT_VIEW)
            }
        }
        
        return views
    }
    
    public static func textToAdd(item: String, withComma: Bool? = false) -> String {
        return nil == withComma ? item + " " : withComma! ? item + ", " : item + " "
    }
    
    public static func getItemsTextFor(spot: Spot) -> NSAttributedString {
        var text : String = ""
                            
        var tags : String = ""
        for tag in Constants.TAGS {
            tags += Helper.itemInBitmask(item: tag, bitmask: spot.tags) ? textToAdd(item: tag.0) : ""
        }
        
        if tags.count > 0 {
            text += ("\n" + tags)
        }
        
        let itemsText :NSMutableAttributedString = NSMutableAttributedString(string: text)
        if text.count > 0 {
            itemsText.addAttributes([NSAttributedString.Key.foregroundColor: Constants.RED], range: NSRange(location: 0, length: tags.count))
        }
        
        return itemsText
    }
    
    public static func getItemsTextFor(view: View) -> NSAttributedString {
        var text           : String
        var equipmentBegin : Int
        var equipmentEnd   : Int
        var timesBegin     : Int
        var timesEnd       : Int
        var tagsBegin      : Int
        
        var equipment : String = "["
        for equip in Constants.EQUIPMENT {
            equipment += Helper.itemInBitmask(item: equip, bitmask: view.equipment) ? textToAdd(item: equip.0, withComma: true) : ""
        }
        
        if equipment.count > 1 {
            equipment.removeLast(2)
            equipment += "]"
            text = equipment
        } else {
            text = ""
        }
        equipmentBegin = 0
        equipmentEnd   = equipmentBegin + (equipment.count > 1 ? equipment.count : 0)
        
        var times : String = ""
        for time in Constants.TIMES {
            times += Helper.itemInBitmask(item: time, bitmask: view.times)  ? textToAdd(item: time.0)  : ""
        }
        
        if times.count > 0 {
            if equipment.count > 1 {
                times.removeLast()
                text += ("\n" + times)
            } else {
                text += times
            }
        }
        timesBegin = equipment.count == 1 ? equipmentEnd : equipmentEnd + 1
        timesEnd   = timesBegin + times.count
                
        var tags : String = ""
        for tag in Constants.TAGS {
            tags += Helper.itemInBitmask(item: tag, bitmask: view.tags) ? textToAdd(item: tag.0) : ""
        }        
        
        if tags.count > 0 {
            if times.count > 0 || equipment.count > 1 {
                tags.removeLast()
                text += ("\n" + tags)
            } else {
                text += tags
            }
        }
        tagsBegin = times.count == 0 ? timesEnd : timesEnd + 1
        
        let itemsText :NSMutableAttributedString = NSMutableAttributedString(string: text)
        if text.count > 0 {
            itemsText.addAttributes([NSAttributedString.Key.foregroundColor: Constants.YELLOW], range: NSRange(location: equipmentBegin, length: equipment.count > 2 ? equipment.count : 0))
            itemsText.addAttributes([NSAttributedString.Key.foregroundColor: Constants.BLUE], range: NSRange(location: timesBegin, length: times.count))
            itemsText.addAttributes([NSAttributedString.Key.foregroundColor: Constants.RED], range: NSRange(location: tagsBegin, length: tags.count))
        }
        
        return itemsText
    }
    
    public static func isItemInGroup(item: (String, Int32), group: [(String, Int32)]) -> Bool {
        return group.filter({ $0.0 == item.0 }).count > 0
    }
    
    public static func getCountryForSpot(spot: Spot) -> Void {
        let location : CLLocation = CLLocation(latitude: spot.point.coordinate.latitude, longitude: spot.point.coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            guard let placemarks = placemarks, error == nil else {
                self.processResponse(spot: spot, placemarks: nil, error: error)
                return
            }
            self.processResponse(spot: spot, placemarks: placemarks, error: nil)
        }
    }
    private static func processResponse(spot: Spot, placemarks: [CLPlacemark]?, error: Error?) -> Void {
        if nil == placemarks { return }
        for placemark in placemarks! {
            if let countryCode = placemark.isoCountryCode {
                spot.country = countryCode
                return
            } else {
                spot.country = ""
            }
        }
    }
    
    public static func getCountryForView(view: View) -> Void {
        let location : CLLocation = CLLocation(latitude: view.cameraPoint.coordinate.latitude, longitude: view.cameraPoint.coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            guard let placemarks = placemarks, error == nil else {
                self.processResponse(view: view, placemarks: nil, error: error)
                return
            }
            self.processResponse(view: view, placemarks: placemarks, error: nil)
        }
    }
    private static func processResponse(view: View, placemarks: [CLPlacemark]?, error: Error?) -> Void {
        if nil == placemarks { return }
        for placemark in placemarks! {
            if let countryCode = placemark.isoCountryCode {
                view.country = countryCode                
                return
            } else {
                view.country = ""                
            }
        }
    }
}

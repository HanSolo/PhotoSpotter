//
//  Constants.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 02.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import MapKit
import UIKit


public class Constants {
    public static let APP_TITLE               : String = "Photo Spotter"    
    public static let JSON_FILE_NAME          : String = "photospotter"
    public static let JSON_FILE_EXTENSION     : String = "json"
    
    public static let EARTH_RADIUS            : Double = 6_378_137.0 // in m                                                         
    public static let DATE_FORMAT             : String = "HH:mm"
    public static let EPD_SUN                 : String = "sun"
    public static let EPD_MOON                : String = "moon"
    public static let EPD_BLUE_HOUR_MORNING   : String = "blueHourMorning"
    public static let EPD_GOLDEN_HOUR_MORNING : String = "goldenHourMorning"
    public static let EPD_SUNRISE             : String = "sunrise"
    public static let EPD_GOLDEN_HOUR_EVENING : String = "goldenHourEvening"
    public static let EPD_SUNSET              : String = "sunset"
    public static let EPD_BLUE_HOUR_EVENING   : String = "blueHourEvening"
    public static let EPD_MOONRISE            : String = "moonrise"
    public static let EPD_MOONSET             : String = "moonset"
    public static let EPD_GOLDEN_HOUR_END     : String = "goldenHourEnd"
    public static let EPD_GOLDEN_HOUR         : String = "goldenHour"
    public static let EPD_SUNRISE_END         : String = "sunriseEnd"
    public static let EPD_SUNSET_START        : String = "sunsetStart"
    public static let EPD_BLUE_HOUR_DAWN_END  : String = "blueHourDawnEnd"
    public static let EPD_BLUE_HOUR_DUSK      : String = "blueHourDusk"
    public static let EPD_DAWN                : String = "dawn"
    public static let EPD_DUSK                : String = "dusk"
    public static let EPD_BLUE_HOUR_DAWN      : String = "blueHourDawn"
    public static let EPD_BLUE_HOUR_DUSK_END  : String = "blueHourDuskEnd"
    public static let EPD_NAUTICAL_DAWN       : String = "nauticalDawn"
    public static let EPD_NAUTICAL_DUSK       : String = "nauticalDusk"
    public static let EPD_NIGHT_END           : String = "nightEnd"
    public static let EPD_NIGHT               : String = "night"
    public static let EPD_RISE                : String = "rise"
    public static let EPD_SET                 : String = "set"
    public static let EPD_AZIMUTH             : String = "azimuth"
    public static let EPD_ALTITUDE            : String = "altitude"
    public static let EPD_ALWAYS_UP           : String = "alwaysUp"
    public static let EPD_ALWAYS_DOWN         : String = "alwaysDown"
    public static let EPD_SOLAR_NOON          : String = "solarNoon"
    public static let EPD_NADIR               : String = "nadir"
    public static let EPD_DEC                 : String = "dec"
    public static let EPD_RA                  : String = "ra"
    public static let EPD_DIST                : String = "dist"
    public static let EPD_FRACTION            : String = "fraction"
    public static let EPD_PHASE               : String = "phase"
    public static let EPD_ANGLE               : String = "angle"
    
    public static let UNIT_LENGTH         : String = " m"
    public static let UNIT_ANGLE          : String = " °"
    
    public static let TRANSLUCENT_GRAY    : UIColor = UIColor.darkGray.withAlphaComponent(0.75)
    public static let YELLOW              : UIColor = UIColor(red: 1.00, green: 0.77, blue: 0.32, alpha: 1.00)
    public static let RED                 : UIColor = UIColor(red: 1.00, green: 0.42, blue: 0.37, alpha: 1.00)
    public static let BLUE                : UIColor = UIColor(red: 0.30, green: 0.78, blue: 1.00, alpha: 1.00)
    
    public static let BLUE_STROKE         : UIColor = UIColor.init(red: 0.0,        green: 0.56078431, blue:  0.8627451, alpha: 1.0)
    public static let DOF_FILL            : UIColor = UIColor.init(red: 0.45490196, green: 0.80784314, blue: 1.0,        alpha: 0.1)
    public static let DOF_STROKE          : UIColor = UIColor.init(red: 0.45490196, green: 0.80784314, blue: 1.0,        alpha: 1.0)
    public static let MAX_FOV_FILL        : UIColor = UIColor.init(red: 0.0,        green: 0.56078431, blue: 0.8627451,  alpha: 0.1)
    public static let MAX_FOV_STROKE      : UIColor = BLUE_STROKE
    public static let MIN_FOV_FILL        : UIColor = UIColor.clear
    public static let MIN_FOV_STROKE      : UIColor = BLUE_STROKE
    public static let FOV_FILL            : UIColor = UIColor.init(red: 0.0,        green: 0.56078431, blue:  0.8627451, alpha: 0.3)
    public static let FOV_STROKE          : UIColor = BLUE_STROKE
    public static let FOV_FRAME_FILL      : UIColor = UIColor.clear
    public static let FOV_FRAME_STROKE    : UIColor = BLUE_STROKE

    public static let CENTER_LINE_STROKE  : UIColor = BLUE_STROKE
    public static let MOON_RISE_STROKE    : UIColor = UIColor.init(red: 0.0,  green: 0.9,        blue:  0.9,       alpha: 1.0)
    public static let MOON_SET_STROKE     : UIColor = UIColor.init(red: 0.0,  green: 0.375,      blue:  0.75,      alpha: 1.0)
    public static let MOON_STROKE         : UIColor = UIColor.init(red: 0.0,  green: 0.5,        blue:  0.5,       alpha: 1.0)
    public static let SUN_RISE_STROKE     : UIColor = UIColor.init(red: 0.9,  green: 0.9,        blue:  0.0,       alpha: 1.0)
    public static let SUN_SET_STROKE      : UIColor = UIColor.init(red: 0.75, green: 0.375,      blue:  0.0,       alpha: 1.0)
    public static let SUN_STROKE          : UIColor = UIColor.init(red: 0.5,  green: 0.5,        blue:  0.0,       alpha: 1.0)
    
    public static let DEFAULT_COUNTRY     : String     = "DE"
    
    public static let DEFAULT_POSITION    : MKMapPoint = MKMapPoint(CLLocationCoordinate2D(latitude : 51.911821, longitude: 7.633703))
    
    public static let DEFAULT_CAMERA      : Camera = Camera(name        : "DEFAULT DSLR",
                                                            sensorFormat: SensorFormat.FULL_FORMAT.id)
    
    public static let DEFAULT_LENS        : Lens   = Lens(name          : "DEFAULT LENS",
                                                          minFocalLength: 8,
                                                          maxFocalLength: 1000,
                                                          minAperture   : 0.7,
                                                          maxAperture   : 99,
                                                          sensorFormat  : SensorFormat.FULL_FORMAT.id)
    
    public static let DEFAULT_ORIENTATION : Orientation = Orientation.landscape
    
    public static let DEFAULT_ORIGIN      : MKMapPoint  = MKMapPoint(CLLocationCoordinate2D(latitude: 51.911821, longitude: 7.633703))

    public static let DEFAULT_MAP_SIZE    : MKMapSize   = MKMapSize(width: 46585.40107989311, height: 49490.00642307103)
    
    public static let DEFAULT_SPOT        : Spot        = Spot(name: "Home", description: "Test", point: DEFAULT_POSITION, country: DEFAULT_COUNTRY)
    
    public static let DEFAULT_VIEW        : View        = View(name       : "View",
                                                               description: "Default View",
                                                               cameraPoint: DEFAULT_POSITION,
                                                               motifPoint : MKMapPoint(CLLocationCoordinate2D(latitude: DEFAULT_POSITION.coordinate.latitude + 0.005, longitude: DEFAULT_POSITION.coordinate.longitude)),
                                                               camera     : DEFAULT_CAMERA,
                                                               lens       : DEFAULT_LENS,
                                                               focalLength: DEFAULT_LENS.minFocalLength + (DEFAULT_LENS.maxFocalLength - DEFAULT_LENS.minFocalLength) / 2,
                                                               aperture   : DEFAULT_LENS.minAperture + (DEFAULT_LENS.maxAperture - DEFAULT_LENS.minAperture) / 2,
                                                               orientation: Orientation.landscape,
                                                               country    : DEFAULT_COUNTRY,
                                                               mapRect    : MKMapRect(origin: DEFAULT_ORIGIN, size: DEFAULT_MAP_SIZE)
                                                              )
    
    public static let VALID_CLEAR         : CGColor = CGColor.init(srgbRed: 1, green: 1, blue: 1, alpha: 0)
    public static let INVALID_RED         : CGColor = UIColor(red: 1.00, green: 0.42, blue: 0.37, alpha: 1.00).cgColor
    
    public static let ATTENTION_ICON      : UIImage = UIImage(systemName: "exclamationmark.circle")!
    public static let INFO_ICON           : UIImage = UIImage(systemName: "info.circle")!
    public static let ERROR_ICON          : UIImage = UIImage(systemName: "xmark.octagon")!
    public static let STAR_ICON           : UIImage = (UIImage(named: "star")?.resize(to: CGSize(width: 24, height: 24)))!   
    
    // Equipment
    public static let EQP_TRIPOD     : (String, Int32) = ("Tripod",     1 << 0) //  1
    public static let EQP_GIMBAL     : (String, Int32) = ("Gimbal",     1 << 1) //  2
    public static let EQP_CPL_FILTER : (String, Int32) = ("CPL Filter", 1 << 2) //  4
    public static let EQP_ND_FILTER  : (String, Int32) = ("ND Filter",  1 << 3) //  8
    public static let EQP_IR_FILTER  : (String, Int32) = ("IR Filter",  1 << 4) // 16
    public static let EQP_FLASH      : (String, Int32) = ("Flash",      1 << 5) // 32
    public static let EQP_REMOTE     : (String, Int32) = ("Remote",     1 << 6) // 64
    
    public static let EQUIPMENT      :[(String, Int32)] = [
        EQP_TRIPOD, EQP_GIMBAL, EQP_CPL_FILTER, EQP_ND_FILTER, EQP_IR_FILTER, EQP_FLASH, EQP_REMOTE
    ]
    
    // Times
    public static let TMS_ALL_YEAR   : (String, Int32) = ("All Year",   1 << 0)
    public static let TMS_SPRING     : (String, Int32) = ("Spring",     1 << 1)
    public static let TMS_SUMMER     : (String, Int32) = ("Summer",     1 << 2)
    public static let TMS_AUTUMN     : (String, Int32) = ("Autumn",     1 << 3)
    public static let TMS_WINTER     : (String, Int32) = ("Winter",     1 << 4)
    public static let TMS_JANUARY    : (String, Int32) = ("January",    1 << 5)
    public static let TMS_FEBRUARY   : (String, Int32) = ("February",   1 << 6)
    public static let TMS_MARCH      : (String, Int32) = ("March",      1 << 7)
    public static let TMS_APRIL      : (String, Int32) = ("April",      1 << 8)
    public static let TMS_MAY        : (String, Int32) = ("May",        1 << 9)
    public static let TMS_JUNE       : (String, Int32) = ("June",       1 << 10)
    public static let TMS_JULY       : (String, Int32) = ("July",       1 << 11)
    public static let TMS_AUGUST     : (String, Int32) = ("August",     1 << 12)
    public static let TMS_SEPTEMBER  : (String, Int32) = ("September",  1 << 13)
    public static let TMS_OCTOBER    : (String, Int32) = ("October",    1 << 14)
    public static let TMS_NOVEMBER   : (String, Int32) = ("November",   1 << 15)
    public static let TMS_DECEMBER   : (String, Int32) = ("December",   1 << 16)
    
    public static let TIMES          : [(String, Int32)] = [
        TMS_ALL_YEAR, TMS_SPRING, TMS_SUMMER, TMS_AUTUMN, TMS_WINTER, TMS_JANUARY, TMS_FEBRUARY, TMS_MARCH,
        TMS_APRIL, TMS_MAY, TMS_JUNE, TMS_JULY, TMS_AUGUST, TMS_SEPTEMBER, TMS_OCTOBER, TMS_NOVEMBER, TMS_DECEMBER
    ]
    
    // Tags
    public static let TAG_NIGHT         : (String, Int32) = ("Nightshot"    , 1 << 0)
    public static let TAG_ASTRO         : (String, Int32) = ("Astro"        , 1 << 1)
    public static let TAG_MACRO         : (String, Int32) = ("Macro"        , 1 << 2)
    public static let TAG_POI           : (String, Int32) = ("POI"          , 1 << 3)
    public static let TAG_INFRARED      : (String, Int32) = ("Infrared"     , 1 << 4)
    public static let TAG_LONG_EXPOSURE : (String, Int32) = ("Long Exposure", 1 << 5)
    public static let TAG_CITYSCAPE     : (String, Int32) = ("Cityscape"    , 1 << 6)
    public static let TAG_LANDSCAPE     : (String, Int32) = ("Landscape"    , 1 << 7)
    public static let TAG_STREET        : (String, Int32) = ("Street"       , 1 << 8)
    public static let TAG_BRIDGE        : (String, Int32) = ("Bridge"       , 1 << 9)
    public static let TAG_LAKE          : (String, Int32) = ("Lake"         , 1 << 10)
    public static let TAG_SHIP          : (String, Int32) = ("Ship"         , 1 << 11)
    public static let TAG_CAR           : (String, Int32) = ("Car"          , 1 << 12)
    public static let TAG_FLOWER        : (String, Int32) = ("Flower"       , 1 << 13)
    public static let TAG_TREE          : (String, Int32) = ("Tree"         , 1 << 14)
    public static let TAG_BUILDING      : (String, Int32) = ("Building"     , 1 << 15)
    public static let TAG_BEACH         : (String, Int32) = ("Beach"        , 1 << 16)
    public static let TAG_SUNRISE       : (String, Int32) = ("Sunrise"      , 1 << 17)
    public static let TAG_SUNSET        : (String, Int32) = ("Sunset"       , 1 << 18)
    public static let TAG_MOON          : (String, Int32) = ("Moon"         , 1 << 19)
    public static let TAG_ARCHITECTURE  : (String, Int32) = ("Architecture" , 1 << 20)
    public static let TAG_CLOSEUP       : (String, Int32) = ("Close up"     , 1 << 21)
    public static let TAG_RIVER         : (String, Int32) = ("River"        , 1 << 22)
    public static let TAG_CHURCH        : (String, Int32) = ("Church"       , 1 << 23)
    public static let TAG_TRAIN         : (String, Int32) = ("Train"        , 1 << 24)
    
    public static let TAGS              : [(String, Int32)] = [
        TAG_NIGHT, TAG_ASTRO, TAG_MACRO, TAG_POI, TAG_INFRARED, TAG_LONG_EXPOSURE, TAG_CITYSCAPE, TAG_LANDSCAPE,
        TAG_STREET, TAG_BRIDGE, TAG_LAKE, TAG_SHIP, TAG_CAR, TAG_FLOWER, TAG_TREE, TAG_BUILDING, TAG_BEACH,
        TAG_SUNRISE, TAG_SUNSET, TAG_MOON, TAG_ARCHITECTURE, TAG_CLOSEUP, TAG_RIVER, TAG_CHURCH, TAG_TRAIN
    ]
    
    // UserDefaults keys
    public static let CAMERA_UD       : String = "camera"
    public static let LENS_UD         : String = "lens"
    public static let FOCAL_LENGTH_UD : String = "focalLength"
    public static let APERTURE_UD     : String = "aperture"
    
    
    // CoreData entities
    public static let LENS_CD   : String = "LensCD"
    public static let CAMERA_CD : String = "CameraCD"
    public static let SPOT_CD   : String = "SpotCD"
    public static let VIEW_CD   : String = "ViewCD"
    
    
    // CoreData fields
    public static let NAME_CD             : String = "name"
    public static let MIN_APERTURE_CD     : String = "minAperture"
    public static let MAX_APERTURE_CD     : String = "maxAperture"
    public static let MIN_FOCAL_LENGTH_CD : String = "minFocalLength"
    public static let MAX_FOCAL_LENGTH_CD : String = "maxFocalLength"
    public static let SENSOR_FORMAT_CD    : String = "sensorFormat"
    public static let DESCRIPTION_CD      : String = "desc"
    public static let CAMERA_LAT_CD       : String = "cameraLat"
    public static let CAMERA_LON_CD       : String = "cameraLon"
    public static let MOTIF_LAT_CD        : String = "motifLat"
    public static let MOTIF_LON_CD        : String = "motifLon"
    public static let CAMERA_NAME_CD      : String = "cameraName"
    public static let LENS_NAME_CD        : String = "lensName"
    public static let APERTURE_CD         : String = "aperture"
    public static let FOCAL_LENGTH_CD     : String = "focalLength"
    public static let ORIENTATION_CD      : String = "orientation"
    public static let COUNTRY_CD          : String = "country"
    public static let ORIGIN_LAT_CD       : String = "originLat"
    public static let ORIGIN_LON_CD       : String = "originLon"
    public static let MAP_WIDTH_CD        : String = "mapWidth"
    public static let MAP_HEIGHT_CD       : String = "mapHeight"
    public static let TAGS_CD             : String = "tags"
    public static let EQUIPMENT_CD        : String = "equipment"
    public static let TIMES_CD            : String = "times"
    public static let LAT_CD              : String = "lat"
    public static let LON_CD              : String = "lon"
}

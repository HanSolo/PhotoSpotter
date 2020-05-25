//
//  SunMoon.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 03.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

struct SunMoon {
    let rad   :Double = .pi / 180.0
    let dayMs :Double = 1000.0 * 60.0 * 60.0 * 24.0
    let J1970 :Double = 2440588.0
    let J2000 :Double = 2451545.0
    let J0    :Double = 0.0009

    var e     :Double = 23.4397 * .pi / 180.0
    
    /*
     sunrise         sunrise (top edge of the sun appears on the horizon)
     sunriseEnd      sunrise ends (bottom edge of the sun touches the horizon)
     goldenHourEnd   morning golden hour (soft light, best time for photography) ends
     solarNoon       solar noon (sun is in the highest position)
     goldenHour      evening golden hour starts
     sunsetStart     sunset starts (bottom edge of the sun touches the horizon)
     sunset          sunset (sun disappears below the horizon, evening civil twilight starts)
     dusk            dusk (evening nautical twilight starts)
     nauticalDusk    nautical dusk (evening astronomical twilight starts)
     night           night starts (dark enough for astronomical observations)
     nadir           nadir (darkest moment of the night, sun is in the lowest position)
     nightEnd        night ends (morning astronomical twilight starts)
     nauticalDawn    nautical dawn (morning nautical twilight starts)
     dawn            dawn (morning nautical twilight ends, morning civil twilight starts)
    */
    
    var times = [
        [     6.0,   Constants.EPD_GOLDEN_HOUR_END,    Constants.EPD_GOLDEN_HOUR        ],
        [    -0.3,   Constants.EPD_SUNRISE_END,        Constants.EPD_SUNSET_START       ],
        [    -0.833, Constants.EPD_SUNRISE,            Constants.EPD_SUNSET             ],
        [    -4.0,   Constants.EPD_BLUE_HOUR_DAWN_END, Constants.EPD_BLUE_HOUR_DUSK     ],
        [    -6.0,   Constants.EPD_DAWN,               Constants.EPD_DUSK               ],
        [    -8.0,   Constants.EPD_BLUE_HOUR_DAWN,     Constants.EPD_BLUE_HOUR_DUSK_END ],
        [   -12.0,   Constants.EPD_NAUTICAL_DAWN,      Constants.EPD_NAUTICAL_DUSK      ],
        [   -18.0,   Constants.EPD_NIGHT_END,          Constants.EPD_NIGHT              ]
    ]
    
    
    func toJulianDate(date : Date) -> Double {
        let JD_JAN_1_1970_0000GMT = 2440587.5
        return JD_JAN_1_1970_0000GMT + date.timeIntervalSince1970 / 86400
    }

    func fromJulianDate(jd : Double) -> Date {
        let JD_JAN_1_1970_0000GMT = 2440587.5
        return  Date(timeIntervalSince1970: (jd - JD_JAN_1_1970_0000GMT) * 86400)
    }
    
    func toDays(date :Date) -> Double { return toJulianDate(date: date) - J2000 }
    
    func dateToMillis(date :Date) -> Int64 { return Int64(date.timeIntervalSince1970 * 1000.0) }
    func dateFromMillis(millis :Int64) -> Date { return Date(timeIntervalSince1970: TimeInterval(millis / 1000)) }

    // general calculations for position
    func rightAscension(l :Double, b :Double) -> Double { return atan2(sin(l) * cos(e) - tan(b) * sin(e), cos(l)) }
    func declination(l :Double, b :Double) -> Double { return asin(sin(b) * cos(e) + cos(b) * sin(e) * sin(l)) }
    
    func azimuth(H :Double, phi :Double, dec :Double) -> Double { return atan2(sin(H), cos(H) * sin(phi) - tan(dec) * cos(phi)) }
    func altitude(H :Double, phi :Double, dec :Double) -> Double { return asin(sin(phi) * sin(dec) + cos(phi) * cos(dec) * cos(H)) }
    
    func siderealTime(d :Double, lw :Double) -> Double { return rad * (280.16 + 360.9856235 * d) - lw }
    
    func astroRefraction(height :Double) -> Double {
        // the following formula works for positive altitudes only.
        // if h = -0.08901179 a div/0 would occur.
        var _height :Double = height
        if _height < 0 { _height = 0 }
        
        // formula 16.4 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
        // 1.02 / tan(h + 10.26 / (h + 5.10)) h in degrees, result in arc minutes -> converted to rad:
        return 0.0002967 / tan(height + 0.00312536 / (height + 0.08901179))
    }
    
    // general sun calculations
    func solarMeanAnomaly(d :Double) -> Double { return rad * (357.5291 + 0.98560028 * d) }
    
    func eclipticLongitude(M :Double) -> Double {
        let C :Double = rad * (1.9148 * sin(M) + 0.02 * sin(2 * M) + 0.0003 * sin(3 * M)) // equation of center
        let P :Double = rad * 102.9372 // perihelion of the Earth
        return M + C + P + .pi
    }
    
    func sunCoords(d :Double) -> Dictionary<String, Double> {
        let M :Double = solarMeanAnomaly(d: d)
        let L :Double = eclipticLongitude(M: M)
        return [
            Constants.EPD_DEC: declination(l: L, b: 0),
            Constants.EPD_RA : rightAscension(l: L, b: 0)
        ]
    }
    
    // calculates sun position for a given date and latitude/longitude
    func getPosition(date :Date, lat :Double, lon :Double) -> Dictionary<String, Double> {
        let lw  = rad * -lon
        let phi = rad * lat
        let d   = toDays(date: date)
        
        let c = sunCoords(d: d)
        let H = siderealTime(d: d, lw: lw) - c[Constants.EPD_RA]!
        return [
            Constants.EPD_AZIMUTH : azimuth(H: H, phi: phi, dec: c[Constants.EPD_DEC]!),
            Constants.EPD_ALTITUDE: altitude(H: H, phi: phi, dec: c[Constants.EPD_DEC]!)
            ]
    }
    
    // calculations for sun times
    func julianCycle(d :Double, lw :Double) -> Double { return round(d - J0 - lw / (2.0 * .pi)) }
    
    func approxTransit(Ht :Double, lw :Double, n :Double) -> Double { return J0 + (Ht + lw) / (2.0 * .pi) + n }
    
    func solarTransitJ(ds :Double, M :Double, L :Double) -> Double { return J2000 + ds + 0.0053 * sin(M) - 0.0069 * sin(2.0 * L) }
    
    func hourAngle(h :Double, phi :Double, d :Double) -> Double { return acos((sin(h) - sin(phi) * sin(d)) / (cos(phi) * cos(d))) }
    
    // returns set time for the given sun altitude
    func getSetJ(height :Double, lw :Double, phi :Double, dec :Double, n :Double, M :Double, L :Double) -> Double {
        let w :Double = hourAngle(h: height, phi: phi, d: dec)
        let a :Double = approxTransit(Ht: w, lw: lw, n: n)
        return solarTransitJ(ds: a, M: M, L: L)
    }
    
    // calculates sun times for a given date and latitude/longitude
    func getTimes(date :Date, lat :Double, lon :Double) -> Dictionary<String, Date> {
        let lw    = rad * -lon
        let phi   = rad * lat
    
        let d     = toDays(date: date)
        let n     = julianCycle(d: d, lw: lw)
        let ds    = approxTransit(Ht: 0, lw: lw, n: n)
    
        let M     = solarMeanAnomaly(d: ds)
        let L     = eclipticLongitude(M: M)
        let dec   = declination(l: L, b: 0.0)
        
        let Jnoon = solarTransitJ(ds: ds, M: M, L: L)
        
        
        var result :Dictionary<String, Date> = [
            Constants.EPD_SOLAR_NOON: fromJulianDate(jd: Jnoon),
            Constants.EPD_NADIR     : fromJulianDate(jd: (Jnoon - 0.5))
        ]
    
        for i in 0..<times.count {
            let angle :Double = (times[i])[0] as! Double
            
            let Jset  = getSetJ(height: angle * rad, lw: lw, phi: phi, dec: dec, n: n, M: M, L: L)
            let Jrise = Jnoon - (Jset - Jnoon)
            
            let riseName :String = (times[i])[1] as! String
            let riseDate :Date   = fromJulianDate(jd: Jrise)
            
            let setName  :String = (times[i])[2] as! String
            let setDate  :Date   = fromJulianDate(jd: Jset)
            
            result[riseName] = riseDate
            result[setName]  = setDate
        }
    
        return result
    }
    
    func getMoonPosition(date :Date, lat :Double, lon :Double) -> Dictionary<String,Double> {
        let lw  = rad * -lon
        let phi = rad * lat
        let d   = toDays(date: date)
    
        let c   = moonCoords(d: d)
        let H   = siderealTime(d: d, lw: lw) - c[Constants.EPD_RA]!
        var h   = altitude(H: H, phi: phi, dec: c[Constants.EPD_DEC]!)
        // formula 14.1 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
        let pa  = atan2(sin(H), tan(phi) * cos(c[Constants.EPD_DEC]!) - sin(c[Constants.EPD_DEC]!) * cos(H))
    
        h = h + astroRefraction(height: h) // altitude correction for refraction
    
        return [
            Constants.EPD_AZIMUTH  : azimuth(H: H, phi: phi, dec: c[Constants.EPD_DEC]!),
            Constants.EPD_ALTITUDE : h,
            "distance"             : c[Constants.EPD_DIST]!,
            "parallacticAngle"     : pa
        ]
    }
    
    // moon calculations, based on http://aa.quae.nl/en/reken/hemelpositie.html formulas
    func moonCoords(d :Double) -> Dictionary<String, Double> { // geocentric ecliptic coordinates of the moon
        let L :Double = rad * (218.316 + 13.176396 * d) // ecliptic longitude
        let M :Double = rad * (134.963 + 13.064993 * d) // mean anomaly
        let F :Double = rad * (93.272 + 13.229350 * d)  // mean distance
    
        let l  :Double = L + rad * 6.289 * sin(M) // longitude
        let b  :Double = rad * 5.128 * sin(F)     // latitude
        let dt :Double = 385001 - 20905 * cos(M)  // distance to the moon in km
    
        return [
            Constants.EPD_RA  : rightAscension(l: l, b: b),
            Constants.EPD_DEC : declination(l: l, b: b),
            Constants.EPD_DIST: dt
        ]
    }
    
    // calculations for illumination parameters of the moon,
    // based on http://idlastro.gsfc.nasa.gov/ftp/pro/astro/mphase.pro formulas and
    // Chapter 48 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
    func getMoonIllumination(date :Date) -> Dictionary<String, Double> {
        let d = toDays(date: date)
        let s = sunCoords(d: d)
        let m = moonCoords(d: d)
        
        let sdist = 149598000.0 // distance from Earth to Sun in km
        
        let phi   = acos(sin(s[Constants.EPD_DEC]!) * sin(m[Constants.EPD_DEC]!) + cos(s[Constants.EPD_DEC]!) * cos(m[Constants.EPD_DEC]!) * cos(s[Constants.EPD_RA]! - m[Constants.EPD_RA]!))
        let inc   = atan2(sdist * sin(phi), m[Constants.EPD_DIST]! - sdist * cos(phi))
        let angle = atan2(cos(s[Constants.EPD_DEC]!) * sin(s[Constants.EPD_RA]! - m[Constants.EPD_RA]!), sin(s[Constants.EPD_DEC]!) * cos(m[Constants.EPD_DEC]!) -
        cos(s[Constants.EPD_DEC]!) * sin(m[Constants.EPD_DEC]!) * cos(s[Constants.EPD_RA]! - m[Constants.EPD_RA]!))
        
        return [
            Constants.EPD_FRACTION: (1 + cos(inc)) / 2,
            Constants.EPD_PHASE   : 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / .pi,
            Constants.EPD_ANGLE   : angle
        ]
    }
    
    func hoursLater(date :Date, h :Int) -> Date {
        return dateFromMillis(millis: dateToMillis(date: date) + Int64(h) * Int64(dayMs / 24.0))
    }
    func hoursLater(date :Date, h :Double) -> Date {
        return dateFromMillis(millis: dateToMillis(date: date) + Int64(h * dayMs / 24.0))
    }
    
    func getMoonTimes(date :Date, lat :Double, lon :Double) -> Dictionary<String, Date> {
        var t              :Date           = date
        let calendar       :Calendar       = Calendar.current
        var dateComponents :DateComponents = calendar.dateComponents([.year, .month, .day], from: t)
        dateComponents.hour       = 0
        dateComponents.minute     = 0
        dateComponents.second     = 0
        dateComponents.nanosecond = 0
        t = calendar.date(from: dateComponents)!
        
        let hc    = 0.133 * rad
        var h0    :Double = getMoonPosition(date: t, lat: lat, lon: lon)[Constants.EPD_ALTITUDE]! - hc
        var h1    :Double = 0.0
        var h2    :Double = 0.0
        var rise  :Double = -1.0
        var set   :Double = -1.0
        var a     :Double = 0.0
        var b     :Double = 0.0
        var xe    :Double = 0.0
        var ye    :Double = 0.0
        var d     :Double = 0.0
        var roots :Double = 0.0
        var x1    :Double = 0.0
        var x2    :Double = 0.0
        var dx    :Double = 0.0
    
        // go in 2-hour chunks, each time seeing if a 3-point quadratic curve crosses zero (which means rise or set)
        for i in stride(from: 1, through: 24, by: 2) {
            h1 = getMoonPosition(date: hoursLater(date: t, h: i), lat: lat, lon: lon)[Constants.EPD_ALTITUDE]! - hc
            h2 = getMoonPosition(date: hoursLater(date: t, h: i + 1), lat: lat, lon: lon)[Constants.EPD_ALTITUDE]! - hc
        
            a = (h0 + h2) / 2 - h1
            b = (h2 - h0) / 2
            xe = -b / (2 * a)
            ye = (a * xe + b) * xe + h1
            d = b * b - 4 * a * h1
            roots = 0
        
            if d >= 0 {
                dx = sqrt(d) / (abs(a) * 2.0)
                x1 = xe - dx
                x2 = xe + dx
                if abs(x1) <= 1 { roots += 1.0 }
                if abs(x2) <= 1 { roots += 1.0 }
                if x1 < -1 { x1 = x2 }
            }
        
            if roots == 1.0 {
                if h0 < 0 {
                    rise = Double(i) + x1
                } else {
                    set = Double(i) + x1
                }
            } else if roots == 2.0 {
                rise = Double(i) + (ye < 0 ? x2 : x1)
                set  = Double(i) + (ye < 0 ? x1 : x2)
            }
            
            if rise >= 0 && set >= 0 { break }
            h0 = h2
        }
        var result :Dictionary<String, Date> = [:]
        
        if rise >= 0.0 { result[Constants.EPD_RISE] = hoursLater(date: t, h: rise) }
        if set  >= 0.0 {
            /*
            if set < rise {
                t = t.addingTimeInterval(86500.0)
            }
            */
            result[Constants.EPD_SET]  = hoursLater(date: t, h: set)
        }
    
        if rise == -1.0 && set == -1.0 { result[ye > 0 ? Constants.EPD_ALWAYS_UP : Constants.EPD_ALWAYS_DOWN] = Date() }
    
        return result
    }

    // Get dictionary with sunrise, sunset blue- and golden-hours
    func getSunEvents(date: Date, lat :Double, lon :Double) -> Dictionary<String,String> {
        let times :Dictionary<String,Date> = getTimes(date: date, lat: lat, lon: lon)
        return getSunEvents(times: times)
    }
    func getSunEvents(times :Dictionary<String,Date>) -> Dictionary<String,String> {
        let blueHourMorningString   :String = "\(Helper.dateToString(fromDate: times[Constants.EPD_BLUE_HOUR_DAWN]!, formatString: Constants.DATE_FORMAT)) - \(Helper.dateToString(fromDate: times[Constants.EPD_BLUE_HOUR_DAWN_END]!, formatString: Constants.DATE_FORMAT))"
        let goldenHourMorningString :String = "\(Helper.dateToString(fromDate: times[Constants.EPD_BLUE_HOUR_DAWN_END]!, formatString: Constants.DATE_FORMAT)) - \(Helper.dateToString(fromDate: times[Constants.EPD_GOLDEN_HOUR_END]!, formatString: Constants.DATE_FORMAT))"
        let sunriseString           :String = Helper.dateToString(fromDate: times[Constants.EPD_SUNRISE]!, formatString: Constants.DATE_FORMAT)
        let goldenHourEveningString :String = "\(Helper.dateToString(fromDate: times[Constants.EPD_GOLDEN_HOUR]!, formatString: Constants.DATE_FORMAT)) - \(Helper.dateToString(fromDate: times[Constants.EPD_BLUE_HOUR_DUSK]!, formatString: Constants.DATE_FORMAT))"
        let sunsetString            :String = Helper.dateToString(fromDate: times[Constants.EPD_SUNSET]!, formatString: Constants.DATE_FORMAT)
        let blueHourEveningString   :String = "\(Helper.dateToString(fromDate: times[Constants.EPD_BLUE_HOUR_DUSK]!, formatString: Constants.DATE_FORMAT)) - \(Helper.dateToString(fromDate: times[Constants.EPD_BLUE_HOUR_DUSK_END]!, formatString: Constants.DATE_FORMAT))"
        
        let eventNames :Dictionary<String,String> = [
            Constants.EPD_BLUE_HOUR_MORNING   : blueHourMorningString,
            Constants.EPD_GOLDEN_HOUR_MORNING : goldenHourMorningString,
            Constants.EPD_SUNRISE             : sunriseString,
            Constants.EPD_GOLDEN_HOUR_EVENING : goldenHourEveningString,
            Constants.EPD_SUNSET              : sunsetString,
            Constants.EPD_BLUE_HOUR_EVENING   : blueHourEveningString
        ]
        
        return eventNames
    }
    
    func getSunEventsWithNames(date: Date, lat :Double, lon :Double) -> Dictionary<String, [String]> {
        let times :Dictionary<String,Date> = getTimes(date: date, lat: lat, lon: lon)
        return getSunEventsWithNames(times: times)
    }
    func getSunEventsWithNames(times :Dictionary<String,Date>) -> Dictionary<String, [String]> {
        let blueHourMorningString   :String = "\(Helper.dateToString(fromDate: times[Constants.EPD_BLUE_HOUR_DAWN]!, formatString: Constants.DATE_FORMAT)) - \(Helper.dateToString(fromDate: times[Constants.EPD_BLUE_HOUR_DAWN_END]!, formatString: Constants.DATE_FORMAT))"
        let goldenHourMorningString :String = "\(Helper.dateToString(fromDate: times[Constants.EPD_BLUE_HOUR_DAWN_END]!, formatString: Constants.DATE_FORMAT)) - \(Helper.dateToString(fromDate: times[Constants.EPD_GOLDEN_HOUR_END]!, formatString: Constants.DATE_FORMAT))"
        let sunriseString           :String = Helper.dateToString(fromDate: times[Constants.EPD_SUNRISE]!, formatString: Constants.DATE_FORMAT)
        let goldenHourEveningString :String = "\(Helper.dateToString(fromDate: times[Constants.EPD_GOLDEN_HOUR]!, formatString: Constants.DATE_FORMAT)) - \(Helper.dateToString(fromDate: times[Constants.EPD_BLUE_HOUR_DUSK]!, formatString: Constants.DATE_FORMAT))"
        let sunsetString            :String = Helper.dateToString(fromDate: times[Constants.EPD_SUNSET]!, formatString: Constants.DATE_FORMAT)
        let blueHourEveningString   :String = "\(Helper.dateToString(fromDate: times[Constants.EPD_BLUE_HOUR_DUSK]!, formatString: Constants.DATE_FORMAT)) - \(Helper.dateToString(fromDate: times[Constants.EPD_BLUE_HOUR_DUSK_END]!, formatString: Constants.DATE_FORMAT))"
                
        let events :Dictionary<String, [String]> = [
            Constants.EPD_BLUE_HOUR_MORNING  : [ "Blue Hour",   blueHourMorningString   ],
            Constants.EPD_GOLDEN_HOUR_MORNING: [ "Golden Hour", goldenHourMorningString ],
            Constants.EPD_SUNRISE            : [ "Sunrise",     sunriseString           ],
            Constants.EPD_GOLDEN_HOUR_EVENING: [ "Golden Hour", goldenHourEveningString ],
            Constants.EPD_SUNSET             : [ "Sunset",      sunsetString            ],
            Constants.EPD_BLUE_HOUR_EVENING  : [ "Blue Hour",   blueHourEveningString   ]
        ]
        return events
    }

    func getMoonEvents(date: Date, lat: Double, lon: Double) -> Dictionary<String,String> {
        let times :Dictionary<String,Date> = getMoonTimes(date: date, lat: lat, lon: lon)
        return getMoonEvents(times: times)
    }
    func getMoonEvents(times: Dictionary<String,Date>) -> Dictionary<String,String> {
        var moonriseString : String = "-"
        if let moonRise = times[Constants.EPD_RISE] {
            moonriseString = "\(Helper.dateToString(fromDate: moonRise, formatString: Constants.DATE_FORMAT))"
        }
        
        var moonsetString : String = "-"
        if let moonSet = times[Constants.EPD_SET] {
            moonsetString = "\(Helper.dateToString(fromDate: moonSet, formatString: Constants.DATE_FORMAT))"
        }
        
        let eventNames :Dictionary<String,String> = [
            Constants.EPD_MOONRISE : moonriseString,
            Constants.EPD_MOONSET  : moonsetString
        ]
        
        return eventNames
    }
    func getMoonEventsWithNames(date: Date, lat :Double, lon :Double) -> Dictionary<String, [String]> {
        let times :Dictionary<String,Date> = getTimes(date: date, lat: lat, lon: lon)
        return getMoonEventsWithNames(times: times)
    }
    func getMoonEventsWithNames(times :Dictionary<String,Date>) -> Dictionary<String, [String]> {
        let moonriseString :String = Helper.dateToString(fromDate: times[Constants.EPD_MOONRISE]!, formatString: Constants.DATE_FORMAT)
        let moonsetString  :String = Helper.dateToString(fromDate: times[Constants.EPD_MOONSET]!, formatString: Constants.DATE_FORMAT)
                
        let events :Dictionary<String, [String]> = [
            Constants.EPD_MOONRISE : [ "Moonrise", moonriseString ],
            Constants.EPD_MOONSET  : [ "Moonset",  moonsetString  ]
        ]
        return events
    }
    
    func getEventAngles(date: Date, lat :Double, lon :Double) -> Dictionary<String, (Double, Double)> {
        let times     :Dictionary<String,Date> = getTimes(date: date, lat: lat, lon: lon)
        let moonTimes :Dictionary<String,Date> = getMoonTimes(date: date, lat: lat, lon: lon)
        
        // Get dates for each event
        let blueHourMorningBegin   :Date = times[Constants.EPD_BLUE_HOUR_DAWN]!
        let blueHourMorningEnd     :Date = times[Constants.EPD_BLUE_HOUR_DAWN_END]!
        
        let sunrise                :Date = times[Constants.EPD_SUNRISE]!
        
        let goldenHourMorningBegin :Date = times[Constants.EPD_BLUE_HOUR_DAWN_END]!
        let goldenHourMorningEnd   :Date = times[Constants.EPD_GOLDEN_HOUR_END]!
        
        let goldenHourEveningBegin :Date = times[Constants.EPD_GOLDEN_HOUR]!
        let goldenHourEveningEnd   :Date = times[Constants.EPD_BLUE_HOUR_DUSK]!
        
        let sunset                 :Date = times[Constants.EPD_SUNSET]!
        
        let blueHourEveningBegin   :Date = times[Constants.EPD_BLUE_HOUR_DUSK]!
        let blueHourEveningEnd     :Date = times[Constants.EPD_BLUE_HOUR_DUSK_END]!
        
        let moonrise               :Date = moonTimes[Constants.EPD_RISE] ?? date
        let moonset                :Date = moonTimes[Constants.EPD_SET] ?? date
        
        
        // Get begin and end angle for each event
        let sunPosition  :Dictionary<String, Double> = getPosition(date: date, lat: lat, lon: lon)
        let moonPosition :Dictionary<String, Double> = getMoonPosition(date: date, lat: lat, lon: lon)
        
        let currentSunAngle             :Double = sunPosition[Constants.EPD_AZIMUTH]!
        let currentSunAltitude          :Double = sunPosition[Constants.EPD_ALTITUDE]!
                
        let currentMoonAngle            :Double = moonPosition[Constants.EPD_AZIMUTH]!
        let currentMoonAltitude         :Double = moonPosition[Constants.EPD_ALTITUDE]!
        
        let blueHourMorningBeginAngle   :Double = getPosition(date: blueHourMorningBegin, lat: lat, lon: lon)[Constants.EPD_AZIMUTH]!
        let blueHourMorningEndAngle     :Double = getPosition(date: blueHourMorningEnd, lat: lat, lon: lon)[Constants.EPD_AZIMUTH]!
        
        let sunriseAngle                :Double = getPosition(date: sunrise, lat: lat, lon: lon)[Constants.EPD_AZIMUTH]!
        
        let goldenHourMorningBeginAngle :Double = getPosition(date: goldenHourMorningBegin, lat: lat, lon: lon)[Constants.EPD_AZIMUTH]!
        let goldenHourMorningEndAngle   :Double = getPosition(date: goldenHourMorningEnd, lat: lat, lon: lon)[Constants.EPD_AZIMUTH]!
        
        let goldenHourEveningBeginAngle :Double = getPosition(date: goldenHourEveningBegin, lat: lat, lon: lon)[Constants.EPD_AZIMUTH]!
        let goldenHourEveningEndAngle   :Double = getPosition(date: goldenHourEveningEnd, lat: lat, lon: lon)[Constants.EPD_AZIMUTH]!
        
        let sunsetAngle                 :Double = getPosition(date: sunset, lat: lat, lon: lon)[Constants.EPD_AZIMUTH]!
        
        let blueHourEveningBeginAngle   :Double = getPosition(date: blueHourEveningBegin, lat: lat, lon: lon)[Constants.EPD_AZIMUTH]!
        let blueHourEveningEndAngle     :Double = getPosition(date: blueHourEveningEnd, lat: lat, lon: lon)[Constants.EPD_AZIMUTH]!
       
        let moonriseAngle               :Double = (moonrise == date) ? -1.0 : getMoonPosition(date: moonrise, lat: lat, lon: lon)[Constants.EPD_AZIMUTH]!
        
        let moonsetAngle                :Double = (moonset == date) ? -1.0 : getMoonPosition(date: moonset, lat: lat, lon: lon)[Constants.EPD_AZIMUTH]!
        
        
        let eventAngles :Dictionary<String, (Double, Double)> = [
            Constants.EPD_SUN                 : ( currentSunAngle, currentSunAltitude ),
            Constants.EPD_MOON                : ( currentMoonAngle, currentMoonAltitude ),
            Constants.EPD_BLUE_HOUR_MORNING   : ( blueHourMorningBeginAngle, blueHourMorningEndAngle ),
            Constants.EPD_GOLDEN_HOUR_MORNING : ( goldenHourMorningBeginAngle, goldenHourMorningEndAngle ),
            Constants.EPD_SUNRISE             : ( sunriseAngle, sunriseAngle ),
            Constants.EPD_GOLDEN_HOUR_EVENING : ( goldenHourEveningBeginAngle, goldenHourEveningEndAngle ),
            Constants.EPD_SUNSET              : ( sunsetAngle, sunsetAngle ),
            Constants.EPD_BLUE_HOUR_EVENING   : ( blueHourEveningBeginAngle, blueHourEveningEndAngle ),
            Constants.EPD_MOONRISE            : ( moonriseAngle, moonriseAngle ),
            Constants.EPD_MOONSET             : ( moonsetAngle, moonsetAngle )
        ]
        return eventAngles
    }
}

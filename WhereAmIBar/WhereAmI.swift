//
//  WhereAmI.swift
//  WhereAmIBar
//
//  Created by Matt Gowie on 2/18/17.
//  Copyright © 2017 Masterpoint. All rights reserved.
//

import Foundation
import PromiseKit

enum WhereAmIError: Error {
    case NoReasonToUpdateCancel
    case IpError(msg: String)
    case IpApiError(msg: String)
    case PostLocationError(msg: String)
}

class WhereAmI {
    
    func updateLocation() -> Promise<[String: Any]> {
        return updateLocation(previousIp: nil)
    }
    
    func updateLocation(previousIp: String?) -> Promise<[String: Any]> {
        return Promise { fullfil, reject in
            firstly {
                return fetchIp()
            }.then { ip -> Promise<[String: Any]> in
                NSLog("Previous IP: \(previousIp) IP: \(ip)")
                if previousIp == nil || previousIp! != ip {
                    return self.fetchLocation(ipAddress: ip)
                } else {
                    throw WhereAmIError.NoReasonToUpdateCancel
                }
            }.then { locationJson in
                return self.postLocationUpdate(locationInfo: locationJson)
            }.then { locationInfo in
                fullfil(locationInfo)
            }.catch { error in
                reject(error)
            }
        }
    }
    
    func fetchIp() -> Promise<String> {
        return Promise { fulfill, reject in
            let session = URLSession.shared
            let url = URL(string: "https://icanhazip.com")
            let task = session.dataTask(with: url!) { data, response, err in
                // first check for a hard error
                if let error = err {
                    reject(WhereAmIError.IpError(msg: "icanhazip error: \(error)"))
                }
                
                // then check the response code
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200: // all good!
                        let ip = String(data: data!, encoding: .utf8)!
                        NSLog("\(ip)")
                        fulfill(ip.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                    case 401: // unauthorized
                        reject(WhereAmIError.IpError(msg: "icanhazip returned an 'unauthorized' response."))
                    default:
                        let error = String.init(format: "icanhazip returned response: %d %@",
                                                httpResponse.statusCode,
                                                HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                        reject(WhereAmIError.IpError(msg: error))
                    }
                }
            }
            task.resume()
        }
    }
    
    private func fetchLocation(ipAddress: String?) -> Promise<[String: Any]> {
        return Promise { fulfill, reject in
            let session = URLSession.shared
            if let ip = ipAddress {
                let url = URL(string: "http://ip-api.com/json/\(ip)")
                let task = session.dataTask(with: url!) { data, response, err in
                    // first check for a hard error
                    if let error = err {
                        reject(WhereAmIError.IpApiError(msg: "ip-api error: \(error)"))
                    }
                    
                    // then check the response code
                    if let httpResponse = response as? HTTPURLResponse {
                        switch httpResponse.statusCode {
                        case 200: // all good!
                            let json = self.convertToDictionary(data: data!)
                            fulfill(json!)
                        case 401: // unauthorized
                            reject(WhereAmIError.IpApiError(msg: "ip-api returned an 'unauthorized' response."))
                        default:
                            let error = String.init(format: "ip-api returned response: %d %@",
                                                    httpResponse.statusCode,
                                                    HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                            reject(WhereAmIError.IpApiError(msg: error))
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    private func postLocationUpdate(locationInfo: [String: Any]) -> Promise<[String: Any]> {
        return Promise { fulfill, reject in
            let expected = transformLocationInfo(json: locationInfo)
            let jsonData = try? JSONSerialization.data(withJSONObject: expected)
            NSLog(String(data: jsonData!, encoding: .utf8)!)
            
            // create post request
            let url = URL(string: "https://whereami.mattgowie.com/location")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    reject(error!)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200: // all good!
                        fulfill(expected)
                    default:
                        let error = "POST Request to update location failed! \(httpResponse.statusCode)" +
                        "\(String(data: data!, encoding: .utf8)!)"
                        reject(WhereAmIError.PostLocationError(msg: error))
                    }
                }
            }
            task.resume()
        }
    }
    
    private func convertToDictionary(data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    private func transformLocationInfo(json: [String: Any]) -> [String: Any] {
        var result = [String: Any]()
        // :country_long, :country, :city, :region, :latitude, :longitude, :ip, :timestamp
        
        if let city = json["city"] { result["city"] = city }
        if let ip = json["query"] { result["ip"] = ip }
        if let lat = json["lat"] { result["latitude"] = lat }
        if let lon = json["lon"] { result["longitude"] = lon }
        if let countryLong = json["country"] { result["country_long"] = countryLong }
        if let country = json["countryCode"] { result["country"] = country }
        if let zip = json["zip"] { result["zip"] = zip }
        if let region = json["regionName"] { result["region"] = region }
        result["timestamp"] = "\(NSDate().timeIntervalSince1970)"
        
        return result
    }
}

//
//  APIClient+URLSessionTask.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/21/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import Foundation

extension APIClient {
    
    fileprivate func dataTask(_ urlRequest: URLRequest, success: @escaping () -> Void, failure: @escaping (_ error:APIError) -> ()) -> URLSessionTask {
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            let serializedResponse: Dictionary<String, AnyObject>? = {
                if let data = data {
                    do {
                        return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, AnyObject>
                    } catch {
                        return nil
                    }
                }
                return nil
            }()
            if let actualError = error as NSError! {
                DispatchQueue.main.async(execute: {
                    let error = APIError(error: actualError)
                    error.responseText = serializedResponse?.description
                    failure(error)
                })
            } else if HTTPURLResponse.isUnauthorized(response as? HTTPURLResponse) {
                //failure(error: error)
            } else if (response as! HTTPURLResponse).didFail() {
                let err = APIError(urlResponse: (response as! HTTPURLResponse), jsonResponse: serializedResponse!)
                DispatchQueue.main.async(execute: {
                    failure(err)
                })
            } else {
                DispatchQueue.main.async(execute: {
                    success()
                })
            }
        })
        lastPerformedTask = task
        return task
    }
    
    fileprivate func jsonDataTask(_ urlRequest: URLRequest, success: @escaping (Dictionary<String, AnyObject>) -> Void, failure: @escaping (_ error: APIError) -> () ) -> URLSessionTask {
//        print(urlRequest)
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            DispatchQueue.main.async(execute: {
                let httpResponse = response as? HTTPURLResponse
                
                // if actual error happens (no internet, timeout, etc.)
                if let actualError = error as NSError!, let actualData = data {
                    let error = APIError(error: actualError)
                    let string = NSString(data: actualData, encoding: String.Encoding.ascii.rawValue)
                    error.responseText = string as? String
                    failure(error)
                } else {
                    let code: Int = {
                        if httpResponse == nil {
                            return Constants.Error.Code.unknownError.rawValue
                        } else {
                            return httpResponse!.statusCode
                        }
                    }()
                    if HTTPURLResponse.isUnauthorized(httpResponse) {
                        let error = APIError(domain:Constants.Error.apiClientErrorDomain, code:Constants.Error.Code.unauthorizedError.rawValue, userInfo: nil)
                        failure(error)
                    } else {
                        if let actualData = data as Data? {
                            if actualData.count == 0 {
                                failure(APIError(domain: Constants.Error.apiClientErrorDomain, code: code, userInfo: nil))
                            } else if (response as! HTTPURLResponse).didFail() {
                                let err = APIError(domain: Constants.Error.apiClientErrorDomain, code: code, userInfo: nil)
                                failure(err)
                            } else {
                                let serialized = try! JSONSerialization.jsonObject(with: actualData, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, AnyObject>
                                
                                if (serialized == nil) {
                                    let array_serialized = try! JSONSerialization.jsonObject(with: actualData, options: .allowFragments) as? [Dictionary<String, AnyObject>]
                                    var ser_array_serialized = Dictionary<String, AnyObject>()
                                    ser_array_serialized.updateValue(array_serialized! as AnyObject, forKey: "response")
                                    success(ser_array_serialized)
                                } else {
                                    success(serialized!)
                                }
                            }
                        }
                    }
                }
            })
        })
        lastPerformedTask = task
        return task
    }
    
    func urlSessionTask(_ method: httpMethod, url: String, parameters: Dictionary<String, AnyObject>? = nil, success: @escaping () -> Void, failure: @escaping (_ error: APIError) -> ()) -> URLSessionTask {
        let url = URL(string: url)
        let urlRequest = NSMutableURLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.httpMethod = method.rawValue
        
        if let actualParameters = parameters {
            urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: actualParameters, options: JSONSerialization.WritingOptions.prettyPrinted)
        }
        
        // add additional headers
        for (key, value) in self.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        let task = dataTask(urlRequest as URLRequest, success: success) { (error) in
            if error.code == Constants.Error.Code.unauthorizedError.rawValue {
                self.validateFullScope {
                    failure(APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.unknownError.rawValue, userInfo: nil))
                }
            } else {
                failure(error)
            }
        }
        
        return task
    }
    
    /**
     GET a request to server that fetches json structures, like list of documents, list of folders.
     :param: url       url to fetch data from
     :param: success   block with json data that has to be inserted to database
     :param: failure   failure block with error that should be sent to present a UIAlertcontroller with API error
     :returns: a task to resume when the request should be started
     */
    func urlSessionJSONTask(url: String,  success: @escaping (Dictionary<String,AnyObject>) -> Void , failure: @escaping (_ error: APIError) -> ()) -> URLSessionTask {
        
        let fullURL = URL(string: url, relativeTo: Constants.url.baseURL as URL?)
        let urlRequest = NSMutableURLRequest(url: fullURL!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.httpMethod = httpMethod.get.rawValue
        for (key, value) in self.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        let task = jsonDataTask(urlRequest as URLRequest, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.unauthorizedError.rawValue {
                self.validateFullScope {
                    failure(APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.unknownError.rawValue, userInfo: nil))
                }
                print(error.responseText)
            } else {
                failure(error)
            }
        }
        
        return task
    }
    
    func urlSessionTaskWithNoAuthorizationHeader(_ method: httpMethod, url: String, parameters: Dictionary<String, AnyObject>? = nil, success: @escaping () -> Void, failure: @escaping (_ error: APIError) -> ()) -> URLSessionTask {
        let url = URL(string: url)
        let urlRequest = NSMutableURLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: parameters!, options: JSONSerialization.WritingOptions.prettyPrinted)
        urlRequest.setValue(nil, forHTTPHeaderField: "Authorization")
        
        let task = dataTask(urlRequest as URLRequest, success: success, failure: failure)
        return task
    }
}

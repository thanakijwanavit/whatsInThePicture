//
//  AWSClientFunctions.swift
//  whats in the picture
//
//  Created by nic Wanavit on 11/24/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import Foundation
import AWSAPIGateway
import AWSMobileClient
import AWSAppSync
import AWSS3
  // ViewController or application context . . .

    


class AWSClientFunctions {
    
    //New overloaded function that gets Cognito User Pools tokens
    func doInvokeAPI_test2(){
        AWSMobileClient.default().getTokens { (tokens, err) in
            self.doInvokeAPI_test(token: tokens!.idToken!.tokenString!)
        }
    }

    //Updated function with arguments and code updates
    func doInvokeAPI_test(token:String) {

        let headerParameters = [
                //other headers
                "Authorization" : token
        ]

        let serviceConfiguration = AWSServiceConfiguration(region: AWSRegionType.APSoutheast1,
                                                               credentialsProvider: nil)

    }
    
    
    
    static func doInvokeAPI() {
     // change the method name, or path or the query string parameters here as desired
     let httpMethodName = "POST"
     // change to any valid path you configured in the API
     let URLString = "/items"
     let queryStringParameters = ["key1":"{value1}"]
     let headerParameters = [
         "Content-Type": "application/json",
         "Accept": "application/json"
     ]

     let httpBody = "{ \n  " +
             "\"key1\":\"value1\", \n  " +
             "\"key2\":\"value2\", \n  " +
             "\"key3\":\"value3\"\n}"

     // Construct the request object
     let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
             urlString: URLString,
             queryParameters: queryStringParameters,
             headerParameters: headerParameters,
             httpBody: httpBody)

    // Create a service configuration
    let serviceConfiguration = AWSServiceConfiguration(region: AWSRegionType.APSoutheast1,
          credentialsProvider: AWSMobileClient.default())

    // Initialize the API client using the service configuration
    MLCLASSIFICATIONMLClassificationClient.registerClient(withConfiguration: serviceConfiguration!, forKey: "CloudLogicAPIKey")

        
    // Fetch the Cloud Logic client to be used for invocation
    let invocationClient = MLCLASSIFICATIONMLClassificationClient.client(forKey: "CloudLogicAPIKey")

    invocationClient.invoke(apiRequest).continueWith { (task: AWSTask) -> Any? in
             if let error = task.error {
                 print("Error occurred: \(error)")
                 // Handle error here
                 return nil
             }

             // Handle successful result here
             let result = task.result!
             let responseString = String(data: result.responseData!, encoding: .utf8)

             print(responseString)
             print(result.statusCode)

             return nil
         }
     }
    
    
    static func getPredictionResult(s3Path:String, completion: @escaping (String?, Error?)->Void){
        
        
        let queryString = ["s3Path": s3Path]
        let forecastEndpoint = "some endpoint uri"  // put lambda edpoint here
        getLambda(queryString: queryString, endpoint: forecastEndpoint, completion: completion)
    }
    
    
    

    static func getLambda(queryString:[String:String], endpoint:String, completion: @escaping (String?, Error?)->Void) {
     // change the method name, or path or the query string parameters here as desired
     let httpMethodName = "GET"
     // change to any valid path you configured in the API
//     let URLString = "/items"
//     let queryStringParameters = ["key1":"{value1}"]
     let headerParameters = [
         "Content-Type": "application/json",
         "Accept": "application/json"
     ]

//     let httpBody = "{ \n  " +
//             "\"key1\":\"value1\", \n  " +
//             "\"key2\":\"value2\", \n  " +
//             "\"key3\":\"value3\"\n}"

     // Construct the request object
     let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
             urlString: endpoint,
             queryParameters: queryString,
             headerParameters: headerParameters,
             httpBody: nil)

    // Create a service configuration
    let serviceConfiguration = AWSServiceConfiguration(region: AWSRegionType.APSoutheast1,
          credentialsProvider: AWSMobileClient.default())

    // Initialize the API client using the service configuration
    MLCLASSIFICATIONMLClassificationClient.registerClient(withConfiguration: serviceConfiguration!, forKey: "CloudLogicAPIKey")

        
    // Fetch the Cloud Logic client to be used for invocation
    let invocationClient = MLCLASSIFICATIONMLClassificationClient.client(forKey: "CloudLogicAPIKey")

    invocationClient.invoke(apiRequest).continueWith { (task: AWSTask) -> Any? in
             if let error = task.error {
                 print("Error occurred: \(error)")
                 // Handle error here
                 completion(nil,error)
                 return nil
             }

             // Handle successful result here
             let result = task.result!
             let responseString = String(data: result.responseData!, encoding: .utf8)

             print(responseString!)
             print(result.statusCode)
             completion(responseString, nil)

             return nil
         }
     }
    
    
    
    
    //// upload file to s3
    static func uploadData(data:Data,fileName:String, completion: @escaping (_ filePath:String?, Error?)->Void) {
//        let data: Data = Data() // Data to be uploaded
        
        let uploadLocation = "public/images/\(fileName)"
        let bucketName = "whatsinthepictureimagestorage-ios"
        debugPrint("uploading file \(fileName) to location to \(uploadLocation)")

        let expression = AWSS3TransferUtilityUploadExpression()
           expression.progressBlock = {(task, progress) in
              DispatchQueue.main.async(execute: {
                // Do something e.g. Update a progress bar.
             })
        }

        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
           DispatchQueue.main.async(execute: {
              // Do something e.g. Alert a user for transfer completion.
              // On failed uploads, `error` contains the error object.
            if error == nil {
                debugPrint("file upload complete to s3://\(bucketName)/\(uploadLocation)")
                completion("s3://\(bucketName)/\(uploadLocation)", nil)
            } else {
                debugPrint("error: \(error.debugDescription)")
                completion(nil, error)
            }
           })
        }

        let transferUtility = AWSS3TransferUtility.default()

        transferUtility.uploadData(data,
             bucket: bucketName,
             key: uploadLocation,
             contentType: "text/plain",
             expression: expression,
             completionHandler: completionHandler).continueWith {
                (task) -> AnyObject? in
                    if let error = task.error {
                       debugPrint("Error: \(error.localizedDescription)")
                    }

                    if let _ = task.result {
                       // Do something with uploadTask.
                    }
                    return nil;
            }
    }
    
    
    
    
    static func convertAndUploadToS3(imageToScaleAndUpload:UIImage, filename:String, completion: @escaping (_ s3Path:String?, _ scaledImage:UIImage?, Error?)->Void) {
        let scaledImage = UtilityFunctions.resizeToVgg(image: imageToScaleAndUpload)
        AWSClientFunctions.uploadData(data: scaledImage.pngData()! , fileName: "\(filename).png") { (filePath, error) in
            if let error = error {
                print( "error uploading file\(error.localizedDescription)")
                completion(nil,nil,error)
            } else {
                print("upload successful confirmation n ResultViewController at \(String(describing: filePath))")
                completion(filePath,scaledImage, nil)
            }
        }
    }
}







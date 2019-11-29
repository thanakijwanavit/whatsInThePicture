//
//  AppDelegate.swift
//  whats in the picture
//
//  Created by nic Wanavit on 11/23/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import UIKit
import CoreData
import AWSAppSync
import AWSMobileClient
import AWSS3

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var appSyncClient: AWSAppSyncClient?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            // You can choose the directory in which AppSync stores its persistent cache databases
            let cacheConfiguration = try AWSAppSyncCacheConfiguration()

            // AppSync configuration & client initialization
            let appSyncServiceConfig = try AWSAppSyncServiceConfig()
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: appSyncServiceConfig,
                                                                  cacheConfiguration: cacheConfiguration)
            appSyncClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
            
            print("Initialized appsync client.")
        } catch {
            print("Error initializing appsync client. \(error)")
        }
        // other methods
        
        
        //init mobileClient
        
        AWSMobileClient.default().initialize { (userState, error) in
                        if let error = error {
                            debugPrint("Error initializing AWSMobileClient: \(error.localizedDescription)")
                        } else if userState != nil {
                            debugPrint("initialization successful and user is \(userState.debugDescription)")

                        }
            AWSMobileClient.default().getTokens { (tokens, error) in
                if let error = error {
                    print("Error getting token \(error.localizedDescription)")
                } else if let tokens = tokens {
                    print("OITC token is " + tokens.accessToken!.tokenString!)
                }
            }
            AWSMobileClient.default().getAWSCredentials { (credentials, error) in
                if let error = error {
                    print("\(error.localizedDescription)")
                } else if let credentials = credentials {
                    print("aws token is" + credentials.accessKey)
                }
            }
        }
        
        
        //// s3 client initiation
        
        //Setup credentials, see your awsconfiguration.json for the "YOUR-IDENTITY-POOL-ID"
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .APSoutheast1, identityPoolId: "ap-southeast-1:e5b58448-20eb-40fc-8777-0816a6a8068e")

        //Setup the service configuration
        let configuration = AWSServiceConfiguration(region: .APSoutheast1, credentialsProvider: credentialProvider)

        //Setup the transfer utility configuration
        let tuConf = AWSS3TransferUtilityConfiguration()
        tuConf.isAccelerateModeEnabled = false

        //Register a transfer utility object asynchronously
        AWSS3TransferUtility.register(
            with: configuration!,
            transferUtilityConfiguration: tuConf,
            forKey: "transfer-utility-with-advanced-options"
        ) { (error) in
             if let error = error {
                 //Handle registration error.
             }
        }
        
        
        
        return true
    }
    
    

}


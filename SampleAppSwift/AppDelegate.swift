//
//  AppDelegate.swift
//  SampleAppSwift
//
//  Created by Felix Lamouroux on 14.06.17.
//  Copyright © 2017 iosphere. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Set your ingestion key, host and app name
        // best to use hyphens instead of dots in app and hostname
        ISHLogDNAService.setup(withIngestionKey: "...", hostName: "sample-app", appName: "swift")

        let message = ISHLogDNAMessage(line: "Sample app started", level: .error, meta: [ "myField" : 42 ])
        ISHLogDNAService.logMessages([message]);
        return true
    }

}


//
//  AppDelegate.m
//  ISHLogDNA
//
//  Created by Felix Lamouroux on 13.06.17.
//  Copyright © 2017 iosphere. All rights reserved.
//

#import "AppDelegate.h"
#import "ISHLogDNAService.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /********* SETUP YOUR API KEY, HOST AND APPNAME *********/
    NSString *ingestionKey = @"...";
    // best to use hyphens instead of dots in app and hostname
    NSString *hostName = @"sample-app";
    NSString *appName = @"obj-c";
    /********* SETUP YOUR API KEY, HOST AND APPNAME *********/

    [ISHLogDNAService setupWithIngestionKey:ingestionKey
                                   hostName:hostName
                                    appName:appName];

    // Send message including custom meta data (the dictionary must be encodable into JSON)
    ISHLogDNAMessage *message = [ISHLogDNAMessage messageWithLine:@"Sample app started" level:ISHLogDNALevelInfo meta:@{@"anyKey" : @[@1, @42]}];
    [ISHLogDNAService logMessages:@[message]];
    return YES;
}

@end

//
//  AppDelegate.m
//  ISHLogDna
//
//  Created by Felix Lamouroux on 13.06.17.
//  Copyright © 2017 iosphere. All rights reserved.
//

#import "AppDelegate.h"
#import "ISHLogDnaService.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /********* SETUP YOUR API KEY, HOST AND APPNAME *********/
    NSString *ingestionKey = @"...";
    // best to use hyphens instead of dots in app and hostname
    NSString *hostName = @"sample-app";
    NSString *appName = @"obj-c";
    /********* SETUP YOUR API KEY, HOST AND APPNAME *********/

    [ISHLogDnaService setupWithIngestionKey:ingestionKey
                                   hostName:hostName
                                    appName:appName];

    // Send message including custom meta data (the dictionary must be encodable into JSON)
    ISHLogDnaMessage *message = [ISHLogDnaMessage messageWithLine:@"Sample app started" level:ISHLogDnaLevelInfo meta:@{@"anyKey" : @[@1, @42]}];
    [ISHLogDnaService logMessages:@[message]];
    return YES;
}

@end

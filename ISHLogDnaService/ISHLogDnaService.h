//
//  ISHLogDnaService.h
//  ISHLogDna
//
//  Created by Felix Lamouroux on 13.06.17.
//  Copyright © 2017 iosphere. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ISHLogDnaLevelDebug,
    ISHLogDnaLevelInfo,
    ISHLogDnaLevelWarn,
    ISHLogDnaLevelError,
    ISHLogDnaLevelFatal
} ISHLogDnaLevel;

/**
 * A log message can be sent to logdna via the ISHLogDnaService.
 */
@interface ISHLogDnaMessage : NSObject

/**
 * Create messages using this constructor.
 *
 * @param line The message line should not be empty.
 * @param level The log level of this message.
 * @param meta The meta field must be encodable into JSON using NSJSONSerialization.
 */
+ (instancetype)messageWithLine:(NSString *)line level:(ISHLogDnaLevel)level meta:(nullable NSDictionary *)meta;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

/**
 * This service provides remote logging methods via LogDna.
 *
 * Make sure to call +[ISHLogDnaService setupWithIngestionKey:hostName:appName:]
 * before using any logging methods.
 */
@interface ISHLogDnaService : NSObject

/// Setup the ISHLogDnaService. Must be called before logging any messages.
+ (instancetype)setupWithIngestionKey:(NSString *)key
                             hostName:(NSString *)host
                              appName:(NSString *)appName;

/// Sends an array of log messages to logdna. Make sure to setup the service before calling this method.
+ (void)logMessages:(NSArray<ISHLogDnaMessage *> *)messages;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END

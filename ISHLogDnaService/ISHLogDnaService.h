//
//  ISHLogDnaService.h
//  ISHLogDna
//
//  Created by Felix Lamouroux on 13.06.17.
//  Copyright © 2017 iosphere. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ISHLogDnaLevel) {
    ISHLogDnaLevelDebug,
    ISHLogDnaLevelInfo,
    ISHLogDnaLevelWarn,
    ISHLogDnaLevelError,
    ISHLogDnaLevelFatal
};

/**
 * A log message can be sent to logdna via the ISHLogDnaService.
 */
@interface ISHLogDnaMessage : NSObject

/**
 * Create messages using this constructor.
 *
 * @param line The message line should not be empty.
 * @param level The log level of this message.
 * @param meta The optional meta field must be encodable into JSON using NSJSONSerialization.
 *
 * @return An immutable timestamped message to be logged via the ISHLogDnaService.
 *
 * @note You have to provide a consistent type per key across all messages' meta fields.
 *       If inconsistent value types are used, that line's metadata, will not be parsed. 
 *       For example, if a line is passed with a meta object, such as meta.myfield of type 
 *       String, any subsequent lines with meta.myfield must have a String as the value type 
 *       for meta.myfield.
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

/**
 * Log messages are only sent to the server if the service enabled and will silently be ignored otherwise.
 * The default value is set to the user's advertising preferences.
 */
@property (class, nonatomic) BOOL enabled;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END

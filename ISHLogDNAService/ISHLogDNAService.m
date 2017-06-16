//
//  ISHLogDNAService.m
//  ISHLogDNA
//
//  Created by Felix Lamouroux on 13.06.17.
//  Copyright © 2017 iosphere. All rights reserved.
//

#import "ISHLogDNAService.h"

#if TARGET_OS_IOS || TARGET_OS_TV
@import AdSupport;
#endif

NSString * const ISHLogDNAServiceKeyErrorDescription = @"errorDescription";
NSString * const ISHLogDNAServiceKeyErrorCode = @"errorCode";
NSString * const ISHLogDNAServiceKeyErrorDomain = @"errorDomain";

NSString *NSStringFromLogDNALevel(ISHLogDNALevel level) {
    switch (level) {
        case ISHLogDNALevelDebug:
            return @"DEBUG";

        case ISHLogDNALevelInfo:
            return @"INFO";

        case ISHLogDNALevelWarn:
            return @"WARN";

        case ISHLogDNALevelError:
            return @"ERROR";

        case ISHLogDNALevelFatal:
            return @"FATAL";
    }

    NSCAssert(NO, @"Invalid log level: %@", @(level));
    return @"DEBUG";
}

#pragma mark - Message

@interface ISHLogDNAMessage ()
@property (nonatomic) NSString *line;
@property (nonatomic) NSDate *timestamp;
@property (nonatomic) NSDictionary *meta;
@property (nonatomic) ISHLogDNALevel level;
@end

@implementation ISHLogDNAMessage : NSObject

+ (instancetype)messageWithLine:(NSString *)line level:(ISHLogDNALevel)level meta:(nullable NSDictionary *)meta {
    NSParameterAssert(line.length);

    ISHLogDNAMessage *msg = [[self alloc] init];
    [msg setLevel:level];
    [msg setMeta:meta];
    [msg setLine:line];
    [msg setTimestamp:[NSDate date]];

    return msg;
}

+ (NSDictionary<NSString *,id> *)metaDictionaryWithError:(NSError *)error {
    if (!error) {
        return @{};
    }

    NSMutableDictionary *errorDict = [NSMutableDictionary dictionaryWithObject:@(error.code) forKey:ISHLogDNAServiceKeyErrorCode];

    if (error.domain.length) {
        [errorDict setObject:error.domain forKey:ISHLogDNAServiceKeyErrorDomain];
    }

    if (error.description.length) {
        [errorDict setObject:error.description forKey:ISHLogDNAServiceKeyErrorDescription];
    }

    return [errorDict copy];
}

- (NSMutableDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (!self.line) {
        return dict;
    }

    dict[@"line"] = self.line;
    dict[@"level"] = NSStringFromLogDNALevel(self.level);

    if (self.timestamp) {
        dict[@"timestamp"] = @([self.timestamp timeIntervalSince1970]);
    }

    if (self.meta) {
        dict[@"meta"] = self.meta;
    }

    return dict;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", [super description], [[self dictionaryRepresentation] description]];
}

@end

#pragma mark - Service

@interface ISHLogDNAService ()
@property (nonatomic) BOOL enabled;
@property (nonatomic) NSString *ingestionKey;
@property (nonatomic) NSString *hostName;
@property (nonatomic) NSString *appName;
@end

@implementation ISHLogDNAService

+ (instancetype)sharedInstance {
    static ISHLogDNAService *sharedInstance = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
        
#if TARGET_OS_IOS || TARGET_OS_TV
        sharedInstance.enabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
#endif
    });

    return sharedInstance;
}

+ (instancetype)setupWithIngestionKey:(NSString *)key
                             hostName:(NSString *)host
                              appName:(NSString *)appName {
    NSParameterAssert(key.length);
    NSParameterAssert(host.length);
    NSParameterAssert(appName.length);

    ISHLogDNAService *sharedInstance = [self sharedInstance];
    [sharedInstance setIngestionKey:key];
    [sharedInstance setHostName:host];
    [sharedInstance setAppName:appName];

    return sharedInstance;
}

+ (BOOL)enabled {
    return [[self sharedInstance] enabled];
}

+ (void)setEnabled:(BOOL)enabled {
    [[self sharedInstance] setEnabled:enabled];
}

- (NSURL *)baseUrl {
    NSString *url = [NSString stringWithFormat:@"https://logs.logdna.com/logs/ingest?hostname=%@&now=%@", self.hostName, @([[NSDate date] timeIntervalSince1970])];

    return [NSURL URLWithString:url];
}

+ (void)logMessages:(NSArray<ISHLogDNAMessage *> *)messages {
    NSParameterAssert([[self sharedInstance] ingestionKey]);
    [[self sharedInstance] logMessages:messages];
}

- (void)logMessages:(NSArray<ISHLogDNAMessage *> *)messages {
    NSParameterAssert(messages);

    if (!self.enabled || !messages.count) {
        return;
    }

    NSMutableArray<NSDictionary *> *messagesAsDictionaries = [NSMutableArray arrayWithCapacity:messages.count];

    for (ISHLogDNAMessage *message in messages) {
        NSMutableDictionary *dictMessage = [message dictionaryRepresentation];
        NSAssert(dictMessage.count, @"Dictionary should at least include line and level: %@ -> %@", message, dictMessage);

        if (!dictMessage.count) {
            continue;
        }

        dictMessage[@"app"] = self.appName;
        [messagesAsDictionaries addObject:dictMessage];
    }

    NSDictionary<NSString *, NSArray<NSDictionary *> *> *boxedMessages = @{@"lines" : messagesAsDictionaries};
    NSError *encodingError;
    NSData *encodedMessages = [NSJSONSerialization dataWithJSONObject:boxedMessages options:kNilOptions error:&encodingError];

    if (encodingError) {
        NSLog(@"Could not encode log message: %@, error: %@", boxedMessages, encodingError);
        return;
    }

    NSURL *url = [self baseUrl];
    NSParameterAssert(url);

    if (!url) {
        NSLog(@"Failed to create base URL. Invalid host? %@", self.hostName);
        return;
    }

    // configure request header
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];

    // set auth header with ingestionKey
    NSString *ingestionKeyAuth = [NSString stringWithFormat:@"%@:", self.ingestionKey];
    NSString *authString = [@"Basic " stringByAppendingFormat:@"%@", [[ingestionKeyAuth dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]];
    [request setValue:authString forHTTPHeaderField:@"Authorization"];

    // set body to encoded boxed messages json
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:encodedMessages];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
                return;
            }

            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

            if (httpResponse.statusCode != 200) {
                NSLog(@"Failed to log message (statuscode %@): %@\n%@", @(httpResponse.statusCode), url, messagesAsDictionaries);
            }
        }];

    [task resume];
}

@end

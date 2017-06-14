//
//  ISHLogDnaService.m
//  ISHLogDna
//
//  Created by Felix Lamouroux on 13.06.17.
//  Copyright © 2017 iosphere. All rights reserved.
//

#import "ISHLogDnaService.h"
@import AdSupport;

NSString *NSStringFromLogDnaLevel(ISHLogDnaLevel level) {
    switch (level) {
        case ISHLogDnaLevelDebug:
            return @"DEBUG";

        case ISHLogDnaLevelInfo:
            return @"INFO";

        case ISHLogDnaLevelWarn:
            return @"WARN";

        case ISHLogDnaLevelError:
            return @"ERROR";

        case ISHLogDnaLevelFatal:
            return @"FATAL";
    }

    return @"DEBUG";
}

@interface ISHLogDnaMessage ()
@property (nonatomic) NSString *line;
@property (nonatomic) NSDate *timestamp;
@property (nonatomic) NSDictionary *meta;
@property (nonatomic) ISHLogDnaLevel level;
- (instancetype)init NS_AVAILABLE(10.0, 2.0);

@end

@implementation ISHLogDnaMessage : NSObject

+ (instancetype)messageWithLine:(NSString *)line level:(ISHLogDnaLevel)level meta:(nullable NSDictionary *)meta {
    NSParameterAssert(line.length);

    if (!line) {
        return nil;
    }

    ISHLogDnaMessage *msg = [[[self class] alloc] init];
    [msg setLevel:level];
    [msg setMeta:meta];
    [msg setLine:line];
    [msg setTimestamp:[NSDate date]];
    return msg;
}

- (NSMutableDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    dict[@"line"] = self.line;
    dict[@"level"] = NSStringFromLogDnaLevel(self.level);

    if (self.timestamp) {
        dict[@"timestamp"] = @([self.timestamp timeIntervalSince1970]);
    }

    if (self.meta) {
        dict[@"meta"] = self.meta;
    }

    return dict;
}

@end

@interface ISHLogDnaService ()
@property (nonatomic) BOOL enabled;
@property (nonatomic) NSString *ingestionKey;
@property (nonatomic) NSString *hostName;
@property (nonatomic) NSString *appName;
@property (nonatomic, nonnull) NSURLSession *urlSession;
- (instancetype)init NS_AVAILABLE(10.0, 2.0);

@end

@implementation ISHLogDnaService

+ (instancetype)sharedInstance {
    static ISHLogDnaService *sharedInstance = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        sharedInstance = [[[self class] alloc] init];
        sharedInstance.enabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    });

    return sharedInstance;
}

+ (instancetype)setupWithIngestionKey:(NSString *)key
                             hostName:(NSString *)host
                              appName:(NSString *)appName {
    NSParameterAssert(key.length);
    NSParameterAssert(host.length);
    NSParameterAssert(appName.length);

    ISHLogDnaService *sharedInstance = [self sharedInstance];
    [sharedInstance setIngestionKey:key];
    [sharedInstance setHostName:host];
    [sharedInstance setAppName:appName];
    [sharedInstance setUrlSession:[NSURLSession sharedSession]];
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

+ (void)logMessages:(NSArray<ISHLogDnaMessage *> *)messages {
    NSParameterAssert([[self sharedInstance] ingestionKey]);
    [[self sharedInstance] logMessages:messages];
}

- (void)logMessages:(NSArray<ISHLogDnaMessage *> *)messages {
    NSParameterAssert(messages);

    if (!messages.count) {
        return;
    }

    if (!self.enabled) {
        return;
    }

    NSMutableArray *messagesAsDictionaries = [NSMutableArray arrayWithCapacity:messages.count];

    for (ISHLogDnaMessage *message in messages) {
        NSMutableDictionary *dictMesage = [message dictionaryRepresentation];
        dictMesage[@"app"] = self.appName;
        [messagesAsDictionaries addObject:dictMesage];
    }

    NSDictionary *boxedMessages = @{@"lines" : messagesAsDictionaries};
    NSError *encodingError;
    NSData *encodedMessages = [NSJSONSerialization dataWithJSONObject:boxedMessages options:0 error:&encodingError];

    if (encodingError) {
        NSLog(@"Could not encode log message: %@, error: %@", boxedMessages, encodingError);
        return;
    }

    NSURL *url = [self baseUrl];

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

    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
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

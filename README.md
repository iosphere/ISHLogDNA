# [LogDNA](https://logdna.com) for iOS

This micro-framework supports remote logging via [LogDNA](https://logdna.com) on
iOS. The framework itself is written in ObjC for easy integration in Swift and
ObjC apps.

## Sample

### Objective-C

```obj-c
[ISHLogDNAService setupWithIngestionKey:ingestionKey
                               hostName:hostName
                                appName:appName];

// Send message including custom meta data (the dictionary must be encodable into JSON)
ISHLogDNAMessage *m;
m = [ISHLogDNAMessage messageWithLine:@"Sample app started"
                                level:ISHLogDNALevelInfo
                                 meta:@{@"anyKey" : @[@1, @42]}];
[ISHLogDNAService logMessages:@[m]];
```

### Swift

```swift
ISHLogDNAService.setup(withIngestionKey: "", hostName: "", appName: "")

let message = ISHLogDNAMessage(line: "Sample app started", level: .info, meta: [ "myField" : 42 ])
ISHLogDNAService.logMessages([message]);
```

## Usage

Simply include the following files in your project:

* `ISHLogDNAService.h`
* `ISHLogDNAService.m`

For Swift: ensure to include `#import "ISHLogDnaService.h"`
in your bridging header.

`ISHLogDNAService` uses the [AdSupport framework](https://developer.apple.com/documentation/adsupport)
to use a sensible default for the enabled flag. By default logging is only
enabled for users with `isAdvertisingTrackingEnabled`.

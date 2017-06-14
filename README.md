# [LogDNA](https://logdna.com) for iOS

This micro-framework supports remote logging via [LogDNA](https://logdna.com) on
iOS. The framework itself is written in ObjC for easy integration in Swift and
ObjC apps.

## Sample

```obj-c
[ISHLogDnaService setupWithIngestionKey:ingestionKey
                               hostName:hostName
                                appName:appName];

// Send message including custom meta data (the dictionary must be encodable into JSON)
ISHLogDnaMessage *m;
m =[ISHLogDnaMessage messageWithLine:@"Sample app started"
                               level:ISHLogDnaLevelInfo
                                meta:@{@"anyKey" : @[@1, @42]}];
[ISHLogDnaService logMessages:@[m]];
```

```swift
ISHLogDnaService.setup(withIngestionKey: "", hostName: "", appName: "")

let message = ISHLogDnaMessage(line: "Sample app started", level: .info, meta: [ "myField" : 42 ])
ISHLogDnaService.logMessages([message]);
```

## Usage

Simply include the following files in your project:

* `ISHLogDnaService.h`
* `ISHLogDnaService.m`

For Swift: ensure to include `#import "ISHLogDnaService.h"`
in your bridging header.

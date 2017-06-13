# [logdna](https://logdna.com) for iOS

This micro-framework supports remote logging via [logdna](https://logdna.com) on
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

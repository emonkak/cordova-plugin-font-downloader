#import "CDVFontDownloader.h"
#import <Cordova/CDVViewController.h>
#import <Cordova/NSDictionary+CordovaPreferences.h>
#import <CoreText/CoreText.h>

@implementation CDVFontDownloader

- (void)download:(CDVInvokedUrlCommand*)command
{
    NSString *fontName = [command argumentAtIndex:0];
    NSDictionary *attributes = @{(id)kCTFontNameAttribute: fontName};
    CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attributes);
    NSArray *fontDescriptors = @[(__bridge id)fontDescriptor];

    CFRelease(fontDescriptor);

    CTFontDescriptorMatchFontDescriptorsWithProgressHandler((__bridge CFArrayRef)fontDescriptors, NULL, ^bool(CTFontDescriptorMatchingState state, CFDictionaryRef progressParameter) {
        CDVPluginResult *pluginResult;

        switch (state) {
            case kCTFontDescriptorMatchingDidBegin:
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                             messageAsDictionary:@{@"type": @"begin", @"fontName": fontName}];
                [pluginResult setKeepCallbackAsBool:YES];
                break;

            case kCTFontDescriptorMatchingDidFailWithError: {
                NSDictionary *params = (__bridge NSDictionary *)progressParameter;
                NSError *error = params[(id)kCTFontDescriptorMatchingError];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                             messageAsDictionary:@{@"type": @"fail", @"fontName": fontName, @"error": error.localizedDescription}];
                break;
            }

            case kCTFontDescriptorMatchingDidFinish:
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                             messageAsDictionary:@{@"type": @"finish", @"fontName": fontName}];
                break;

            case kCTFontDescriptorMatchingDidFinishDownloading:
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                             messageAsDictionary:@{@"type": @"finishdownloading", @"fontName": fontName, @"progress": @1.0}];
                [pluginResult setKeepCallbackAsBool:YES];
                break;

            case kCTFontDescriptorMatchingDidMatch: {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                             messageAsDictionary:@{@"type": @"match", @"fontName": fontName}];
                [pluginResult setKeepCallbackAsBool:YES];
                break;
            }

            case kCTFontDescriptorMatchingDownloading: {
                NSDictionary *params = (__bridge NSDictionary *)progressParameter;
                double progress = [params[(id)kCTFontDescriptorMatchingPercentage] doubleValue];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                             messageAsDictionary:@{@"type": @"downloading", @"fontName": fontName, @"progress": @(progress)}];
                [pluginResult setKeepCallbackAsBool:YES];
                break;
            }

            case kCTFontDescriptorMatchingStalled:
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                             messageAsDictionary:@{@"type": @"stalled", @"fontName": fontName}];
                [pluginResult setKeepCallbackAsBool:YES];
                break;

            case kCTFontDescriptorMatchingWillBeginDownloading:
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                             messageAsDictionary:@{@"type": @"begindownloading", @"fontName": fontName, @"progress": @0.0}];
                [pluginResult setKeepCallbackAsBool:YES];
                break;

            case kCTFontDescriptorMatchingWillBeginQuerying:
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                             messageAsDictionary:@{@"type": @"beginquerying", @"fontName": fontName}];
                [pluginResult setKeepCallbackAsBool:YES];
                break;

            default:
                // Not come here
                return NO;
        }

        [self.commandDelegate sendPluginResult:pluginResult
                                    callbackId:command.callbackId];

        return YES;
    });
}

@end

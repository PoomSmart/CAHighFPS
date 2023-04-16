#define CHECK_TARGET

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <PSHeader/PS.h>

#define key CFSTR("CAHighFPS")
#define domain CFSTR("com.apple.UIKit")

@interface CAMetalLayer (Private)
@property (assign) CGFloat drawableTimeoutSeconds;
@end

static NSInteger maxFPS = -1;

static NSInteger getMaxFPS() {
    if (maxFPS == -1)
        maxFPS = [UIScreen mainScreen].maximumFramesPerSecond;
    return maxFPS;
} 

static BOOL shouldEnableForBundleIdentifier(NSString *bundleIdentifier) {
    const void *value = CFPreferencesCopyAppValue(key, domain);
    if (value == NULL)
        value = CFPreferencesCopyValue(key, domain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    NSArray <NSString *> *nsValue = (__bridge NSArray <NSString *> *)value;
    return [nsValue containsObject:bundleIdentifier];
}

#pragma mark - CADisplayLink

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"

%hook CADisplayLink

- (void)setFrameInterval:(NSInteger)interval {
    %orig(1);
    if ([self respondsToSelector:@selector(setPreferredFramesPerSecond:)])
        self.preferredFramesPerSecond = 0;
}

- (void)setPreferredFramesPerSecond:(NSInteger)fps {
    %orig(0);
}

- (void)setPreferredFrameRateRange:(CAFrameRateRange)range {
    CGFloat max = getMaxFPS();
    range.minimum = 30;
    range.preferred = max;
    range.maximum = max;
    %orig;
}

%end

#pragma clang diagnostic pop

#pragma mark - CAMetalLayer

%hook CAMetalLayer

- (NSUInteger)maximumDrawableCount {
    return 2;
}

- (void)setMaximumDrawableCount:(NSUInteger)count {
    %orig(2);
}

%end

#pragma mark - Metal Advanced Hack

%hook CAMetalDrawable

- (void)presentAfterMinimumDuration:(CFTimeInterval)duration {
	%orig(1.0 / getMaxFPS());
}

%end

%hook MTLCommandBuffer

- (void)presentDrawable:(id)drawable afterMinimumDuration:(CFTimeInterval)minimumDuration {
    %orig(drawable, 1.0 / getMaxFPS());
}

%end

// #pragma mark - UIKit

// BOOL (*_UIUpdateCycleSchedulerEnabled)(void);

// %group UIKit

// %hookf(BOOL, _UIUpdateCycleSchedulerEnabled) {
//     return YES;
// }

// %end

%ctor {
    if (isTarget(TargetTypeApps) && shouldEnableForBundleIdentifier(NSBundle.mainBundle.bundleIdentifier)) {
        // if (IS_IOS_OR_NEWER(iOS_15_0)) { // iOS 15.0 only?
        //     MSImageRef ref = MSGetImageByName("/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore");
        //     _UIUpdateCycleSchedulerEnabled = (BOOL (*)(void))MSFindSymbol(ref, "__UIUpdateCycleSchedulerEnabled");
        //     if (_UIUpdateCycleSchedulerEnabled) {
        //         %init(UIKit);
        //     }
        // }
        %init;
    }
}
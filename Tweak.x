#define tweakIdentifier @"com.ps.coreanimationhighfps"
#define CHECK_TARGET

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <HBLog.h>
#import "../PS.h"
#import "../PSPrefs/PSPrefs.x"

@interface CAMetalLayer (Private)
@property (assign) CGFloat drawableTimeoutSeconds;
@end

static BOOL shouldEnableForBundleIdentifier(NSString *bundleIdentifier) {
    NSArray <NSString *> *value = Prefs()[@"CAHighFPS"];
    return [value containsObject:bundleIdentifier];
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
    CGFloat max = [UIScreen mainScreen].maximumFramesPerSecond;
    range.minimum = 30;
    range.preferred = max;
    range.maximum = max;
    %orig;
}

%end

#pragma clang diagnostic pop

#pragma mark - CAMetalLayer

%hook CAMetalLayer

- (id)init {
    self = %orig;
    if (@available(iOS 11.0, *)) {
        self.allowsNextDrawableTimeout = NO;
        if ([self respondsToSelector:@selector(setDrawableTimeoutSeconds:)])
            self.drawableTimeoutSeconds = 0;
    }
    return self;
}

- (CGFloat)drawableTimeoutSeconds {
    return 0;
}

- (void)setDrawableTimeoutSeconds:(CGFloat)seconds {
    %orig(0);
}

- (BOOL)allowsNextDrawableTimeout {
    return NO;
}

- (void)setAllowsNextDrawableTimeout:(BOOL)allowed {
    %orig(NO);
}

%end

// #pragma mark - Metal Advanced Hack

// %hook MTLCommandBuffer

// - (void)presentDrawable:(id)drawable afterMinimumDuration:(CFTimeInterval)minimumDuration {
//     %orig(drawable, 1.0 / 120);
// }

// %end

#pragma mark - 60Hz APT

%group APT

bool *CADevicePrefers60HzAPT;
void (*CADevicePrefers60HzAPT_block_invoke)(void);
%hookf(void, CADevicePrefers60HzAPT_block_invoke) {
    *CADevicePrefers60HzAPT = false;
}

%end

%ctor {
    if (isTarget(TargetTypeApps) && shouldEnableForBundleIdentifier(NSBundle.mainBundle.bundleIdentifier)) {
        if (IS_IOS_OR_NEWER(iOS_15_0)) {
            MSImageRef ref = MSGetImageByName("/System/Library/Frameworks/QuartzCore.framework/QuartzCore");
            CADevicePrefers60HzAPT_block_invoke = (void (*)(void))MSFindSymbol(ref, "___CADevicePrefers60HzAPT_block_invoke");
            CADevicePrefers60HzAPT = (bool *)MSFindSymbol(ref, "__ZZ22CADevicePrefers60HzAPTE1b");
            HBLogDebug(@"CAHighFPS symbols found: %d %d", CADevicePrefers60HzAPT_block_invoke != NULL, CADevicePrefers60HzAPT != NULL);
            %init(APT);
        }
        %init;
    }
}
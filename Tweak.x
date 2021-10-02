#define tweakIdentifier @"com.ps.coreanimationhighfps"
#define CHECK_TARGET

#import "../PS.h"
#import "../PSPrefs/PSPrefs.x"

static BOOL shouldEnableForBundleIdentifier(NSString *bundleIdentifier) {
    NSDictionary *preferences = Prefs();
    NSArray <NSString *> *value = preferences[@"CAHighFPS"];
    return [value containsObject:bundleIdentifier];
}

%hook CADisplayLink

- (void)setFrameInterval:(NSInteger)interval {
    %orig(1);
    if ([self respondsToSelector:@selector(setPreferredFramesPerSecond:)])
        self.preferredFramesPerSecond = 0;
}

%end

%ctor {
    if (isTarget(TargetTypeApps) && shouldEnableForBundleIdentifier(NSBundle.mainBundle.bundleIdentifier)) {
        %init;
    }
}
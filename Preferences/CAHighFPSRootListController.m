#import "CAHighFPSRootListController.h"

@implementation CAHighFPSRootListController

- (NSArray *)specifiers {
    if (!_specifiers)
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    return _specifiers;
}

@end

//
//  GromorePopAd.h
//  gromore
//
//  Created by tian on 2023/8/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GromorePopAd : NSObject

+ (instancetype)sharedInstance;
- (void)showAd:(NSDictionary *)arguments;

@end

NS_ASSUME_NONNULL_END

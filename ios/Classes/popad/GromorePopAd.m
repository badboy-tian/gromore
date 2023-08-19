//
//  GromorePopAd.m
//  gromore
//
//  Created by tian on 2023/8/19.
//

#import "GromorePopAd.h"
#import "BUAdSDK/BUAdSDK.h"
#import "ABUUIViewController+getCurrentVC.h"
#import "GroLogUtil.h"
#import "GromoreEvent.h"
#import "MJExtension.h"

@interface GromorePopAd()<BUNativeExpressFullscreenVideoAdDelegate>

@property(nonatomic,strong) BUNativeExpressFullscreenVideoAd *reward;
@property(nonatomic,strong) NSString *codeId;

@end

@implementation GromorePopAd

+ (instancetype)sharedInstance{
    static GromorePopAd *myInstance = nil;
    if(myInstance == nil){
        myInstance = [[GromorePopAd alloc]init];
    }
    return myInstance;
}

//预加载激励广告
-(void)showAd:(NSDictionary*)arguments{
    NSDictionary *dic = arguments;
    self.codeId = dic[@"iosId"];
    
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    slot.ID = self.codeId;
    slot.mediation.mutedIfCan = YES;
    
    // gdt和穿山甲激励服务端校验需要赋值ABURewardedVideoModel
    BUNativeExpressFullscreenVideoAd *reward = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlot:slot];
    self.reward = reward;
    self.reward.delegate = self;
    //self.reward.mutedIfCan = true;
    [self.reward loadAdData];
}

#pragma mark - BUNativeExpressFullscreenVideoAdDelegate

- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd {
    [[GroLogUtil sharedInstance] print:@"POP广告加载成功"];
    NSDictionary *dictionary = @{@"adType":@"interactAd",@"onAdMethod":@"onReady"};
    [[GromoreEvent sharedInstance] sentEvent:dictionary];
    [self.reward showAdFromRootViewController:[UIViewController jsd_getCurrentViewController]];
}

- (void)nativeExpressRewardedVideoAd:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [[GroLogUtil sharedInstance] print:@"激励广告加载失败"];
    NSInteger code = error.code;
    NSString *message = error.userInfo.description;
    NSDictionary *dictionary = @{@"adType":@"interactAd",@"onAdMethod":@"onFail",@"code":@(code),@"message":message};
    [[GromoreEvent sharedInstance] sentEvent:dictionary];
}

- (void)nativeExpressFullscreenVideoAdDidDownLoadVideo:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd {
    [[GroLogUtil sharedInstance] print:@"popAd广告缓存(视频)成功"];
}

- (void)nativeExpressFullscreenVideoAdDidVisible:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd error:(NSError *)error {
    [[GroLogUtil sharedInstance] print:@"popAd广告nativeExpressFullscreenVideoAdDidVisible"];
    NSDictionary *dictionary = @{@"adType":@"interactAd",@"onAdMethod":@"onShow"};
    [[GromoreEvent sharedInstance] sentEvent:dictionary];
}

- (void)nativeExpressFullscreenVideoAdViewRenderSuccess:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd {
    [[GroLogUtil sharedInstance] print:@"popAd广告nativeExpressFullscreenVideoAdViewRenderSuccess"];
    NSDictionary *dictionary = @{@"adType":@"interactAd",@"onAdMethod":@"onShow"};
    [[GromoreEvent sharedInstance] sentEvent:dictionary];
}

- (void)nativeExpressFullscreenVideoAdDidClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [[GroLogUtil sharedInstance] print:@"popAd广告nativeExpressFullscreenVideoAdDidClose"];
    NSDictionary *dictionary = @{@"adType":@"interactAd",@"onAdMethod":@"onClose"};
    [[GromoreEvent sharedInstance] sentEvent:dictionary];
}

- (void)nativeExpressFullscreenVideoAdDidCloseOtherController:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd interactionType:(BUInteractionType)interactionType {
    [[GroLogUtil sharedInstance] print:@"popAd广告nativeExpressFullscreenVideoAdDidCloseOtherController"];
    NSDictionary *dictionary = @{@"adType":@"interactAd",@"onAdMethod":@"onClose"};
    [[GromoreEvent sharedInstance] sentEvent:dictionary];
}

@end

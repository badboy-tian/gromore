//
//  GromoreRewardAd.m
//  gromore
//
//  Created by gstory on 2022/8/10.
//

#import "GromoreRewardAd.h"
#import "BUAdSDK/BUAdSDK.h"
#import "ABUUIViewController+getCurrentVC.h"
#import "GroLogUtil.h"
#import "GromoreEvent.h"
#import "MJExtension.h"

@interface GromoreRewardAd()<BUMNativeExpressRewardedVideoAdDelegate>

@property(nonatomic,strong) BUNativeExpressRewardedVideoAd *reward;
@property(nonatomic,strong) NSString *codeId;
@property(nonatomic,strong) NSString *rewardName;
@property(nonatomic,assign) NSInteger rewardAmount;
@property(nonatomic,strong) NSString *userId;
@property(nonatomic,strong) NSString *extra;

@end

@implementation GromoreRewardAd

+ (instancetype)sharedInstance{
    static GromoreRewardAd *myInstance = nil;
    if(myInstance == nil){
        myInstance = [[GromoreRewardAd alloc]init];
    }
    return myInstance;
}

//预加载激励广告
-(void)initAd:(NSDictionary*)arguments{
    NSDictionary *dic = arguments;
    self.codeId = dic[@"iosId"];
    self.rewardName = dic[@"rewardName"];
    self.rewardAmount = [dic[@"rewardAmount"] intValue];
    self.userId =dic[@"userID"];
    self.extra = dic[@"extra"];
    
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    slot.ID = self.codeId;
    slot.mediation.mutedIfCan = YES;
    
    // gdt和穿山甲激励服务端校验需要赋值ABURewardedVideoModel
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = self.userId;
    model.rewardName = self.rewardName;
    model.rewardAmount = self.rewardAmount;
    model.extra = self.extra;
    self.reward = [[BUNativeExpressRewardedVideoAd alloc] initWithSlot:slot rewardedVideoModel:model];
    self.reward.delegate = self;
    //self.reward.mutedIfCan = true;
    [self.reward loadAdData];
}

//展示广告
-(void)showAd{
    if(self.reward == nil){
        NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onUnReady"};
        [[GromoreEvent sharedInstance] sentEvent:dictionary];
    }else{
        if (self.reward.mediation.isReady) {
            [self.reward showAdFromRootViewController:[UIViewController jsd_getCurrentViewController]];
        }else{
            NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onFail",@"code":@(-1),@"message":@"广告不可用，请重新拉取"};
            [[GromoreEvent sharedInstance] sentEvent:dictionary];
        }
    }
}

#pragma mark - 广告请求delegate
- (void)nativeExpressRewardedVideoAdDidLoad:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [[GroLogUtil sharedInstance] print:@"激励广告加载成功"];
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onReady"};
    [[GromoreEvent sharedInstance] sentEvent:dictionary];
}

- (void)nativeExpressRewardedVideoAd:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [[GroLogUtil sharedInstance] print:@"激励广告加载失败"];
    NSInteger code = error.code;
    NSString *message = error.userInfo.description;
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onFail",@"code":@(code),@"message":message};
    [[GromoreEvent sharedInstance] sentEvent:dictionary];
}

- (void)nativeExpressRewardedVideoAdDidDownLoadVideo:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [[GroLogUtil sharedInstance] print:@"激励广告缓存(视频)成功"];
}

- (void)nativeExpressRewardedVideoAdViewRenderSuccess:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdViewRenderFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *)error {
    [[GroLogUtil sharedInstance] print:@"激励广告渲染失败"];
    NSInteger code = error.code;
    NSString *message = error.userInfo.description;
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onFail",@"code":@(code),@"message":message};
    [[GromoreEvent sharedInstance] sentEvent:dictionary];
}

- (void)nativeExpressRewardedVideoAdDidVisible:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [[GroLogUtil sharedInstance] print:@"激励广告展示成功"];
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onShow"};
    [[GromoreEvent sharedInstance] sentEvent:dictionary];
}

- (void)nativeExpressRewardedVideoAdDidShowFailed:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *)error {
    [[GroLogUtil sharedInstance] print:@"激励广告展示失败"];
    NSInteger code = error.code;
    NSString *message = error.userInfo.description;
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onFail",@"code":@(code),@"message":message};
    [[GromoreEvent sharedInstance] sentEvent:dictionary];
}

- (void)nativeExpressRewardedVideoAdDidClick:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [[GroLogUtil sharedInstance] print:@"激励广告点击"];
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onClick"};
    [[GromoreEvent sharedInstance] sentEvent:dictionary];
}

- (void)nativeExpressRewardedVideoAdDidClickSkip:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [[GroLogUtil sharedInstance] print:@"激励广告跳过"];
}

- (void)nativeExpressRewardedVideoAdDidClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [[GroLogUtil sharedInstance] print:@"激励广告关闭"];
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onClose"};
    [[GromoreEvent sharedInstance] sentEvent:dictionary];
}

// 广告奖励下发
- (void)nativeExpressRewardedVideoAdServerRewardDidSucceed:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    BURewardedVideoModel *rewardInfo = rewardedVideoAd.rewardedVideoModel;
    NSString *transId = rewardInfo.mediation.tradeId;
    if(transId == nil){
         transId = @"";
     }
    
    NSString *rewardAmount = [NSNumber numberWithInt:rewardInfo.rewardAmount];
    NSString *rewardName = rewardInfo.rewardName;
    NSString *rewardVerify = [NSNumber numberWithBool:verify];
    NSString * logs = [NSString stringWithFormat:@"激励奖励发放==>verify=%@,transId=%@,rewardAmount=%@,rewardName=%@", rewardVerify,transId,rewardAmount,rewardName];
    [[GroLogUtil sharedInstance] print:logs];
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onVerify",@"verify":rewardVerify,@"transId":transId,@"rewardAmount":rewardAmount,@"rewardName":rewardName};
    [[GromoreEvent sharedInstance] sentEvent:dictionary];
    //广告相关信息
    NSMutableDictionary *ecpmInfo = rewardedVideoAd.mediation.getShowEcpmInfo.mj_keyValues;
//    NSDictionary *adInfo = @{@"adType":@"rewardAd",@"onAdMethod":@"onAdInfo"};
    [ecpmInfo setValue:@"rewardAd" forKey:@"adType"];
    [ecpmInfo setValue:@"onAdInfo" forKey:@"onAdMethod"];
//    [ecpmInfo addEntriesFromDictionary:adInfo];
    [[GroLogUtil sharedInstance] print:ecpmInfo];
    [[GromoreEvent sharedInstance] sentEvent:ecpmInfo];
}
@end

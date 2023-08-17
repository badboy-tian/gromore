//
//  GromoreNativeAd.m
//  gromore
//
//  Created by gstory on 2022/8/11.
//

#import "GromoreNativeAd.h"
#import "BUAdSDK/BUAdSDK.h"
#import "GroLogUtil.h"
#import "ABUUIViewController+getCurrentVC.h"
#import "MJExtension.h"

#pragma mark - GromoreNativeAdFactory

@implementation GromoreNativeAdFactory{
    NSObject<FlutterBinaryMessenger>*_messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager{
    self = [super init];
    if (self) {
        _messenger = messager;
    }
    return self;
}

-(NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}

-(NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args{
    GromoreNativeAd * nativeAd = [[GromoreNativeAd alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
    return nativeAd;
}
@end

@interface GromoreNativeAd()<BUMNativeAdsManagerDelegate,BUMNativeAdDelegate>
@property (nonatomic, strong) BUNativeAdsManager *adManager;
@property(nonatomic,strong) UIView *container;
@property(nonatomic,assign) CGRect frame;
@property(nonatomic,assign) NSInteger viewId;
@property(nonatomic,strong) FlutterMethodChannel *channel;
@property(nonatomic,strong) NSString *codeId;
@property(nonatomic,assign) NSInteger width;
@property(nonatomic,assign) NSInteger height;
@end

#pragma mark - GromoreNativeAd
@implementation GromoreNativeAd

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        NSDictionary *dic = args;
        self.frame = frame;
        self.viewId = viewId;
        self.codeId = dic[@"iosId"];
        self.width =[dic[@"width"] intValue];
        self.height =[dic[@"height"] intValue];
        NSString* channelName = [NSString stringWithFormat:@"com.gstory.gromore/NativeAdView_%lld", viewId];
        self.channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        self.container = [[UIView alloc] initWithFrame:frame];
        [self loadNativeAd];
    }
    return self;
}

- (UIView*)view{
    return  self.container;
}

-(void)loadNativeAd{
    [self.container removeFromSuperview];
    if (self.adManager) {
        [self.adManager.mediation destory];
        //[self.adManager destory];
    }
    NSString *string = [NSString stringWithFormat:@"width=%d height=%d",self.width,self.height];
    [[GroLogUtil sharedInstance] print:string];
    CGSize size = CGSizeMake(self.width, self.height);
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    
    slot.adSize = CGSizeMake(self.width, self.height);
    slot.ID = self.codeId;
    //slot.getExpressAdIfCan = YES;
    // 如果是模板广告，返回高度将不一定是width，而是按照width和对应代码位在平台的配置计算出的高度
    //slot.adSize =  CGSizeMake(self.width, self.height);
    //v2700开始原生广告支持自渲染和模板类型混出，如果开发者在平台配置了对应代码位的该属性则无需设置；否则开发者需要设置getExpressAdIfCan属性来告知SDK当前广告位下配置的是否为模板类型；平台配置优先于getExpressAdIfCan设置
    //slot1.getExpressAdIfCan = YES;
    // 在getExpressAdIfCan=YES下，如果需要使用gdt express2.0，请设置useExpress2IfCanForGDT=YES;，如果开发者在平台配置了对应代码位的该属性则无需设置；否则开发者需要设置useExpress2IfCanForGDT属性来告知SDK当前广告位下配置的是否为模板2.0；平台配置优先于useExpress2IfCanForGDT设置
    //self.adManager.useExpress2IfCanForGDT = YES;
    self.adManager = [[BUNativeAdsManager alloc] initWithSlot:slot];
    self.adManager.mediation.rootViewController = [UIViewController jsd_getRootViewController];
    //self.adManager.startMutedIfCan = NO;
    self.adManager.delegate = self;
    //该逻辑用于判断配置是否拉取成功。如果拉取成功，可直接加载广告，否则需要调用setConfigSuccessCallback，传入block并在block中调用加载广告。SDK内部会在配置拉取成功后调用传入的block
    //当前配置拉取成功，直接loadAdData
    [self.adManager loadAdDataWithCount:1];
}

# pragma mark ---<BUMNativeAdsManagerDelegate>---
- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(NSArray<BUNativeAd *> *)nativeAdDataArray {
    [[GroLogUtil sharedInstance] print:@"信息流广告拉去成功"];
    //取第一条广告载入
    if([nativeAdDataArray count] > 0){
        BUNativeAd *view = nativeAdDataArray[0];
        view.rootViewController = [UIViewController jsd_getRootViewController];
        view.delegate = self;
        [view.mediation render];
    }
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(NSError *)error {
    [[GroLogUtil sharedInstance] print:@"信息流拉去失败"];
    NSInteger code = error.code;
    NSString *message = error.userInfo.description;
    NSDictionary *dictionary = @{@"code":@(code),@"message":message};
    [self.channel invokeMethod:@"onFail" arguments:dictionary result:nil];
}

# pragma mark ---<BUMNativeAdDelegate>---
- (void)nativeAdExpressViewRenderSuccess:(BUNativeAd *)nativeAd {
    [[GroLogUtil sharedInstance] print:@"信息流广告渲染成功"];
    [self.container addSubview:nativeAd.mediation.canvasView];
    NSDictionary *dictionary = @{@"width": @(nativeAd.mediation.canvasView.frame.size.width),@"height":@(nativeAd.mediation.canvasView.frame.size.height)};
    [self.channel invokeMethod:@"onShow" arguments:dictionary result:nil];
}

- (void)nativeAdExpressViewRenderFail:(BUNativeAd *)nativeAd error:(NSError *)error {
    [[GroLogUtil sharedInstance] print:@"信息流广告渲染失败"];
    NSInteger code = error.code;
    NSString *message = error.userInfo.description;
    NSDictionary *dictionary = @{@"code":@(code),@"message":message};
    [self.channel invokeMethod:@"onFail" arguments:dictionary result:nil];
}

- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd {
    NSString *str = [NSString stringWithFormat:@"信息流广告展示 %@",nativeAd.mediation.getShowEcpmInfo.mj_keyValues];
    [[GroLogUtil sharedInstance] print:str];
    [self.channel invokeMethod:@"onAdInfo" arguments:nativeAd.mediation.getShowEcpmInfo.mj_keyValues result:nil];
}

- (void)nativeAdVideoDidClick:(BUNativeAd *)nativeAd {
    [[GroLogUtil sharedInstance] print:@"信息流广告点击"];
    [self.channel invokeMethod:@"onClick" arguments:nil result:nil];
}

- (void)nativeAdWillPresentFullScreenModal:(BUNativeAd *)nativeAd {
    [[GroLogUtil sharedInstance] print:@"信息流广告全屏内容展示"];
}

- (void)nativeAdDidCloseOtherController:(BUNativeAd *)nativeAd interactionType:(BUInteractionType)interactionType {
    [[GroLogUtil sharedInstance] print:@"信息流广告不感兴趣"];
    [self.container removeFromSuperview];
    //nativeAd.mediation = nil;
    [self.channel invokeMethod:@"onClose" arguments:nil result:nil];
}

@end

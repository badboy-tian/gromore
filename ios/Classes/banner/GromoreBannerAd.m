//
//  GromoreBannerAd.m
//  gromore
//
//  Created by gstory on 2022/8/12.
//

#import "GromoreBannerAd.h"
#import "BUAdSDK/BUAdSDK.h"
#import "ABUUIViewController+getCurrentVC.h"
#import "GroLogUtil.h"
#import "MJExtension.h"

#pragma mark - GromoreNativeAdFactory

@implementation GromoreBannerAdFactory{
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
    GromoreBannerAd * bannerAd = [[GromoreBannerAd alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
    return bannerAd;
}
@end

@interface GromoreBannerAd()<BUMNativeExpressBannerViewDelegate>
@property (nonatomic, strong) BUNativeExpressBannerView *bannerAd;
@property(nonatomic,strong) UIView *container;
@property(nonatomic,assign) CGRect frame;
@property(nonatomic,assign) NSInteger viewId;
@property(nonatomic,strong) FlutterMethodChannel *channel;
@property(nonatomic,strong) NSString *codeId;
@property(nonatomic,assign) NSInteger width;
@property(nonatomic,assign) NSInteger height;
@end

#pragma mark - GromoreBannerAd
@implementation GromoreBannerAd

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        NSDictionary *dic = args;
        self.frame = frame;
        self.viewId = viewId;
        self.codeId = dic[@"iosId"];
        self.width =[dic[@"width"] intValue];
        self.height =[dic[@"height"] intValue];
        NSString* channelName = [NSString stringWithFormat:@"com.gstory.gromore/BannerAdView_%lld", viewId];
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
    //self.bannerAd = [[BUNativeExpressBannerView alloc] initWithAdUnitID:self.codeId rootViewController:[UIViewController jsd_getRootViewController] adSize:CGSizeMake(self.width, self.height)];
    self.bannerAd = [[BUNativeExpressBannerView alloc] initWithSlotID:self.codeId rootViewController:[UIViewController jsd_getRootViewController] adSize:CGSizeMake(self.width, self.height)];
    self.bannerAd.delegate = self;
    // 是否使用模板广告，只对支持模板广告的第三方SDK有效，默认为NO，仅在广告加载前设置有效，优先以平台配置为准
    //self.bannerAd.getExpressAdIfCan = YES;
    //图片大小，包括视频媒体的大小设定
    //self.bannerAd.imageOrVideoSize = CGSizeMake(self.width, self.height);
    //是否静音播放视频，是否真实静音由adapter确定，默认为YES，仅在广告加载前设置有效，优先以平台配置为准
    //self.bannerAd.startMutedIfCan = YES;
    //当前配置拉取成功，直接loadAdData
    /*if ([ABUAdSDKManager configDidLoad]) {
        [self.bannerAd loadAdData];
    } else {
        //当前配置未拉取成功，在成功之后会调用该callback
        [ABUAdSDKManager addConfigLoadSuccessObserver:self withAction:^(id  _Nonnull observer) {
            [self.bannerAd loadAdData];
        }];
    }*/
    [self.bannerAd loadAdData];
}

# pragma mark ---<ABUBannerAdDelegate>---

/// banner广告加载成功回调
/// @param bannerAdView 广告视图
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    [[GroLogUtil sharedInstance] print:@"横幅广告加载成功回调"];
    [self.container addSubview:bannerAdView];
    NSDictionary *dictionary = @{@"width": @(bannerAdView.frame.size.width),@"height":@(bannerAdView.frame.size.height)};
    [self.channel invokeMethod:@"onShow" arguments:dictionary result:nil];
}

/// 广告加载失败回调
/// @param bannerAdView 广告操作对象
/// @param error 错误信息
- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    [[GroLogUtil sharedInstance] print:@"横幅广告加载失败回调"];
    NSInteger code = error.code;
    NSString *message = error.userInfo.description;
    NSDictionary *dictionary = @{@"code":@(code),@"message":message};
    [self.channel invokeMethod:@"onFail" arguments:dictionary result:nil];
}

/// 广告展示回调
/// @param bannerAdView 广告视图
- (void)nativeExpressBannerAdViewDidBecomeVisible:(BUNativeExpressBannerView *)bannerAdView {
    NSString *str = [NSString stringWithFormat:@"横幅广告展示 %@",[[bannerAdView mediation] getShowEcpmInfo].mj_keyValues];
    [[GroLogUtil sharedInstance] print:str];
    
    [self.channel invokeMethod:@"onAdInfo" arguments:[[bannerAdView mediation] getShowEcpmInfo].mj_keyValues result:nil];
}

- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    [[GroLogUtil sharedInstance] print:@"横幅广告点击"];
    [self.channel invokeMethod:@"onClick" arguments:nil result:nil];
}

- (void)nativeExpressBannerAdViewDidCloseOtherController:(BUNativeExpressBannerView *)bannerAdView interactionType:(BUInteractionType)interactionType {
    [[GroLogUtil sharedInstance] print:@"横幅广告关闭"];
    [self.container removeFromSuperview];
    [self.channel invokeMethod:@"onClose" arguments:nil result:nil];
}

@end

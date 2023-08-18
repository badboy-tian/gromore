//
//  GromoreSplashAd.m
//  gromore
//
//  Created by gstory on 2022/8/12.
//

#import "GromoreSplashAd.h"
#import "BUAdSDK/BUAdSDK.h"
#import "ABUUIViewController+getCurrentVC.h"
#import "GroLogUtil.h"
#import "MJExtension.h"

#pragma mark - GromoreSplashAdFactory

@implementation GromoreSplashAdFactory{
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
    GromoreSplashAd * bannerAd = [[GromoreSplashAd alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
    return bannerAd;
}
@end

@interface GromoreSplashAd()<BUSplashAdDelegate>
@property (nonatomic, strong) BUSplashAd *splashAd;
@property(nonatomic,strong) UIView *container;
@property(nonatomic,assign) CGRect frame;
@property(nonatomic,assign) NSInteger viewId;
@property(nonatomic,strong) FlutterMethodChannel *channel;
@property(nonatomic,strong) NSString *codeId;
@property(nonatomic,assign) NSInteger width;
@property(nonatomic,assign) NSInteger height;
@end

#pragma mark - GromoreSplashAd
@implementation GromoreSplashAd

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        NSDictionary *dic = args;
        self.frame = frame;
        self.viewId = viewId;
        self.codeId = dic[@"iosId"];
        self.width =[dic[@"width"] intValue];
        self.height =[dic[@"height"] intValue];
        NSString* channelName = [NSString stringWithFormat:@"com.gstory.gromore/SplashView_%lld", viewId];
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
    
    BUAdSlot *slot = [[BUAdSlot alloc]init];
    slot.ID = self.codeId;

   _splashAd = [[BUSplashAd alloc] initWithSlot:slot adSize:CGSizeZero];
   _splashAd.delegate = self;
    _splashAd.supportZoomOutView = FALSE;
   //_splashAd.cardDelegate = self;
   //_splashAd.zoomOutDelegate = self;
    _splashAd.tolerateTimeout = 5;
    
    
    [_splashAd loadAdData];
}

# pragma mark ---<BUSplashAdDelegate>---

- (void)splashAdLoadSuccess:(BUSplashAd *)splashAd {
    [[GroLogUtil sharedInstance] print:@"开屏广告加载成功回调"];
       // 方式二、使用新创建的视图控制器接入，需要自己管理viewController的展示和关闭：
        [splashAd showSplashViewInRootViewController:[UIViewController jsd_getRootViewController]];
    [self.channel invokeMethod:@"onReady" arguments:nil result:nil];
}

- (void)splashAdRenderSuccess:(BUSplashAd *)splashAd {
    [[GroLogUtil sharedInstance] print:@"开屏广告渲染成功回调"];
    /*[self.container addSubview:splashAd.splashView];
    NSDictionary *dictionary = @{@"width": @(splashAd.splashView.frame.size.width),@"height":@(splashAd.splashView.frame.size.height)};
    [self.channel invokeMethod:@"onShow" arguments:dictionary result:nil];*/
}

- (void)splashAdWillShow:(BUSplashAd *)splashAd {
    [[GroLogUtil sharedInstance] print:@"开屏广告splashAdWillShow"];
    [[GroLogUtil sharedInstance] print:@"开屏广告渲染成功回调"];
    [self.container addSubview:splashAd.splashView];
    NSDictionary *dictionary = @{@"width": @(splashAd.splashView.frame.size.width),@"height":@(splashAd.splashView.frame.size.height)};
    [self.channel invokeMethod:@"onShow" arguments:dictionary result:nil];
}

- (void)splashAdDidShow:(BUSplashAd *)splashAd {
    [[GroLogUtil sharedInstance] print:@"开屏广告splashAdDidShow"];
}

- (void)splashAdRenderFail:(BUSplashAd *)splashAd error:(BUAdError *)error {
    [[GroLogUtil sharedInstance] print:@"开屏广告渲染失败回调"];
    NSInteger code = error.code;
    NSString *message = error.userInfo.description;
    NSDictionary *dictionary = @{@"code":@(code),@"message":message};
    [self.channel invokeMethod:@"onFail" arguments:dictionary result:nil];
}

- (void)splashAdLoadFail:(BUSplashAd *)splashAd error:(BUAdError *)error {
    [[GroLogUtil sharedInstance] print:@"开屏广告加载失败回调"];
    NSInteger code = error.code;
    NSString *message = error.userInfo.description;
    NSDictionary *dictionary = @{@"code":@(code),@"message":message};
    [self.channel invokeMethod:@"onFail" arguments:dictionary result:nil];
}

- (void)splashAdDidClick:(BUSplashAd *)splashAd {
    [[GroLogUtil sharedInstance] print:@"开屏广告点击"];
    [self.channel invokeMethod:@"onClick" arguments:nil result:nil];
}

- (void)splashAdDidClose:(BUSplashAd *)splashAd closeType:(BUSplashAdCloseType)closeType {
    [[GroLogUtil sharedInstance] print:@"开屏广告关闭splashAdDidClose"];
    [self.container removeFromSuperview];
    [self.channel invokeMethod:@"onClose" arguments:nil result:nil];
}

- (void)splashDidCloseOtherController:(BUSplashAd *)splashAd interactionType:(BUInteractionType)interactionType {
    [splashAd.mediation destoryAd];
}

- (void)splashAdViewControllerDidClose:(BUSplashAd *)splashAd {
    [[GroLogUtil sharedInstance] print:@"开屏广告关闭splashAdViewControllerDidClose"];
    [self.container removeFromSuperview];
    [self.channel invokeMethod:@"onClose" arguments:nil result:nil];
}

@end

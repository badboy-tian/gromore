#import "GromorePlugin.h"
#import "BUAdSDK/BUAdSDK.h"
#import "GromoreRewardAd.h"
#import "GromorePopAd.h"
#import "GroLogUtil.h"
#import "GromoreEvent.h"
#import "GromoreNativeAd.h"
#import "GromoreBannerAd.h"
#import "GromoreSplashAd.h"

@implementation GromorePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"gromore"
                                     binaryMessenger:[registrar messenger]];
    GromorePlugin* instance = [[GromorePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    //注册event
    [[GromoreEvent sharedInstance]  initEvent:registrar];
    //注册native
    [registrar registerViewFactory:[[GromoreNativeAdFactory alloc] initWithMessenger:registrar.messenger] withId:@"com.gstory.gromore/NativeAdView"];
    //注册banner
    [registrar registerViewFactory:[[GromoreBannerAdFactory alloc] initWithMessenger:registrar.messenger] withId:@"com.gstory.gromore/BannerAdView"];
    //注册splash
    [registrar registerViewFactory:[[GromoreSplashAdFactory alloc] initWithMessenger:registrar.messenger] withId:@"com.gstory.gromore/SplashView"];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    //初始化
    if ([@"register" isEqualToString:call.method]) {
        BOOL debug = [call.arguments[@"debug"] boolValue];
        [[GroLogUtil sharedInstance] debug:debug];
        NSString *appId = call.arguments[@"iosAppId"];
        //        NSDictionary *didDic = @{ @"device_id": @"1234567" };
        
        BUAdSDKConfiguration *configuration = [BUAdSDKConfiguration configuration];
        // 设置APPID
        configuration.appID = appId;

        // 设置日志输出
        //configuration.logLevel = BUAdSDKLogLevelDebug;
        configuration.debugLog = @(1);

        // 是否使用聚合
        configuration.useMediation = YES;
        // 未成年配置
        configuration.ageGroup = BUAdSDKAgeGroupAdult;
        // 主题模式
        configuration.themeStatus = @(BUAdSDKThemeStatus_Normal);
        // 初始化
        [BUAdSDKManager startWithAsyncCompletionHandler:^(BOOL success, NSError *error) {
            if (success) {
                result(@YES);
            }else{
                result(@FALSE);
            }
        }];
        
        //获取sdk版本号
    }else if([@"sdkVersion" isEqualToString:call.method]){
        NSString *version = [BUAdSDKManager SDKVersion];
        result(version);
        //预加载激励广告
    }else if([@"loadRewardAd" isEqualToString:call.method]){
        [[GromoreRewardAd sharedInstance] initAd:call.arguments];
        result(@YES);
        //显示激励广告
    }else if([@"showRewardAd" isEqualToString:call.method]){
        [[GromoreRewardAd sharedInstance] showAd];
        result(@YES);
    } else if([@"loadPopAd" isEqualToString:call.method]){
        [[GromorePopAd sharedInstance] showAd:call.arguments];
        result(@YES);
        //显示激励广告
    }else {
        result(FlutterMethodNotImplemented);
    }
}

@end

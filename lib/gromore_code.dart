/// @Author: gstory
/// @CreateDate: 2022/8/10 16:26
/// @Email gstory0404@gmail.com
/// @Description: 类型

///广告类型
class GromoreAdType {
  static const String adType = "adType";

  ///激励广告
  static const String rewardAd = "rewardAd";

  ///插屏广告
  static const String interactAd = "interactAd";
}

class GromoreAdMethod {
  ///stream中 广告方法
  static const String onAdMethod = "onAdMethod";

  ///广告加载状态 view使用
  ///显示view
  static const String onShow = "onShow";

  ///广告曝光
  static const String onExpose = "onExpose";

  ///加载失败
  static const String onFail = "onFail";

  ///点击
  static const String onClick = "onClick";

  ///视频播放
  static const String onVideoPlay = "onVideoPlay";

  ///视频暂停
  static const String onVideoPause = "onVideoPause";

  ///视频结束
  static const String onVideoStop = "onVideoStop";

  ///倒计时结束
  static const String onFinish = "onFinish";

  ///加载超时
  static const String onTimeOut = "onTimeOut";

  ///广告关闭
  static const String onClose = "onClose";

  ///广告奖励校验
  static const String onVerify = "onVerify";

  ///广告预加载完成
  static const String onReady = "onReady";

  ///广告未预加载
  static const String onUnReady = "onUnReady";

  ///倒计时
  static const String onADTick = "onADTick";

  ///广告信息回调
  static const String onAdInfo = "onAdInfo";

  ///广告跳过回调
  static const String onSkip = "onSkip";

  ///弹窗广告展示
  static const String onPopShow = "onPopShow";
}

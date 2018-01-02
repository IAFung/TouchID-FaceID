//  BioMetricAuthenticator.h
//
//  Created by 冯铁军 on 2017/12/29.
//  Copyright © 2017年 冯铁军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>

/**
 *  TouchID/FaceID 状态
 */
typedef NS_ENUM(NSUInteger, CDAuthType){
    
    /**
     *  当前设备不支持TouchID/FaceID
     */
    CDAuthTypeNotSupport = 0,
    /**
     *  TouchID/FaceID 验证失败
     */
    CDAuthTypeFail,
    /**
     *  TouchID/FaceID 被用户手动取消
     */
    CDAuthTypeUserCancel,
    /**
     *  用户不使用TouchID/FaceID,选择手动输入密码
     */
    CDAuthTypeFallback,
    /**
     *  TouchID/FaceID 被系统取消 (如遇到来电,锁屏,按了Home键等)
     */
    CDAuthTypeSystemCancel,
    /**
     *  TouchID/FaceID 无法启动,因为用户没有设置密码
     */
    CDAuthTypePasswordNotSet,
    /**
     *  用户没有设置TouchID/FaceID
     */
    CDAuthTypeNotEnrolled,
    /**
     *  TouchID/FaceID 无效
     */
    CDAuthTypeNotAvailable,
    /**
     *  TouchID/FaceID 被锁定(连续多次验证TouchID/FaceID失败,系统需要用户手动输入密码)
     */
    CDAuthTypeBiometryLockout,
    /**
     *  当前软件被挂起并取消了授权 (如App进入了后台等)
     */
    CDAuthTypeAppCancel,
    /**
     *  当前软件被挂起并取消了授权 (LAContext对象无效)
     */
    CDAuthTypeInvalidContext,
    /**
     *  系统版本不支持TouchID/FaceID (必须高于iOS 8.0才能使用)
     */
    CDAuthTypeVersionNotSupport
};

typedef void (^AuthenticationFailure)(CDAuthType authenticationType, NSString *errorMessage);
typedef void (^AuthenticationSuccess)(void);

/**
 * 通常先调用BioMetrics,多次失败状态变为CDAuthTypeBiometryLockout时,调用Passcode
 *
 */
@interface BioMetricAuthenticator : NSObject

/**
 * reason使用默认
 * fallbackTitle,cancelTitle使用系统默认
 */
+ (void)authenticateWithBioMetricsSuccessBlock:(AuthenticationSuccess)success
                                  failureBlock:(AuthenticationFailure)failure;
/**
 * fallbackTitle,cancelTitle使用系统默认
 */
+ (void)authenticateWithBioMetricsOfReason:(NSString *)reason
                              successBlock:(AuthenticationSuccess)success
                              failureBlock:(AuthenticationFailure)failure;
/**
 * fallbackTitle 可传nil,若传nil,按钮显示系统默认,系统默认为"输入密码",若想隐藏此按钮,传"",iOS10后可用
 *
 */
+ (void)authenticateWithBioMetricsOfReason:(NSString *)reason
                             fallbackTitle:(NSString *)fallbackTitle
                               cancelTitle:(NSString *)cancelTitle
                              successBlock:(AuthenticationSuccess)success
                              failureBlock:(AuthenticationFailure)failure;

/**
 * reason使用默认
 * fallbackTitle,cancelTitle使用系统默认
 */
+ (void)authenticateWithPasscodeSuccessBlock:(AuthenticationSuccess)success
                                failureBlock:(AuthenticationFailure)failure;

/**
 * fallbackTitle,cancelTitle使用系统默认
 */
+ (void)authenticateWithPasscodeOfReason:(NSString *)reason
                            successBlock:(AuthenticationSuccess)success
                            failureBlock:(AuthenticationFailure)failure;

/**
 * 9.0之后调用可用,8.0没有LAPolicyDeviceOwnerAuthentication,调用没有效果
 * fallbackTitle 可传nil,若传nil,按钮显示系统默认,系统默认为"输入密码",若想隐藏此按钮,传"",iOS10后可用
 *
 */
+ (void)authenticateWithPasscodeOfReason:(NSString *)reason
                           fallbackTitle:(NSString *)fallbackTitle
                             cancelTitle:(NSString *)cancelTitle
                            successBlock:(AuthenticationSuccess)success
                            failureBlock:(AuthenticationFailure)failure;

/**
 * 判断是否支持touchID/FaceID
 */
+ (BOOL)canAuthenticate;
/**
 * 判断是否支持FaceID
 */
+ (BOOL)faceIDAvailable;
@end

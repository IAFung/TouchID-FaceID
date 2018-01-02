//  BioMetricAuthenticator.m
//
//  Created by 冯铁军 on 2017/12/29.
//  Copyright © 2017年 冯铁军. All rights reserved.
//

#import "BioMetricAuthenticator.h"

@implementation BioMetricAuthenticator

+ (instancetype)shared {
    static BioMetricAuthenticator *authenticator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        authenticator = [BioMetricAuthenticator new];
    });
    return authenticator;
}
+ (void)authenticateWithBioMetricsSuccessBlock:(AuthenticationSuccess)success
                                  failureBlock:(AuthenticationFailure)failure
{
    [self authenticateWithBioMetricsOfReason:nil
                                successBlock:success
                                failureBlock:failure];
}
+ (void)authenticateWithBioMetricsOfReason:(NSString *)reason
                              successBlock:(AuthenticationSuccess)success
                              failureBlock:(AuthenticationFailure)failure
{
    [self authenticateWithBioMetricsOfReason:reason
                               fallbackTitle:nil
                                 cancelTitle:nil
                                successBlock:success
                                failureBlock:failure];
}
+ (void)authenticateWithBioMetricsOfReason:(NSString *)reason
                            fallbackTitle:(NSString *)fallbackTitle
                              cancelTitle:(NSString *)cancelTitle
                             successBlock:(AuthenticationSuccess)success
                              failureBlock:(AuthenticationFailure)failure {
    NSString *reasonString;
    if (reason == nil || [reason isEqualToString:@""]) {
        reasonString = [self faceIDAvailable]?@"验证FaceID":@"验证TouchID";
    } else {
        reasonString = reason;
    }
    LAContext *context = [LAContext new];
    context.localizedFallbackTitle = fallbackTitle;
    
    if (@available(iOS 10.0,*)) {
        context.localizedCancelTitle = cancelTitle;
    }
    [[BioMetricAuthenticator shared] evaluateWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics context:context reason:reasonString successBlock:success failureBlock:failure];
}
+ (void)authenticateWithPasscodeOfReason:(NSString *)reason
                            successBlock:(AuthenticationSuccess)success
                            failureBlock:(AuthenticationFailure)failure
{
    [self authenticateWithPasscodeOfReason:reason
                             fallbackTitle:nil
                               cancelTitle:nil
                              successBlock:success
                              failureBlock:failure];
}
+ (void)authenticateWithPasscodeSuccessBlock:(AuthenticationSuccess)success
                                failureBlock:(AuthenticationFailure)failure
{
    [self authenticateWithPasscodeOfReason:nil
                              successBlock:success
                              failureBlock:failure];
}
+ (void)authenticateWithPasscodeOfReason:(NSString *)reason
                           fallbackTitle:(NSString *)fallbackTitle
                             cancelTitle:(NSString *)cancelTitle
                            successBlock:(AuthenticationSuccess)success
                            failureBlock:(AuthenticationFailure)failure {
    NSString *reasonString;
    if (reason == nil || [reason isEqualToString:@""]) {
        reasonString = [self faceIDAvailable]?@"由于您失败的次数太多,FaceID被锁定.请输入iPhone密码进行解锁":@"由于您失败的次数太多,TouchID被锁定.请输入iPhone密码进行解锁";
    } else {
        reasonString = reason;
    }
    LAContext *context = [LAContext new];
    context.localizedFallbackTitle = fallbackTitle;
    
    if (@available(iOS 10.0,*)) {
        context.localizedCancelTitle = cancelTitle;
    }
    if (@available(iOS 9.0,*)) {
        [[BioMetricAuthenticator shared] evaluateWithPolicy:LAPolicyDeviceOwnerAuthentication context:context reason:reasonString successBlock:success failureBlock:failure];
    }
}

- (void)evaluateWithPolicy:(LAPolicy)policy
                   context:(LAContext *)context
                    reason:(NSString *)reason
              successBlock:(AuthenticationSuccess)successBlock
              failureBlock:(AuthenticationFailure)failureBlock {
    [context evaluatePolicy:policy localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (success) {
                if (successBlock) {
                    successBlock();
                }
            }else {
                if (failureBlock) {
                    NSString *msg = @"";
                    NSString *touchID = [BioMetricAuthenticator faceIDAvailable] ? @"FaceID" : @"TouchID";
                    switch (error.code) {
                        case LAErrorAuthenticationFailed:
                        {
                            msg = [touchID stringByAppendingString:@"验证失败"];
                            failureBlock(CDAuthTypeFail, msg);
                        }
                            break;
                        case LAErrorUserCancel:
                        {
                            msg = [touchID stringByAppendingString:@"被用户手动取消"];
                            failureBlock(CDAuthTypeUserCancel, msg);
                        }
                            break;
                        case LAErrorUserFallback:
                        {
                            msg = [[@"用户不使用" stringByAppendingString:touchID] stringByAppendingString:@",选择手动输入密码"];
                            failureBlock(CDAuthTypeFallback, msg);
                        }
                            break;
                        case LAErrorSystemCancel:
                        {
                            msg = [touchID stringByAppendingString:@"被系统取消 (如遇到来电,锁屏,按了Home键等)"];
                            failureBlock(CDAuthTypeSystemCancel, msg);
                        }
                            break;
                        case LAErrorPasscodeNotSet:
                        {
                            msg = [touchID stringByAppendingString:@"无法启动,因为用户没有设置密码"];
                            failureBlock(CDAuthTypePasswordNotSet, msg);
                        }
                            break;
                        case LAErrorTouchIDNotEnrolled:
                        {
                            msg = [touchID stringByAppendingString:@"无法启动,因为用户没有设置"];
                            failureBlock(CDAuthTypeNotEnrolled, msg);
                        }
                            break;
                            //                            case LAErrorTouchIDNotAvailable:
                            //                            {
                            //                                msg = [touchID stringByAppendingString:@"不可用"];
                            //                                failureBlock(CDAuthTypeNotAvailable, msg);
                            //                            }
                            //                                break;
                        case LAErrorTouchIDLockout:
                        {
                            msg = [touchID stringByAppendingString:@"被锁定(连续多次验证失败,系统需要用户手动输入密码)"];
                            failureBlock(CDAuthTypeBiometryLockout, msg);
                        }
                            break;
                            
                            //                            case LAErrorAppCancel:
                            //                            {
                            //                                msg = @"当前软件被挂起并取消了授权 (如App进入了后台等)";
                            //                                failureBlock(CDAuthTypeAppCancel, msg);
                            //                            }
                            //                                break;
                            //                            case LAErrorInvalidContext:
                            //                            {
                            //                                msg = @"当前软件被挂起并取消了授权 (LAContext对象无效)";
                            //                                failureBlock(CDAuthTypeInvalidContext, msg);
                            //                            }
                            //                                break;
                        default:
                        {
                            msg = [touchID stringByAppendingString:@"验证失败"];
                            failureBlock(CDAuthTypeFail, msg);
                        }
                            break;
                    }
                }
            }
        });
    }];
}

+ (BOOL)canAuthenticate {
    BOOL isBiometricAuthenticationAvailable = NO;
    NSError *error = nil;
    if ([LAContext.new canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        isBiometricAuthenticationAvailable = (error == nil);
    }
    return isBiometricAuthenticationAvailable;
}

+ (BOOL)faceIDAvailable {
    if (@available(iOS 11,*)) {
        LAContext *context = [LAContext new];
        return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil] && context.biometryType == LABiometryTypeFaceID;
    }
    return NO;
}
@end

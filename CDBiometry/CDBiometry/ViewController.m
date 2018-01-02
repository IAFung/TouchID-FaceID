//  ViewController.m
//  CDBiometry
//
//  Created by 冯铁军 on 2017/12/29.
//  Copyright © 2017年 冯铁军. All rights reserved.
//

#import "ViewController.h"
#import "BioMetricAuthenticator.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tf;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)login:(id)sender {
    [self.view endEditing:YES];
    [self alert:@"登陆成功"];
}
- (IBAction)auth:(id)sender {
    [BioMetricAuthenticator authenticateWithBioMetricsOfReason:@"" fallbackTitle:nil cancelTitle:nil successBlock:^{
        
    } failureBlock:^(CDAuthType authenticationType, NSString *errorMessage) {
        NSLog(@"%@",errorMessage);
        if (authenticationType == CDAuthTypeUserCancel || authenticationType == CDAuthTypeSystemCancel) {
            return;
        }
        if (authenticationType == CDAuthTypeFallback) {
            [_tf becomeFirstResponder];
        }
        if (authenticationType == CDAuthTypeNotEnrolled) {
            [self alert:errorMessage];
        }
        if (authenticationType == CDAuthTypeBiometryLockout) {
            [BioMetricAuthenticator authenticateWithPasscodeOfReason:errorMessage fallbackTitle:nil cancelTitle:nil successBlock:^{
                
            } failureBlock:^(CDAuthType authenticationType, NSString *errorMessage) {
                [self alert:errorMessage];
            }];
        }
    }];
}
- (void)alert:(NSString *)message {
    [[[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil] show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

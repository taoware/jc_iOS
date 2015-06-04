//
//  GXRegisterTableViewController.m
//  jycs
//
//  Created by appleseed on 3/24/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXRegisterTableViewController.h"
#import "GXUserEngine.h"
#import "JKCountDownButton.h"

#define PROVINCE_COMPONENT  0
#define CITY_COMPONENT      1
#define DISTRICT_COMPONENT  2

@interface GXRegisterTableViewController () <UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong)UIPickerView* areaPicker;
@property (nonatomic, strong)UIPickerView* genderPicker;
@property (nonatomic, strong)UIPickerView* categoryPicker;
@property (nonatomic, strong)UIPickerView* jobPicker;

@property (nonatomic, strong)NSDictionary* areaDic;
@property (nonatomic, strong)NSArray* province;
@property (nonatomic, strong)NSArray* city;
@property (nonatomic, strong)NSArray* district;
@property (nonatomic, strong)NSArray* gender;
@property (nonatomic, strong)NSArray* category;
@property (nonatomic, strong)NSArray* jobs;
@property (nonatomic, strong)NSString *selectedProvince;
@property (nonatomic)NSInteger currentProvince;
@property (nonatomic)NSInteger currentCity;
@property (nonatomic)NSInteger currentDistrict;

@property (nonatomic, strong)NSString* verificationCode;
@property (nonatomic, strong)NSString* mobile;

@property (weak, nonatomic) IBOutlet UITextField *genderTextField;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UITextField *jobTextField;
@property (weak, nonatomic) IBOutlet UITextField *areaTextField;


@property (weak, nonatomic) IBOutlet UITextField *firstTextField;
//@property (weak, nonatomic) IBOutlet UITextField *secondTextField;
@property (weak, nonatomic) IBOutlet UITextField *thirdTextField;
@property (weak, nonatomic) IBOutlet UITextField *fourthTextField;
@property (weak, nonatomic) IBOutlet UITextField *fifthTextField;
@property (weak, nonatomic) IBOutlet UITextField *sixthTextField;
@property (weak, nonatomic) IBOutlet UITextField *seventhTextField;
@property (weak, nonatomic) IBOutlet UITextField *eighthTextField;


@end

@implementation GXRegisterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(cancelRegistation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardDidShow:)
                                                 name: UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillDisappear:)
                                                 name: UIKeyboardWillHideNotification object:nil];
    
    [self initAreaData];
    self.gender = @[@"男", @"女"];
    self.category = @[@"管理员", @"联采", @"员工", @"供应商", @"游客"];
    self.jobs = @[@"副校长", @"董事长", @"校长助理", @"主任", @"秘书长", @"副主任", @"副秘书长", @"处长", @"总经理", @"副处长", @"副总经理", @"科长", @"部门经理", @"员工", @"其他"];
    
    [self initializeTextFieldInputView];
}

- (void) initializeTextFieldInputView {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hidePicker)];
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [toolbar setItems:[NSArray arrayWithObjects:flexible,doneButton, nil]];
    
    self.genderTextField.inputView = self.genderPicker;
    self.genderTextField.inputAccessoryView = toolbar;
    self.categoryTextField.inputView = self.categoryPicker;
    self.categoryTextField.inputAccessoryView = toolbar;
    self.jobTextField.inputView = self.jobPicker;
    self.jobTextField.inputAccessoryView = toolbar;
    self.areaTextField.inputView = self.areaPicker;
    self.areaTextField.inputAccessoryView = toolbar;
}

- (void)hidePicker {
    [self.view endEditing:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardDidShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardWillHideNotification object: nil];
}

- (void) keyboardWillShow: (NSNotification*) aNotification
{
    [UIView animateWithDuration: [self keyboardAnimationDurationForNotification: aNotification] animations:^{
        CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        //change the frame of your talbleiview via kbsize.height
    } completion:^(BOOL finished) {
    }];
}

- (void) keyboardDidShow: (NSNotification*) aNotification
{
    [UIView animateWithDuration: [self keyboardAnimationDurationForNotification: aNotification] animations:^{
        CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        //change the frame of your talbleiview via kbsize.height
    } completion:^(BOOL finished) {
    }];
}

- (void) keyboardWillDisappear: (NSNotification*) aNotification
{
    [UIView animateWithDuration: [self keyboardAnimationDurationForNotification: aNotification] animations:^{
        //restore your tableview
    } completion:^(BOOL finished) {
    }];
}

- (NSTimeInterval) keyboardAnimationDurationForNotification:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    NSValue* value = [info objectForKey: UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue: &duration];
    
    return duration;
}

- (void)initAreaData {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"area" ofType:@"plist"];
    self.areaDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSArray *components = [self.areaDic allKeys];
    NSArray *sortedArray = [components sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSMutableArray *provinceTmp = [[NSMutableArray alloc] init];
    for (int i=0; i<[sortedArray count]; i++) {
        NSString *index = [sortedArray objectAtIndex:i];
        NSArray *tmp = [[self.areaDic objectForKey: index] allKeys];
        [provinceTmp addObject: [tmp objectAtIndex:0]];
    }
    
    self.province = [[NSArray alloc] initWithArray: provinceTmp];
    
    NSString *index = [sortedArray objectAtIndex:0];
    NSString *selected = [self.province objectAtIndex:0];
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [[self.areaDic objectForKey:index]objectForKey:selected]];
    
    NSArray *cityArray = [dic allKeys];
    NSDictionary *cityDic = [NSDictionary dictionaryWithDictionary: [dic objectForKey: [cityArray objectAtIndex:0]]];
    self.city = [[NSArray alloc] initWithArray: [cityDic allKeys]];
    
    
    NSString *selectedCity = [self.city objectAtIndex: 0];
    self.district = [[NSArray alloc] initWithArray: [cityDic objectForKey: selectedCity]];
}

# pragma mark - action

- (void)cancelRegistation {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)submitRegistation:(UIButton *)sender {
    NSString* name = self.firstTextField.text;
    NSString* gender = self.genderTextField.text;
    NSString* category = self.categoryTextField.text;
    NSString* job = self.jobTextField.text;
    NSString* locaction = self.areaTextField.text;
    NSString* address = self.thirdTextField.text;
    NSString* mobile = self.fourthTextField.text;
    NSString* validationCode = self.fifthTextField.text;
    NSString* password = self.sixthTextField.text;
    NSString* conformPass = self.seventhTextField.text;
    NSString* notes = self.eighthTextField.text;
    
    if (![self.mobile isEqualToString:mobile]) {
        TTAlertNoTitle(@"更改手机号需要重新获取验证码");
        return;
    }
    
    if (!name.length || !gender.length || !job.length>0 || !locaction.length>0 || !address.length>0 || !mobile.length>0 || !password.length>0) {
        TTAlertNoTitle(@"注册信息不完整");
        return;
    }
    
    if (![self verifyCode:validationCode]) {
        TTAlertNoTitle(@"验证码错误");
        return;
    }
    
    if (!name.length || !gender.length || !job.length>0 || !locaction.length>0 || !address.length>0 || !mobile.length>0 || !password.length>0) {
        TTAlertNoTitle(@"注册信息不完整");
        return;
    } else if (![password isEqualToString:conformPass]) {
        TTAlertNoTitle(@"两次密码不相同");
        return ;
    } else if (![self validatePassword:password]) {  // password validation
        TTAlertNoTitle(@"密码要求6-16位，至少1个数字，1个字母");
        return;
    } else if (![self verifyCode:validationCode]) {  // vefication code validation
        TTAlertNoTitle(@"验证码错误");
        return;
    } else {
        [self showHudInView:self.view hint:@"正在注册"];
        [[GXUserEngine sharedEngine] asyncUserRegisterWithRealName:name andGender:gender andCategory:category andJob:job andArea:locaction andAddress:address andPhoneNumber:mobile andValidationCode:validationCode andPassword:password andRemark:notes completion:^(NSDictionary *registerInfo, GXError *error) {
            [self hideHud];
            if (!error) {
                [self showHint:@"注册成功"];
                [self dismissViewControllerAnimated:YES completion:NULL];
            } else {
                switch (error.errorCode) {
                    case GXErrorServerNotReachable:
                        TTAlertNoTitle(@"服务器连接失败");
                        break;
                    case GXErrorRegistrationFailure:
                        TTAlertNoTitle(error.description);
                        break;
                    default:
                        TTAlertNoTitle(@"注册失败");
                        NSLog(@"%@", error.description);
                        break;
                }
            }
        }];
    }
    
    
}

- (BOOL)verifyCode:(NSString *)code {
    BOOL result = NO;
    
    if ([self.verificationCode isEqualToString:code]) {
        result = YES;
    }
    
    return result;
}

- (BOOL)validatePassword:(NSString *)password {
    BOOL result;
    
    NSString *passwordRegex =@"^(?=.*[0-9])(?=.*[a-zA-Z])([a-zA-Z0-9]+){6,16}$";
    NSPredicate *passwordPred = [NSPredicate predicateWithFormat:@"%@ MATCHES %@", password, passwordRegex];
    result = [passwordPred evaluateWithObject:passwordRegex];
    
    return result;
}

- (UIPickerView *)genderPicker {
    if (!_genderPicker) {
        _genderPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 10.0f)];
        _genderPicker.tag = 201;
        _genderPicker.delegate = self;
        _genderPicker.dataSource = self;
        _genderPicker.showsSelectionIndicator = YES;
    }
    return _genderPicker;
}

- (UIPickerView *)categoryPicker {
    if (!_categoryPicker) {
        _categoryPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 190.0f)];
        _categoryPicker.tag = 202;
        _categoryPicker.delegate = self;
        _categoryPicker.dataSource = self;
        _categoryPicker.showsSelectionIndicator = YES;
    }
    return _categoryPicker;
}

- (UIPickerView *)jobPicker {
    if (!_jobPicker) {
        _jobPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 190.0f)];
        _jobPicker.tag = 204;
        _jobPicker.delegate = self;
        _jobPicker.dataSource = self;
        _jobPicker.showsSelectionIndicator = YES;
    }
    return _jobPicker;
}

- (UIPickerView *)areaPicker {
    if (!_areaPicker) {
        _areaPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 190.0f)];
        _areaPicker.tag = 203;
        _areaPicker.delegate = self;
        _areaPicker.dataSource = self;
        _areaPicker.showsSelectionIndicator = YES;
        [_areaPicker selectRow:self.currentProvince inComponent:PROVINCE_COMPONENT animated:NO];
        [_areaPicker selectRow:self.currentCity inComponent:CITY_COMPONENT animated:NO];
        [_areaPicker selectRow:self.currentDistrict inComponent:DISTRICT_COMPONENT animated:NO];
    }
    return _areaPicker;
}


- (IBAction)countDownXibTouched:(JKCountDownButton*)sender {
    sender.enabled = NO;
    //button type要 设置成custom 否则会闪动
    [sender startWithSecond:60];
    self.mobile = self.fourthTextField.text;
    self.verificationCode = [self generateRandom4DigitCode];
    NSString* message = [NSString stringWithFormat:@"您本次身份校验码是%@, 30分钟内有效，教育超市工作人员绝不会向您索取此校验码，切勿告知他人", self.verificationCode];
    NSString* url = [NSString stringWithFormat:@"http://vps1.taoware.com/notify?mobile=%@&message=%@", self.mobile, message];
//    NSString* url = [NSString stringWithFormat:@"http://vps1.taoware.com/notify?mobile=%@&message=%@", @"13166362596", message];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation start];
    [sender didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
        NSString *title = [NSString stringWithFormat:@"剩余%d秒",second];
        return title;
    }];
    [sender didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
        countDownButton.enabled = YES;
        return @"点击重新获取";
        
    }];
}

- (NSString *)generateRandom4DigitCode {
    int randomNum = arc4random_uniform(10000);
    return [NSString stringWithFormat:@"%04d", randomNum];
}


#pragma mark- Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag == 203) { // 所在地址
        return 3;
    } else {
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 201) {
        return self.gender.count;
    } else if (pickerView.tag == 202) {
        return self.category.count;
    } else if (pickerView.tag == 203) {
        if (component == PROVINCE_COMPONENT) {
            return [self.province count];
        }
        else if (component == CITY_COMPONENT) {
            return [self.city count];
        }
        else {
            return [self.district count];
        }
    } else if (pickerView.tag == 204) {
        return self.jobs.count;
    } else {
        return 0;
    }
}


#pragma mark- Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 201) {
        return self.gender[row];
    } else if (pickerView.tag == 202) {
        
    } else if (pickerView.tag == 203) {
        if (component == PROVINCE_COMPONENT) {
            return [self.province objectAtIndex: row];
        }
        else if (component == CITY_COMPONENT) {
            return [self.city objectAtIndex: row];
        }
        else {
            return [self.district objectAtIndex: row];
        }
    } else if (pickerView.tag == 204) {
        return self.jobs[row];
    }
    return nil;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 203) {
        if (component == PROVINCE_COMPONENT) {
            self.selectedProvince = [self.province objectAtIndex: row];
            NSDictionary *tmp = [NSDictionary dictionaryWithDictionary: [self.areaDic objectForKey: [NSString stringWithFormat:@"%d", row]]];
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [tmp objectForKey: self.selectedProvince]];
            NSArray *cityArray = [dic allKeys];
            NSArray *sortedArray = [cityArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
                
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;//递减
                }
                
                if ([obj1 integerValue] < [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;//上升
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i=0; i<[sortedArray count]; i++) {
                NSString *index = [sortedArray objectAtIndex:i];
                NSArray *temp = [[dic objectForKey: index] allKeys];
                [array addObject: [temp objectAtIndex:0]];
            }
            
            self.city = [[NSArray alloc] initWithArray: array];
            
            NSDictionary *cityDic = [dic objectForKey: [sortedArray objectAtIndex: 0]];
            self.district = [[NSArray alloc] initWithArray: [cityDic objectForKey: [self.city objectAtIndex: 0]]];
            [self.areaPicker selectRow: 0 inComponent: CITY_COMPONENT animated: YES];
            [self.areaPicker selectRow: 0 inComponent: DISTRICT_COMPONENT animated: YES];
            [self.areaPicker reloadComponent: CITY_COMPONENT];
            [self.areaPicker reloadComponent: DISTRICT_COMPONENT];
            
        }
        else if (component == CITY_COMPONENT) {
            NSString *provinceIndex = [NSString stringWithFormat: @"%d", [self.province indexOfObject: self.selectedProvince]];
            NSDictionary *tmp = [NSDictionary dictionaryWithDictionary: [self.areaDic objectForKey: provinceIndex]];
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [tmp objectForKey: self.selectedProvince]];
            NSArray *dicKeyArray = [dic allKeys];
            NSArray *sortedArray = [dicKeyArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
                
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if ([obj1 integerValue] < [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            NSDictionary *cityDic = [NSDictionary dictionaryWithDictionary: [dic objectForKey: [sortedArray objectAtIndex: row]]];
            NSArray *cityKeyArray = [cityDic allKeys];
            
            self.district = [[NSArray alloc] initWithArray: [cityDic objectForKey: [cityKeyArray objectAtIndex:0]]];
            [self.areaPicker selectRow: 0 inComponent: DISTRICT_COMPONENT animated: YES];
            [self.areaPicker reloadComponent: DISTRICT_COMPONENT];
        }
        NSInteger provinceIndex = [self.areaPicker selectedRowInComponent: PROVINCE_COMPONENT];
        NSInteger cityIndex = [self.areaPicker selectedRowInComponent: CITY_COMPONENT];
        NSInteger districtIndex = [self.areaPicker selectedRowInComponent: DISTRICT_COMPONENT];

        self.currentProvince = provinceIndex;
        self.currentCity = cityIndex;
        self.currentDistrict = districtIndex;

        NSString *provinceStr = [self.province objectAtIndex: provinceIndex];
        NSString *cityStr = [self.city objectAtIndex: cityIndex];
        NSString *districtStr = [self.district objectAtIndex:districtIndex];

        if ([provinceStr isEqualToString: cityStr] && [cityStr isEqualToString: districtStr]) {
            cityStr = @"";
            districtStr = @"";
        }
        else if ([cityStr isEqualToString: districtStr]) {
            districtStr = @"";
        }

        NSString *showMsg = [NSString stringWithFormat: @"%@ %@ %@", provinceStr, cityStr, districtStr];
        self.areaTextField.text = showMsg;
    } else if (pickerView.tag == 201) {
        NSInteger genderIndex = [self.genderPicker selectedRowInComponent: 0];
        NSString *showMsg = self.gender[genderIndex];
        self.genderTextField.text = showMsg;
    } else if (pickerView.tag == 202) {
        NSInteger categoryIndex = [self.categoryPicker selectedRowInComponent: 0];
        NSString *showMsg = self.category[categoryIndex];
        self.categoryTextField.text = showMsg;
    } else if (pickerView.tag == 204) {
        NSInteger jobIndex = [self.jobPicker selectedRowInComponent: 0];
        NSString *showMsg = self.jobs[jobIndex];
        self.jobTextField.text = showMsg;
    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == PROVINCE_COMPONENT) {
        return 80;
    }
    else if (component == CITY_COMPONENT) {
        return 100;
    }
    else {
        return 115;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *myView = nil;
    
    if (pickerView.tag == 201) {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 78, 50)];
        myView.textAlignment = UITextAlignmentCenter;
        myView.text = [self.gender objectAtIndex:row];
        myView.font = [UIFont systemFontOfSize:25];
        myView.backgroundColor = [UIColor clearColor];
    } else if (pickerView.tag == 202) {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 78, 30)];
        myView.textAlignment = UITextAlignmentCenter;
        myView.text = [self.category objectAtIndex:row];
        myView.font = [UIFont systemFontOfSize:18];
        myView.backgroundColor = [UIColor clearColor];
    } else if (pickerView.tag == 203) {
        if (component == PROVINCE_COMPONENT) {
            myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 78, 30)];
            myView.textAlignment = UITextAlignmentCenter;
            myView.text = [self.province objectAtIndex:row];
            myView.font = [UIFont systemFontOfSize:18];
            myView.backgroundColor = [UIColor clearColor];
        }
        else if (component == CITY_COMPONENT) {
            myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 95, 30)];
            myView.textAlignment = UITextAlignmentCenter;
            myView.text = [self.city objectAtIndex:row];
            myView.font = [UIFont systemFontOfSize:18];
            myView.backgroundColor = [UIColor clearColor];
        }
        else {
            myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 110, 30)];
            myView.textAlignment = UITextAlignmentCenter;
            myView.text = [self.district objectAtIndex:row];
            myView.font = [UIFont systemFontOfSize:18];
            myView.backgroundColor = [UIColor clearColor];
        }
    } else if (pickerView.tag == 204) {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 120, 30)];
        myView.textAlignment = UITextAlignmentCenter;
        myView.text = [self.jobs objectAtIndex:row];
        myView.font = [UIFont systemFontOfSize:25];
        myView.backgroundColor = [UIColor clearColor];
    }
    
    
    
    return myView;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    if (pickerView == self.areaPicker) {
        return 30;
    }
    return 35;
}

#pragma mark - uiscrollview delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstTextField) {
        [self.firstTextField resignFirstResponder];
        [self.genderTextField becomeFirstResponder];
    } else if (textField == self.thirdTextField) {
        [self.fourthTextField becomeFirstResponder];
    } else if (textField == self.fourthTextField) {
        [self.fifthTextField becomeFirstResponder];
    } else if (textField == self.fifthTextField) {
        [self.sixthTextField becomeFirstResponder];
    } else if (textField == self.sixthTextField) {
        [self.seventhTextField becomeFirstResponder];
    } else if (textField == self.seventhTextField) {
        [self.eighthTextField becomeFirstResponder];
    } else if (textField == self.eighthTextField) {
        [self.view endEditing:YES];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.areaTextField) {
        NSInteger row = 0;
        NSInteger component = 0;
        if (component == PROVINCE_COMPONENT) {
            self.selectedProvince = [self.province objectAtIndex: row];
            NSDictionary *tmp = [NSDictionary dictionaryWithDictionary: [self.areaDic objectForKey: [NSString stringWithFormat:@"%d", row]]];
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [tmp objectForKey: self.selectedProvince]];
            NSArray *cityArray = [dic allKeys];
            NSArray *sortedArray = [cityArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
                
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;//递减
                }
                
                if ([obj1 integerValue] < [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;//上升
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i=0; i<[sortedArray count]; i++) {
                NSString *index = [sortedArray objectAtIndex:i];
                NSArray *temp = [[dic objectForKey: index] allKeys];
                [array addObject: [temp objectAtIndex:0]];
            }
            
            self.city = [[NSArray alloc] initWithArray: array];
            
            NSDictionary *cityDic = [dic objectForKey: [sortedArray objectAtIndex: 0]];
            self.district = [[NSArray alloc] initWithArray: [cityDic objectForKey: [self.city objectAtIndex: 0]]];
            [self.areaPicker selectRow: 0 inComponent: CITY_COMPONENT animated: YES];
            [self.areaPicker selectRow: 0 inComponent: DISTRICT_COMPONENT animated: YES];
            [self.areaPicker reloadComponent: CITY_COMPONENT];
            [self.areaPicker reloadComponent: DISTRICT_COMPONENT];
            
        }
        else if (component == CITY_COMPONENT) {
            NSString *provinceIndex = [NSString stringWithFormat: @"%d", [self.province indexOfObject: self.selectedProvince]];
            NSDictionary *tmp = [NSDictionary dictionaryWithDictionary: [self.areaDic objectForKey: provinceIndex]];
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [tmp objectForKey: self.selectedProvince]];
            NSArray *dicKeyArray = [dic allKeys];
            NSArray *sortedArray = [dicKeyArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
                
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if ([obj1 integerValue] < [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            NSDictionary *cityDic = [NSDictionary dictionaryWithDictionary: [dic objectForKey: [sortedArray objectAtIndex: row]]];
            NSArray *cityKeyArray = [cityDic allKeys];
            
            self.district = [[NSArray alloc] initWithArray: [cityDic objectForKey: [cityKeyArray objectAtIndex:0]]];
            [self.areaPicker selectRow: 0 inComponent: DISTRICT_COMPONENT animated: YES];
            [self.areaPicker reloadComponent: DISTRICT_COMPONENT];
        }
        NSInteger provinceIndex = [self.areaPicker selectedRowInComponent: PROVINCE_COMPONENT];
        NSInteger cityIndex = [self.areaPicker selectedRowInComponent: CITY_COMPONENT];
        NSInteger districtIndex = [self.areaPicker selectedRowInComponent: DISTRICT_COMPONENT];
        
        self.currentProvince = provinceIndex;
        self.currentCity = cityIndex;
        self.currentDistrict = districtIndex;
        
        NSString *provinceStr = [self.province objectAtIndex: provinceIndex];
        NSString *cityStr = [self.city objectAtIndex: cityIndex];
        NSString *districtStr = [self.district objectAtIndex:districtIndex];
        
        if ([provinceStr isEqualToString: cityStr] && [cityStr isEqualToString: districtStr]) {
            cityStr = @"";
            districtStr = @"";
        }
        else if ([cityStr isEqualToString: districtStr]) {
            districtStr = @"";
        }
        
        NSString *showMsg = [NSString stringWithFormat: @"%@ %@ %@", provinceStr, cityStr, districtStr];
        self.areaTextField.text = showMsg;
    } else if (textField == self.genderTextField) {
        NSInteger genderIndex = [self.genderPicker selectedRowInComponent: 0];
        NSString *showMsg = self.gender[genderIndex];
        self.genderTextField.text = showMsg;
    } else if (textField == self.categoryTextField) {
        NSInteger categoryIndex = [self.categoryPicker selectedRowInComponent: 0];
        NSString *showMsg = self.category[categoryIndex];
        self.categoryTextField.text = showMsg;
    } else if (textField == self.jobTextField) {
        NSInteger jobIndex = [self.jobPicker selectedRowInComponent: 0];
        NSString *showMsg = self.jobs[jobIndex];
        self.jobTextField.text = showMsg;
    }
}

@end

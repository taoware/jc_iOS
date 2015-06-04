/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "AddFriendViewController.h"

#import "ApplyViewController.h"
#import "UIViewController+HUD.h"
#import "AddFriendCell.h"
#import "InvitationManager.h"
#import "User.h"
#import "Photo.h"
#import "GXUserEngine.h"
#import "UIDownPicker.h"

#define PROVINCE_COMPONENT  0
#define CITY_COMPONENT      1
#define DISTRICT_COMPONENT  2

@interface AddFriendViewController ()<UITextFieldDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, DownPickerDelegate>

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UITextField* typeField;
@property (strong, nonatomic) DownPicker* downPicker;
@property (strong, nonatomic) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UIPickerView* areaPicker;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong)NSArray* province;
@property (nonatomic, strong)NSArray* city;
@property (nonatomic, strong)NSArray* district;
@property (nonatomic)NSInteger currentProvince;
@property (nonatomic)NSInteger currentCity;
@property (nonatomic)NSInteger currentDistrict;
@property (nonatomic, strong)NSString *selectedProvince;

@property (nonatomic, strong)NSDictionary* areaDic;

@end

@implementation AddFriendViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    self.title = NSLocalizedString(@"friend.add", @"Add friend");
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = self.headerView;
    
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    self.tableView.tableFooterView = footerView;
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    [searchButton setTitle:NSLocalizedString(@"search", @"Search") forState:UIControlStateNormal];
//    [searchButton setTitleColor:[UIColor colorWithRed:32 / 255.0 green:134 / 255.0 blue:158 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:searchButton]];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    [self.view addSubview:self.textField];
    
    [self initAreaData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSArray* types = @[@"地区", @"姓名", @"单位", @"手机号"];
    self.downPicker = [[DownPicker alloc]initWithTextField:self.typeField withData:[types mutableCopy]];
    self.downPicker.delegate = self;
    [self.downPicker setPlaceholder:@"请选择"];
    [self.downPicker setPlaceholderWhileSelecting:@"请选择"];
    [self.downPicker setToolbarDoneButtonText:@"完成"];
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


#pragma mark - getter

- (UITextField *)textField
{
    if (_textField == nil) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(20+90, 10, self.view.frame.size.width - 40 -90, 35)];
        _textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _textField.layer.borderWidth = 0.5;
        _textField.layer.cornerRadius = 3;
        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.font = [UIFont systemFontOfSize:15.0];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.placeholder = NSLocalizedString(@"friend.inputNameToSearch", @"input to find friends");
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.delegate = self;
    }
    
    return _textField;
}

- (UITextField *)typeField {
    if (!_typeField) {
        _typeField = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, 90, 35)];
        _typeField.textAlignment = NSTextAlignmentCenter;
    }
    return _typeField;
}

//- (UISegmentedControl *)segmentControl {
//    if (_segmentControl == nil) {
//        _segmentControl = [[UISegmentedControl alloc]initWithFrame:CGRectMake(10, 55, self.view.frame.size.width - 20, 30)];
//        [_segmentControl insertSegmentWithTitle:@"地区" atIndex:0 animated:NO];
//        [_segmentControl insertSegmentWithTitle:@"姓名" atIndex:1 animated:NO];
//        [_segmentControl insertSegmentWithTitle:@"所在单位" atIndex:2 animated:NO];
//        [_segmentControl insertSegmentWithTitle:@"手机号" atIndex:3 animated:NO];
//        _segmentControl.selectedSegmentIndex = 0;
//        [self segmentControlSelected:_segmentControl];
//        [_segmentControl addTarget:self action:@selector(segmentControlSelected:) forControlEvents:UIControlEventValueChanged];
//    }
//    return _segmentControl;
//}

- (UIView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 55)];
        _headerView.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
        
        [_headerView addSubview:_textField];
        [_headerView addSubview:self.typeField];
    }
    
    return _headerView;
}

- (UIPickerView *)areaPicker {
    if (!_areaPicker) {
        _areaPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 190.0f)];
        _areaPicker.delegate = self;
        _areaPicker.dataSource = self;
        _areaPicker.showsSelectionIndicator = YES;
        [_areaPicker selectRow:self.currentProvince inComponent:PROVINCE_COMPONENT animated:NO];
        [_areaPicker selectRow:self.currentCity inComponent:CITY_COMPONENT animated:NO];
        [_areaPicker selectRow:self.currentDistrict inComponent:DISTRICT_COMPONENT animated:NO];
    }
    return _areaPicker;
}

#pragma mark - action

- (void)segmentControlSelected:(UISegmentedControl *)sender {
    [self.view endEditing:YES];
    self.textField.text = nil;
    
    if (sender.selectedSegmentIndex == 0) {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hidePicker)];
        UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [toolbar setItems:[NSArray arrayWithObjects:flexible,doneButton, nil]];
        
        self.textField.inputView = self.areaPicker;
        self.textField.inputAccessoryView = toolbar;
    } else {
        self.textField.inputView = nil;
    }
    
    NSArray* holderText = @[@"按地区搜索好友",
                            @"按姓名搜索好友",
                            @"按单位搜索好友",
                            @"按手机号搜索好友",
                            ];
    self.textField.placeholder = holderText[sender.selectedSegmentIndex];
}

- (void)hidePicker {
    [self.view endEditing:YES];
}

#pragma mark - down picker delegate

- (void)didPickItemAtIndex:(NSInteger)index {
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    
    self.textField.text = nil;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hidePicker)];
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    [toolbar setItems:[NSArray arrayWithObjects:flexible,doneButton, nil]];
    if (index == 0) {
        self.textField.inputView = self.areaPicker;
        self.textField.inputAccessoryView = toolbar;
        self.textField.placeholder = @"请输入好友所在地区";
    } else if (index == 1) {
        self.textField.inputView = nil;
        [self.textField setKeyboardType:UIKeyboardTypeDefault];
        self.textField.inputAccessoryView = toolbar;
        self.textField.placeholder = @"请输入好友姓名";
    } else if ([self.typeField.text isEqualToString:@"单位"]) {
        self.textField.inputView = nil;
        [self.textField setKeyboardType:UIKeyboardTypeDefault];
        self.textField.inputAccessoryView = toolbar;
        self.textField.placeholder = @"请输入好友所在单位";
    } else if ([self.typeField.text isEqualToString:@"手机号"]) {
        self.textField.inputView = nil;
        self.textField.inputAccessoryView = toolbar;
        self.textField.placeholder = @"请输入好友所的手机号";
        [self.textField setKeyboardType:UIKeyboardTypeNumberPad];
    }
}

#pragma mark- Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == PROVINCE_COMPONENT) {
        return [self.province count];
    }
    else if (component == CITY_COMPONENT) {
        return [self.city count];
    }
    else {
        return [self.district count];
    }
}

#pragma mark- Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == PROVINCE_COMPONENT) {
        return [self.province objectAtIndex: row];
    }
    else if (component == CITY_COMPONENT) {
        return [self.city objectAtIndex: row];
    }
    else {
        return [self.district objectAtIndex: row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
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
    self.textField.text = showMsg;
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
    
    return myView;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddFriendCell";
    AddFriendCell *cell = (AddFriendCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[AddFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    User* user = [[GXUserEngine sharedEngine] queryUserInfoUsingEasmobUsername:[self.dataSource objectAtIndex:indexPath.row]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:user.avatar.thumbnailURL] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
    cell.textLabel.text = user.name;
    
//    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead.png"];
//    cell.textLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndexPath = indexPath;
    NSString *buddyName = [self.dataSource objectAtIndex:indexPath.row];
    if ([self didBuddyExist:buddyName]) {
        User* user = [[GXUserEngine sharedEngine] queryUserInfoUsingEasmobUsername:buddyName];
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"friend.repeat", @"'%@'has been your friend!"), user.name];
        
        [EMAlertView showAlertWithTitle:message
                                message:nil
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles:nil];
        
    }
    else if([self hasSendBuddyRequest:buddyName])
    {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"friend.repeatApply", @"you have send fridend request to '%@'!"), buddyName];
        [EMAlertView showAlertWithTitle:message
                                message:nil
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles:nil];
        
    }else{
        [self showMessageAlertView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - action

- (void)searchAction
{
    [_textField resignFirstResponder];
    if(_textField.text.length > 0)
    {
#warning 由用户体系的用户，需要添加方法在已有的用户体系中查询符合填写内容的用户
#warning 以下代码为测试代码，默认用户体系中有一个符合要求的同名用户
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
        if ([_textField.text isEqualToString:loginUsername]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"friend.notAddSelf", @"can't add yourself as a friend") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
        }
        
        //判断是否已发来申请
        NSArray *applyArray = [[ApplyViewController shareController] dataSource];
        if (applyArray && [applyArray count] > 0) {
            for (ApplyEntity *entity in applyArray) {
                ApplyStyle style = [entity.style intValue];
                BOOL isGroup = style == ApplyStyleFriend ? NO : YES;
                if (!isGroup && [entity.applicantUsername isEqualToString:_textField.text]) {
                    NSString *str = [NSString stringWithFormat:NSLocalizedString(@"friend.repeatInvite", @"%@ have sent the application to you"), _textField.text];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:str delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                    [alertView show];
                    
                    return;
                }
            }
        }
        
        [self.dataSource removeAllObjects];
        
        NSString* queryString = self.textField.text;
//        NSArray* types = @[@"location", @"name", @"address", @"mobile"];
        NSString* type;
        if ([self.typeField.text isEqualToString:@"地区"]) {
            type = @"location";
        } else if ([self.typeField.text isEqualToString:@"姓名"]) {
            type = @"name";
        } else if ([self.typeField.text isEqualToString:@"单位"]) {
            type = @"address";
        } else if ([self.typeField.text isEqualToString:@"手机号"]) {
            type = @"mobile";
        }
        if (type.length == 0) {
            TTAlertNoTitle(@"请选择搜索类型");
            return;
        }
        [[GXUserEngine sharedEngine] queryUserInfoWithQueryString:(NSString *)queryString ofType:(NSString *)type completion:^(NSArray *users, GXError *error) {
            if (error) {
                TTAlertNoTitle(@"查询错误");
            } else if (!users.count) {
                TTAlertNoTitle(@"未查询到用户");
            } else {
                self.dataSource = [[users valueForKey:@"imUsername"] mutableCopy];
                
                NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
                NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
                NSMutableArray* usersToRemove = [[NSMutableArray alloc]init];
                for (NSString* imUser in self.dataSource) {
                    if ([imUser isEqualToString:loginUsername]) {
                        [usersToRemove addObject:imUser];
                    } else if ([self didBuddyExist:imUser]) {
                        [usersToRemove addObject:imUser];
                    }
                }
                for (NSString* imUser in usersToRemove) {
                    [self.dataSource removeObject:imUser];
                }
                if (self.dataSource.count == 0) {
                    TTAlertNoTitle(@"未找到符合条件的联系人，可能已经是您的好友");
                }
                
                [self.tableView reloadData];
            }
        }];
//        [self.dataSource addObject:_textField.text];
//        [self.tableView reloadData];
    }
}

- (BOOL)hasSendBuddyRequest:(NSString *)buddyName
{
    NSArray *buddyList = [[[EaseMob sharedInstance] chatManager] buddyList];
    for (EMBuddy *buddy in buddyList) {
        if ([buddy.username isEqualToString:buddyName] &&
            buddy.followState == eEMBuddyFollowState_NotFollowed &&
            buddy.isPendingApproval) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)didBuddyExist:(NSString *)buddyName
{
    NSArray *buddyList = [[[EaseMob sharedInstance] chatManager] buddyList];
    for (EMBuddy *buddy in buddyList) {
        if ([buddy.username isEqualToString:buddyName] &&
            buddy.followState != eEMBuddyFollowState_NotFollowed) {
            return YES;
        }
    }
    return NO;
}

- (void)showMessageAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:NSLocalizedString(@"saySomething", @"say somthing")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel")
                                          otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView cancelButtonIndex] != buttonIndex) {
        UITextField *messageTextField = [alertView textFieldAtIndex:0];
        
        NSString *messageStr = @"";
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *username = [loginInfo objectForKey:kSDKUsername];
        if (messageTextField.text.length > 0) {
            messageStr = [NSString stringWithFormat:@"%@：%@", username, messageTextField.text];
        }
        else{
            messageStr = [NSString stringWithFormat:NSLocalizedString(@"friend.somebodyInvite", @"%@ invite you as a friend"), username];
        }
        [self sendFriendApplyAtIndexPath:self.selectedIndexPath
                                 message:messageStr];
    }
}

- (void)sendFriendApplyAtIndexPath:(NSIndexPath *)indexPath
                           message:(NSString *)message
{
    NSString *buddyName = [self.dataSource objectAtIndex:indexPath.row];
    if (buddyName && buddyName.length > 0) {
        [self showHudInView:self.view hint:NSLocalizedString(@"friend.sendApply", @"sending application...")];
        EMError *error;
        [[EaseMob sharedInstance].chatManager addBuddy:buddyName message:message error:&error];
        [self hideHud];
        if (error) {
            [self showHint:NSLocalizedString(@"friend.sendApplyFail", @"send application fails, please operate again")];
        }
        else{
            [self showHint:NSLocalizedString(@"friend.sendApplySuccess", @"send successfully")];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end

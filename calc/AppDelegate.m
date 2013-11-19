//
//  AppDelegate.m
//  calc
//
//  Created by tujiaw on 13-11-17.
//  Copyright (c) 2013年 tujiaw. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

typedef enum SymbolTag {
    ADD = 10,
    SUBTRACT = 11,
    MULTIPLY = 12,
    DIVIDE = 13,
    DELETE = 14,
    EMPTY = 15,
    EQUAL = 16,
    PM = 17,
} SymbolTag;

typedef enum Status {
    START = 0x100,
    HISTROY = 0x101,
    COUNT = 0x102,
    RESULT = 0x103,
} Status;

Status g_status = START;
int g_result = 0;
BOOL g_lastIsSymbolClick = NO;

- (NSString*) getSymbolFromTag:(int)tag
{
    switch (tag)
    {
        case ADD:
            return @"+";
        case SUBTRACT:
            return @"-";
        case MULTIPLY:
            return @"*";
        case DIVIDE:
            return @"/";
    }
    return @"";
}

- (int) count:(int)val1 operator:(NSString*)oper andValue:(int)val2
{
    if ([oper isEqualToString:@"+"]) {
        return val1 + val2;
    } else if ([oper isEqualToString:@"-"]) {
        return val1 - val2;
    } else if ([oper isEqualToString:@"*"]) {
        return val1 * val2;
    } else if ([oper isEqualToString:@"/"]) {
        return val1 / val2;
    }
    return 0;
}

- (int) getOperCount:(NSString*)str
{
    int sum = 0;
    for (int i=0; i<str.length; i++) {
        unsigned char oper = [str characterAtIndex:i];
        if (oper=='+' || oper=='-' || oper=='*' || oper=='/') {
            ++sum;
        }
    }
    return sum;
}

- (void) deleteBtnClick
{
    if (g_lastIsSymbolClick) {
        return;
    }
    
    NSMutableString *strCurrent = [NSMutableString stringWithFormat:@"%@", _inputCurrent.text];
    int strLen = strCurrent.length;
    if (strLen > 2 || (strLen==2 && strCurrent.intValue > 0)) {
        _inputCurrent.text = [strCurrent substringToIndex:strCurrent.length-1];
    } else if (strLen == 1 || (strLen==2 && strCurrent.intValue < 0)) {
        _inputCurrent.text = @"0";
    }
}

- (void) emptyBtnClick
{
    g_status = START;
    _inputCurrent.text = @"0";
    _inputHistroy.text = @"";
}

- (void) pmBtnClick
{
    NSMutableString *strCurrent = [NSMutableString stringWithFormat:@"%@", _inputCurrent.text];
    if (strCurrent.length==0 || [strCurrent isEqualToString:@"0"]) {
        return;
    }
    
    unsigned char pm = [strCurrent characterAtIndex:0];
    if (pm == '-') {
        _inputCurrent.text = [strCurrent substringFromIndex:1];
    } else {
        [strCurrent insertString:@"-" atIndex:0];
        _inputCurrent.text = strCurrent;
    }
}

- (void) inputCurrentNumber:(int)tag
{
    if (tag >= 0 && tag <= 9) {
        g_lastIsSymbolClick = NO;
        NSMutableString *strCurrent = [NSMutableString stringWithFormat:@"%@", _inputCurrent.text];
        if (strCurrent.length > 0 && [strCurrent intValue] == 0) {
            if (tag == 0) {
                return;
            } else {
                [strCurrent setString:@""];
            }
        }
        [strCurrent appendString:[NSString stringWithFormat:@"%d", tag]];
        _inputCurrent.text = strCurrent;
    }
}

- (void) updateHistroy:(int)tag
{
    if (tag >= ADD && tag <= DIVIDE) {
        NSMutableString *strHistroy = [NSMutableString stringWithFormat:@"%@", _inputHistroy.text];
        NSMutableString *strCurrent = [NSMutableString stringWithFormat:@"%@", _inputCurrent.text];
        [strHistroy appendString:strCurrent];
        [strHistroy appendString:[self getSymbolFromTag:tag]];
        _inputHistroy.text = strHistroy;
        g_lastIsSymbolClick = YES;
    }
}

// + - * / 符号键被连续点击两次，则只更新历史框中的符号，不进行其他操作
    #define SYMBOL_CLICKED_TWINS \
    do {  \
        if (g_lastIsSymbolClick) { \
            NSMutableString *strHistroy = [NSMutableString stringWithFormat:@"%@", _inputHistroy.text]; \
            if (strHistroy.length > 1) { \
                [strHistroy setString:[strHistroy substringToIndex:strHistroy.length-1]]; \
                [strHistroy appendString:[self getSymbolFromTag:tag]]; \
                _inputHistroy.text = strHistroy; \
            } \
            return; \
        } \
    } while(0)

- (void) start:(id)sender andTag:(int)tag
{
    static BOOL s_isFirstEntry = YES;
    if (s_isFirstEntry) {
        s_isFirstEntry = NO;
        _inputHistroy.text = @"";
        _inputCurrent.text = @"0";
    }
 
    NSMutableString *strCurrent = [NSMutableString stringWithFormat:@"%@", _inputCurrent.text];
    if (tag >=0 && tag <=9) {
        [self inputCurrentNumber:tag];
    } else if (tag >= ADD && tag <= DIVIDE) {
        SYMBOL_CLICKED_TWINS;
        g_status = HISTROY;
        g_result = [strCurrent intValue];
        [self updateHistroy:tag];
    } else if (DELETE == tag) {
        [self deleteBtnClick];
    } else if (EMPTY == tag) {
        [self emptyBtnClick];
    } else if (PM == tag) {
        [self pmBtnClick];
    }
}

- (void) histroy:(id)sender andTag:(int)tag
{
    static BOOL s_isFirstEntry = YES;
    NSMutableString *strHistroy = [NSMutableString stringWithFormat:@"%@", _inputHistroy.text];
    NSMutableString *strCurrent = [NSMutableString stringWithFormat:@"%@", _inputCurrent.text];
    if (tag >=0 && tag <=9) {
        if (s_isFirstEntry) {
            s_isFirstEntry = NO;
            _inputCurrent.text = @"";
        }
        [self inputCurrentNumber:tag];
    } else if (tag >= ADD && tag <= DIVIDE) {
        SYMBOL_CLICKED_TWINS;
        
        [self updateHistroy:tag];
        s_isFirstEntry = YES;
        
        
        if (strHistroy.length > 0) {
            NSString *strOperater = [strHistroy substringFromIndex:strHistroy.length-1];
            g_result = [self count:g_result operator:strOperater andValue:[strCurrent intValue]];
        }
        _inputCurrent.text = [NSString stringWithFormat:@"%d", g_result];
    } else if (DELETE == tag) {
        [self deleteBtnClick];
    } else if (EMPTY == tag) {
        [self emptyBtnClick];
    } else if (EQUAL == tag) {
        if (strHistroy.length > 0) {
            s_isFirstEntry = YES;
            g_status = START;
            NSString *oper = [strHistroy substringFromIndex:strHistroy.length-1];
            g_result = [self count:g_result operator:oper andValue:[strCurrent intValue]];
            _inputCurrent.text = [NSString stringWithFormat:@"%d", g_result];
            _inputHistroy.text = @"";
        }
    } else if (PM == tag) {
        [self pmBtnClick];
    }
}

- (void) count:(id)sender andTag:(int)tag
{
    NSMutableString *strHistroy = [NSMutableString stringWithFormat:@"%@", _inputHistroy.text];
    NSMutableString *strCurrent = [NSMutableString stringWithFormat:@"%@", _inputCurrent.text];
    
    if (tag >= ADD && tag <= DIVIDE) {
        NSString *strOperater = [strHistroy substringFromIndex:strHistroy.length-1];
        g_result = [self count:g_result operator:strOperater andValue:[strCurrent intValue]];
        _inputCurrent.text = [NSString stringWithFormat:@"%d", g_result];
        g_status = HISTROY;
    } else if (DELETE == tag) {
        [self deleteBtnClick];
    } else if (EMPTY == tag) {
        [self emptyBtnClick];
    } else if (PM == tag) {
        [self pmBtnClick];
    }
}

- (void) result:(id)sender andTag:(int)tag
{
    if (tag >=0 && tag <=9) {
        [self start:sender andTag:tag];
    } else if (tag >= ADD && tag <= DIVIDE) {
        [self histroy:sender andTag:tag];
    } else if (EMPTY == tag) {
        
    } else if (EQUAL == tag) {
        
    }
}

- (void) allBtnClick:(id) sender
{
    UIButton *btn = (UIButton*)sender;
    if (btn)
    {
        switch (g_status)
        {
            case START:
                [self start:sender andTag:btn.tag];
                break;
                
            case HISTROY:
                [self histroy:sender andTag:btn.tag];
                break;
                
            case COUNT:
                [self count:sender andTag:btn.tag];
                break;
                
            case RESULT:
                [self result:sender andTag:btn.tag];
                break;
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    CGRect frameRect = [[UIScreen mainScreen] applicationFrame];
    int xSpace = 10, ySpace = 10, btnNormalWidth = 60, btnNormalHeight = 40;
    
    int x = xSpace, y = frameRect.origin.y + ySpace;
    _inputHistroy = [[UILabel alloc] init];
    _inputHistroy.frame = CGRectMake(x, y, btnNormalWidth*3 + xSpace*2, btnNormalHeight);
    _inputHistroy.layer.cornerRadius = 10;
    _inputHistroy.layer.borderColor = [UIColor grayColor].CGColor;
    _inputHistroy.layer.borderWidth = 1.5;
    _inputHistroy.text = @"";
    [self.window addSubview:_inputHistroy];
    
    x = x + _inputHistroy.frame.size.width + xSpace;
    _inputCurrent = [[UILabel alloc] init];
    _inputCurrent.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    _inputCurrent.layer.cornerRadius = 10;
    _inputCurrent.layer.borderColor = [UIColor grayColor].CGColor;
    _inputCurrent.layer.borderWidth = 1.5;
    _inputCurrent.text = @"0";
    [self.window addSubview:_inputCurrent];
    
    x = xSpace;
    y = y + btnNormalHeight + ySpace;
    UIButton *btn7 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn7.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btn7.tag = 7;
    [btn7 setTitle:@"7" forState:UIControlStateNormal];
    [btn7 addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btn7];
    
    x = x + btnNormalWidth + xSpace;
    UIButton *btn8 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn8.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btn8.tag = 8;
    [btn8 setTitle:@"8" forState:UIControlStateNormal];
    [btn8 addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btn8];
    
    x = x + btnNormalWidth + xSpace;
    UIButton *btn9 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn9.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btn9.tag = 9;
    [btn9 setTitle:@"9" forState:UIControlStateNormal];
    [btn9 addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btn9];
    
    x = x + btnNormalWidth + xSpace;
    UIButton *btnDivide = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnDivide.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btnDivide.tag = DIVIDE;
    [btnDivide setTitle:@"/" forState:UIControlStateNormal];
    [btnDivide addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btnDivide];
    
    x = xSpace;
    y = y + btnNormalHeight + ySpace;
    UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn4.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btn4.tag = 4;
    [btn4 setTitle:@"4" forState:UIControlStateNormal];
    [btn4 addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btn4];
    
    x = x + btnNormalWidth + xSpace;
    UIButton *btn5 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn5.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btn5.tag = 5;
    [btn5 setTitle:@"5" forState:UIControlStateNormal];
    [btn5 addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btn5];
    
    x = x + btnNormalWidth + xSpace;
    UIButton *btn6 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn6.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btn6.tag = 6;
    [btn6 setTitle:@"6" forState:UIControlStateNormal];
    [btn6 addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btn6];
    
    x = x + btnNormalWidth + xSpace;
    UIButton *btnMultiply = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnMultiply.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btnMultiply.tag = MULTIPLY;
    [btnMultiply setTitle:@"*" forState:UIControlStateNormal];
    [btnMultiply addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btnMultiply];
    
    
    x = xSpace;
    y = y + btnNormalHeight + ySpace;
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn1.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btn1.tag = 1;
    [btn1 setTitle:@"1" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btn1];
    
    x = x + btnNormalWidth + xSpace;
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn2.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btn2.tag = 2;
    [btn2 setTitle:@"2" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btn2];
    
    x = x + btnNormalWidth + xSpace;
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn3.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btn3.tag = 3;
    [btn3 setTitle:@"3" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btn3];
    
    x = x + btnNormalWidth + xSpace;
    UIButton *btnSubtract = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnSubtract.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btnSubtract.tag = SUBTRACT;
    [btnSubtract setTitle:@"-" forState:UIControlStateNormal];
    [btnSubtract addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btnSubtract];
    
    x = xSpace;
    y = y + btnNormalHeight + ySpace;
    UIButton *btn0 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn0.frame = CGRectMake(x, y, btnNormalWidth*2+xSpace, btnNormalHeight);
    btn0.tag = 0;
    [btn0 setTitle:@"0" forState:UIControlStateNormal];
    [btn0 addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btn0];
    
    x = x + btnNormalWidth*2 + xSpace*2;
    UIButton *btnPm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnPm.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btnPm.tag = PM;
    [btnPm setTitle:@"PM" forState:UIControlStateNormal];
    [btnPm addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btnPm];
    
    x = x + btnNormalWidth + xSpace;
    UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnAdd.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btnAdd.tag = ADD;
    [btnAdd setTitle:@"+" forState:UIControlStateNormal];
    [btnAdd addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btnAdd];
    
    x = xSpace;
    y = y + btnNormalHeight + ySpace;
    UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnDelete.frame = CGRectMake(x, y, btnNormalWidth*2+xSpace, btnNormalHeight);
    btnDelete.tag = DELETE;
    [btnDelete setTitle:@"Backspace" forState:UIControlStateNormal];
    [btnDelete addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btnDelete];
    
    x = x + btnNormalWidth*2 + xSpace*2;
    UIButton *btnNull = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnNull.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btnNull.tag = EMPTY;
    [btnNull setTitle:@"C" forState:UIControlStateNormal];
    [btnNull addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btnNull];
    
    x = x + btnNormalWidth + xSpace;
    UIButton *btnEqual = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnEqual.frame = CGRectMake(x, y, btnNormalWidth, btnNormalHeight);
    btnEqual.tag = EQUAL;
    [btnEqual setTitle:@"=" forState:UIControlStateNormal];
    [btnEqual addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.window addSubview:btnEqual];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

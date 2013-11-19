//
//  AppDelegate.h
//  calc
//
//  Created by tujiaw on 13-11-17.
//  Copyright (c) 2013年 tujiaw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UILabel *_inputHistroy;
    UILabel *_inputCurrent;
}
@property (strong, nonatomic) UIWindow *window;

@end

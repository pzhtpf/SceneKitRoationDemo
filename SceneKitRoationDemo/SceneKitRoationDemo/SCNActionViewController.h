//
//  SCNActionViewController.h
//  SceneKitRoationDemo
//
//  Created by tianpengfei on 16/5/8.
//  Copyright © 2016年 tianpengfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

@interface SCNActionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
- (IBAction)closeAction:(id)sender;

@property(strong,nonatomic)SCNView *scnView;

@end

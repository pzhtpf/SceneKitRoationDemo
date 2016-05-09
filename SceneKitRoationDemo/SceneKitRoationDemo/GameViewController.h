//
//  GameViewController.h
//  SceneKitRoationDemo
//

//  Copyright (c) 2016年 tianpengfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

@interface GameViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
- (IBAction)closeAction:(id)sender;

@property(nonatomic)int type;

@property(strong,nonatomic)SCNView *scnView;
@end

//
//  ViewController.m
//  EdgeAnimationDemo
//
//  Created by lizq on 16/8/17.
//  Copyright © 2016年 zqLee. All rights reserved.
//

#import "ViewController.h"
#import "UIView+EdgeAnimation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view setEdgeFillColor: [UIColor redColor]];
    // Do any additional setup after loading the view, typically from a nib.
//    NSLog(@"view pan == %p", panGesture);

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(pan:)];
    [self.view addGestureRecognizer:panGesture];
    NSLog(@"55    pan == %p", panGesture);
    [self.view addEdgeEffect];


    for (UIGestureRecognizer *gesture in self.view.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            NSLog(@"forin    pan == %p", gesture);
        }
    }


}
- (void)pan:(UIPanGestureRecognizer *)pan {

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

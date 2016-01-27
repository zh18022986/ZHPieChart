//
//  ViewController.m
//  ZHPieChart
//
//  Created by zhouhao on 16/1/15.
//  Copyright © 2016年 zhouhao. All rights reserved.
//

#import "ViewController.h"
#import "ZHPieChartViewController.h"

@interface ViewController ()
@property (strong ,nonatomic) UIButton *button;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonClick{
    ZHPieChartViewController* vc = [ZHPieChartViewController new];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (UIButton *)button{
    if (_button == nil) {
        _button = [[UIButton alloc] initWithFrame:CGRectMake(15, 100, self.view.frame.size.width - 20, 44)];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.backgroundColor = [UIColor redColor];
        _button.titleLabel.font = [UIFont systemFontOfSize:15.f];
        [_button setTitle:@"test" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
@end

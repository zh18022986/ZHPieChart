//
//  ZHPieChartViewController.m
//  ZHPieChart
//
//  Created by zhouhao on 16/1/15.
//  Copyright © 2016年 zhouhao. All rights reserved.
//

#import "ZHPieChartViewController.h"
#import "ZHPieView.h"
#import "MyPieElement.h"

#define     NYColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define kMinTouchSpacing 20.0
#define         RIDO_TO_5S              [[UIScreen mainScreen] bounds].size.width / 320.0

typedef NS_ENUM(NSUInteger, Direction) {
    DirectionUnknown,
    DirectionLeft,//逆时针
    DirectionRight//顺时针
};

@interface ZHPieChartViewController (){
    NSArray *items;
    
}
@property (weak, nonatomic) IBOutlet ZHPieView *pieView;
@property (assign, nonatomic) Direction lastDirection; //最后一次方向
@property (assign, nonatomic) CGPoint currentTickleStart; //当前开始坐标位置
@property (assign, nonatomic) NSInteger index;
@property (nonatomic ,strong) NSArray *colorArray;
@property (nonatomic ,strong) NSArray *dateArray;
@property (nonatomic ,strong) UIView *centerView;
@property (nonatomic ,strong) UILabel *levelLabel;

- (IBAction)addBtnClick:(id)sender;
- (IBAction)deleteBtnClick:(id)sender;
- (IBAction)updateBtnClick;

@end

@implementation ZHPieChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.index = 6;
    items = @[[MyPieElement pieElementWithValue:20 color:self.colorArray[0]],
              [MyPieElement pieElementWithValue:5 color:self.colorArray[1]],
              [MyPieElement pieElementWithValue:5 color:self.colorArray[2]],
              [MyPieElement pieElementWithValue:20 color:self.colorArray[3]],
              [MyPieElement pieElementWithValue:25 color:self.colorArray[4]],
              [MyPieElement pieElementWithValue:5 color:self.colorArray[5]],
              [MyPieElement pieElementWithValue:20 color:self.colorArray[6]]
              ];
    //初始化创建6个模块
    for(int i = 0; i < items.count; i++){
        MyPieElement* newElem = items[i];
        [self.pieView.layer addValues:@[newElem] animated:NO];
    }
    self.pieView.layer.transformTitleBlock = ^(PieElement* elem, float percent){
        return [NSString stringWithFormat:@"%ld", (long)percent];
    };
    self.pieView.layer.showTitles = ShowTitlesAlways;
    [self.pieView addSubview:self.centerView];
}

- (NSArray *)colorArray{
    _colorArray = @[NYColor(97, 223, 246),
                    NYColor(0, 198, 189),
                    NYColor(251, 129, 80),
                    NYColor(0, 66, 126),
                    NYColor(112, 188, 225),
                    NYColor(124, 40, 36),
                    NYColor(247, 42, 38)];
    return _colorArray;
}

//添加
- (IBAction)addBtnClick:(id)sender {
    MyPieElement* newElem = [MyPieElement pieElementWithValue:10 color:self.colorArray[1]];
    newElem.title = [NSString stringWithFormat:@"%d", 10];
    int insertIndex = (unsigned)self.pieView.layer.values.count;
    [self.pieView.layer insertValues:@[newElem] atIndexes:@[@(insertIndex)] animated:YES];
}

- (IBAction)deleteBtnClick:(id)sender {
    if(self.pieView.layer.values.count <= 0)
        return;
    int deleteIndex = (unsigned)self.pieView.layer.values.count-1;
    [self.pieView.layer deleteValues:@[self.pieView.layer.values[deleteIndex]] animated:YES];
}

- (IBAction)updateBtnClick {
    if(self.pieView.layer.values.count == 0)
        return;
    int randCount = MAX(MIN(self.pieView.layer.values.count, 2), arc4random() % self.pieView.layer.values.count);
    NSMutableArray* randIndexes = [NSMutableArray new];
    NSMutableArray* changeValArr = [NSMutableArray new];
    [PieElement animateChanges:^{
        if(self.pieView.layer.values.count <= 0)
            return;
        int deleteIndex = (unsigned)self.pieView.layer.values.count-1;
        for (int i = 0;i<= deleteIndex; i++) {
            
        }
        for(int i = 0; i < randCount; i++){
            int randIndx = arc4random() % self.pieView.layer.values.count;
            while ([randIndexes containsObject:@(randIndx)]) {
                randIndx = arc4random() % self.pieView.layer.values.count;
            }
            [randIndexes addObject:@(randIndx)];
            int randVal = (5 + arc4random() % 10);
            int prevVal = [(PieElement*)self.pieView.layer.values[randIndx] val];
            [self.pieView.layer.values[randIndx] setVal:randVal];
            [changeValArr addObject:[NSString stringWithFormat:@"%d -> %d", prevVal, randVal]];
        }
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _currentTickleStart = [touch locationInView:self.view]; //设置当前开始坐标位置
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint tickleEnd = [touch locationInView:self.view];
    //『当前开始坐标位置』和『移动后坐标位置』进行 X 轴值比较，得到是向右还是向左移动
    CGFloat tickleSpacingX = tickleEnd.x - _currentTickleStart.x;
    //『当前开始坐标位置』和『移动后坐标位置』进行 Y 轴值比较，得到是向下还是向上移动
    CGFloat tickleSpacingY = tickleEnd.y - _currentTickleStart.y;
    CGPoint center = self.pieView.center;
    //移动的 X 轴间距值是否符合要求，足够大
    if (ABS(tickleSpacingX) >= kMinTouchSpacing && ABS(tickleSpacingY) >= kMinTouchSpacing) {
        if (ABS(tickleSpacingX) > ABS(tickleSpacingY)) {
            if (tickleEnd.y < center.y) {
                if (tickleSpacingX > 0) {
                    self.lastDirection = DirectionRight;
                }else{
                    self.lastDirection = DirectionLeft;
                }
            }else{
                if (tickleSpacingX > 0) {
                    self.lastDirection = DirectionLeft;
                }else{
                    self.lastDirection = DirectionRight;
                }
            }
        }else{
            if (tickleEnd.x < center.x) {
                if (tickleSpacingY > 0) {
                    self.lastDirection = DirectionLeft;
                }else{
                    self.lastDirection = DirectionRight;
                }
            }else{
                if (tickleSpacingY > 0) {
                    self.lastDirection = DirectionRight;
                }else{
                    self.lastDirection = DirectionLeft;
                }
            }
        }
        _currentTickleStart = [touch locationInView:self.view]; //设置当前开始坐标位置
        [PieElement animateChanges:^{
            if (self.lastDirection == DirectionLeft) {
                self.index --;
                for (int i = 0; i< self.pieView.layer.values.count; i++) {
                    [self.pieView.layer.values[i] setVal:[self.dateArray[self.index][i] floatValue]];
                }
            }else{
                self.index ++;
                for (int i = 0; i< self.pieView.layer.values.count; i++) {
                    [self.pieView.layer.values[i] setVal:[self.dateArray[self.index][i] floatValue]];
                }
            }
            self.levelLabel.text = [NSString stringWithFormat:@"%ld",(long)self.index];
        }];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (NSInteger)index{
    if (_index < 0) {
        _index = 0;
    }
    if (_index > 10) {
        _index = 10;
    }
    return _index;
}

- (NSArray *)dateArray{
    if (_dateArray == nil) {
        //        _dateArray = [[NSMutableArray alloc] init];
        _dateArray = @[@[@100,@0,@0,@0,@0,@0,@0],
                       @[@50,@50,@0,@0,@0,@0,@0],
                       @[@44,@44,@2,@2,@4,@5,@2],
                       @[@38,@38,@2,@2,@8,@10,@2],
                       @[@32,@32,@3,@3,@12,@15,@3],
                       @[@26,@4,@4,@16,@20,@4,@26],
                       @[@20,@5,@5,@20,@25,@5,@20],
                       @[@16,@6,@6,@23,@28,@5,@16],
                       @[@13,@8,@8,@25,@29,@5,@13],
                       @[@9,@27,@32,@5,@9,@9,@9],
                       @[@10,@30,@35,@5,@5,@5,@10]];
    }
    return _dateArray;
}

- (UIView *)centerView{
    if (_centerView == nil) {
        _centerView = [[UIView alloc] initWithFrame:CGRectMake(127,55, self.pieView.layer.minRadius*2, self.pieView.layer.minRadius*2)];
        _centerView.layer.cornerRadius = 80.f;
        _centerView.layer.masksToBounds = YES;
//        _centerView.backgroundColor = [UIColor redColor];
        _centerView.backgroundColor = [UIColor whiteColor];
        
        UILabel *fengXian = [[UILabel alloc] initWithFrame:CGRectMake(55, 20, 60, 30)];
        fengXian.text = @"风险偏好";
        fengXian.font = [UIFont systemFontOfSize:12];
        fengXian.textColor = [UIColor grayColor];
        self.levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 50, 50, 50)];
        self.levelLabel.text = [NSString stringWithFormat:@"%ld",(long)self.index];
        self.levelLabel.font = [UIFont systemFontOfSize:40.f];
        
        [_centerView addSubview:self.levelLabel];
        [_centerView addSubview:fengXian];

    }
    return _centerView;
}
@end

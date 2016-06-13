//
//  ViewController.m
//  dr-ChartsExample
//
//  Created by DHIREN THIRANI on 6/13/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import "ViewController.h"
#import "PageViewController.h"
#import "DrGraphs.h"

#define header_height 60

#define CHART_LINE 0
#define CHART_HORIZONTAL_STACK 1
#define CHART_PIE 2
#define CHART_BAR 3
#define CHART_CIRCULAR 4

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self createViews];
}

- (void)createViews{
    [self createHeader];
    [self createTableView];
}

- (void)createHeader{
    [self.navigationItem setTitle:@"Charts"];
}

-(void)createTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH(self.view), HEIGHT(self.view))];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor lightGrayColor]] ;
    [self.tableView setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
}

#pragma mark TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case CHART_LINE:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"line_chart_cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"line_chart_cell"];
                [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            }
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), 60)];
            [titleLabel setText:@"Line Chart"];
            [titleLabel setTextColor:[UIColor blackColor]];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            [cell addSubview:titleLabel];
            return cell;
        }
            break;
        case CHART_HORIZONTAL_STACK:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"horizontal_chart_cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"horizontal_chart_cell"];
                [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            }
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), 60)];
            [titleLabel setText:@"Horizontal Stack Chart"];
            [titleLabel setTextColor:[UIColor blackColor]];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            [cell addSubview:titleLabel];
            return cell;
        }
            break;
        case CHART_PIE:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pie_chart_cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pie_chart_cell"];
                [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            }
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), 60)];
            [titleLabel setText:@"Pie Chart"];
            [titleLabel setTextColor:[UIColor blackColor]];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            [cell addSubview:titleLabel];
            return cell;
        }
            break;
        case CHART_BAR:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pie_chart_cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pie_chart_cell"];
                [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            }
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), 60)];
            [titleLabel setText:@"Bar Chart"];
            [titleLabel setTextColor:[UIColor blackColor]];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            [cell addSubview:titleLabel];
            return cell;
        }
            break;
        case CHART_CIRCULAR:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"circular_chart_cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"circular_chart_cell"];
                [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            }
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), 60)];
            [titleLabel setText:@"Circular Chart"];
            [titleLabel setTextColor:[UIColor blackColor]];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            [cell addSubview:titleLabel];
            return cell;
        }
            break;
            
        default:
            break;
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case CHART_LINE:
        {
            PageViewController *pageController = [[PageViewController alloc] initWithChartType:ChartTypeLine];
            [self.navigationController pushViewController:pageController animated:YES];
        }
            break;
        case CHART_HORIZONTAL_STACK:
        {
            PageViewController *pageController = [[PageViewController alloc] initWithChartType:ChartTypeHorizontalStack];
            [self.navigationController pushViewController:pageController animated:YES];
        }
            break;
        case CHART_PIE:
        {
            PageViewController *pageController = [[PageViewController alloc] initWithChartType:ChartTypePie];
            [self.navigationController pushViewController:pageController animated:YES];
        }
            break;
        case CHART_BAR:
        {
            PageViewController *pageController = [[PageViewController alloc] initWithChartType:ChartTypeBar];
            [self.navigationController pushViewController:pageController animated:YES];
        }
            break;
        case CHART_CIRCULAR:
        {
            PageViewController *pageController = [[PageViewController alloc] initWithChartType:ChartTypeCircular];
            [self.navigationController pushViewController:pageController animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

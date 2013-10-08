//
//  ViewController.m
//  AppleBugTest
//
//  Created by Holger Bohlmann on 08.10.13.
//  Copyright (c) 2013 Holger Bohlmann. All rights reserved.
//

#import "ViewController.h"

static NSInteger cellCount = 0;

@interface MyCell : UITableViewCell

@end

@implementation MyCell : UITableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellCount++;
    }
    return self;
}

-(void)dealloc {
    cellCount--;
}

@end

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) BOOL syncFinish;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self setTitle:[NSString stringWithFormat:@"Depth %d", (int)self.navigationController.viewControllers.count]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Count" style:UIBarButtonSystemItemAction target:self action:@selector(showCount)];
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.frame = self.view.bounds;
    
    __weak ViewController *weakSelf = self;
    
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        __strong ViewController *strongSelf = weakSelf;
        if(strongSelf) {
            strongSelf.syncFinish = YES;
            // Under iOS7: The table will be retained! Memory-Leak
            // Run < iOS7: Everything is okay
            [strongSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            // If you reload the whole table, its okay in every iOS Verion
            // [strongSelf.tableView reloadData];
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showCount {
    [[[UIAlertView alloc] initWithTitle:@"Number of my Cells"
                                message:[NSString stringWithFormat:@"%d", (int)cellCount]
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"Okay", nil] show];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
    
    if(cell == nil) {
        cell = [[MyCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"MyCell"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *item = [NSString stringWithFormat:@"%@ - %@", @(indexPath.section), @(indexPath.row)];
    
    if(self.syncFinish && indexPath.section == 1) {
        item = [item stringByAppendingString:@" (SYNCED)"];
    }
    
    [cell.detailTextLabel setText:item];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22.0f;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.navigationController pushViewController:[[ViewController alloc] init] animated:YES];
}

@end

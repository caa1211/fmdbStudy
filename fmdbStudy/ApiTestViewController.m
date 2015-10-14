//
//  ApiTestViewController.m
//  fmdbStudy
//
//  Created by Carter Chang on 10/14/15.
//  Copyright © 2015 Carter Chang. All rights reserved.
//

#import "ApiTestViewController.h"
#import "DatabaseManager.h"

@interface ApiTestViewController ()
@property(nonatomic, strong)FMDatabaseQueue *dbQueue;
@end

@implementation ApiTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//      UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Dismiss"] style:UIBarButtonItemStylePlain target:self action:@selector(onClose:)];
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"close" style:UIBarButtonItemStylePlain target:self action:@selector(onClose:)];
      self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:closeBtn,nil];
    
    self.dbQueue = [[DatabaseManager sharedManager] queue];
    
    // Do any additional setup after loading the view from its nib.
}

-(void) onClose:(id) sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onAddFavList:(id)sender {
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSNumber *timestamp = [DatabaseManager generateTimestamp];
        NSString *favListName = @"星期天記得買";
        [db executeUpdate:@"INSERT INTO favoriteList(name,ts) VALUES (?, ?)", favListName, timestamp];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

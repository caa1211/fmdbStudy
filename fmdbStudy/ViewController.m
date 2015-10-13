//
//  ViewController.m
//  fmdbStudy
//
//  Created by Carter Chang on 10/13/15.
//  Copyright © 2015 Carter Chang. All rights reserved.
//

#import "ViewController.h"
#import <FMDatabase.h>
#import <FMDatabaseAdditions.h>

@interface ViewController ()

@end

@implementation ViewController

FMDatabase *database;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)onCreateDB:(id)sender {
    
    //Create Database
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"shoppingGuide.sqlite"];
    
    NSLog(@"path is %@",docsPath);
    database = [FMDatabase databaseWithPath:path];
    
    if(![database open]){
        NSLog(@"DB Can't Open");
    }
    
    //Create Table
    [database executeUpdate:@"CREATE TABLE IF NOT EXISTS favoriteList(id INTEGER primary key, name TEXT, ts TIMESTAMP)"];

    
    [database close];
}

- (IBAction)onDeleteTable:(id)sender {
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir   stringByAppendingPathComponent:@"shoppingGuide.sqlite"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    if(![database open]){
        NSLog(@"DB Can't Open");
    }
    
    [database executeUpdate:@"DROP TABLE favoriteList"];
    
    [database close];

}


- (IBAction)onInsert:(id)sender {
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir   stringByAppendingPathComponent:@"shoppingGuide.sqlite"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    if(![database open]){
        NSLog(@"DB Can't Open");
    }
    
    NSNumber *timestamp = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
    NSString *name = @"星期天記得買2";
    NSInteger favId = [NSNumber numberWithInt:20];
   
    [database executeUpdate:@"INSERT INTO favoriteList(id,name,ts) VALUES (?, ?, ?)", favId, name, timestamp];
    [database close];
}


//Update

- (IBAction)onDelete:(id)sender {
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir   stringByAppendingPathComponent:@"shoppingGuide.sqlite"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    if(![database open]){
        NSLog(@"DB Can't Open");
    }
    
    [database executeUpdate:@"DELETE FROM favoriteList WHERE id=20"];
    
    [database close];
}


- (IBAction)onUpdate:(id)sender {
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir   stringByAppendingPathComponent:@"shoppingGuide.sqlite"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    if(![database open]){
        NSLog(@"DB Can't Open");
    }

    
    NSNumber *timestamp = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
    NSInteger favId = [NSNumber numberWithInt:20];
    
    [database executeUpdate:@"UPDATE favoriteList SET ts=? WHERE id=?", timestamp, favId];
    
}



- (IBAction)onSelect:(id)sender {
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir   stringByAppendingPathComponent:@"shoppingGuide.sqlite"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    if(![database open]){
        NSLog(@"DB Can't Open");
    }
    
    FMResultSet *results = [database executeQuery:@"SELECT * FROM favoriteList"];
    while([results next]) {
        NSString *name = [results stringForColumn:@"name"];
        NSInteger id  = [results intForColumn:@"id"];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[results objectForColumnName:@"ts"] integerValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *formatedTime = [dateFormatter stringFromDate:date];
        
        NSLog(@"favorite: %@ - %ld - %@",name, id, formatedTime);
    }
    [database close];
}

- (IBAction)onSelectByName:(id)sender {
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir   stringByAppendingPathComponent:@"shoppingGuide.sqlite"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    if(![database open]){
        NSLog(@"DB Can't Open");
    }
    
    FMResultSet *results = [database executeQuery:@"SELECT * FROM favoriteList WHERE name=?",@"星期天記得買2"];
    while([results next]) {
        NSString *name = [results stringForColumn:@"name"];
        NSInteger id  = [results intForColumn:@"id"];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[results objectForColumnName:@"ts"] integerValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *formatedTime = [dateFormatter stringFromDate:date];
        
        NSLog(@"favorite: %@ - %ld - %@",name, id, formatedTime);
    }
    [database close];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

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

+ (FMDatabase*)sharedDatabase
{
    static FMDatabase* sharedDatabase = nil;
    if (sharedDatabase == nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsPath = [paths objectAtIndex:0];
        NSString *path = [docsPath stringByAppendingPathComponent:@"shoppingGuide.sqlite"];
        
        NSLog(@"path is %@",docsPath);
        sharedDatabase = [FMDatabase databaseWithPath:path];
    }
    return sharedDatabase;
}

+ (void) tableCreator:(NSString*)tableName schema:(NSString*)schema {
    FMDatabase *database = [ViewController sharedDatabase];
    NSString *sqlCreateCmd = @"CREATE TABLE IF NOT EXISTS";
    [database executeUpdate:[NSString stringWithFormat:@"%@ %@(%@)",sqlCreateCmd, tableName, schema]];
}

+ (NSNumber *) generateTimestamp {
    return [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)onCreateDB:(id)sender {
    
    //Create Database

    FMDatabase *database = [ViewController sharedDatabase];
    
    NSString *productSchema = @"id TEXT PRIMARY KEY, image TEXT, title TEXT, market TEXT, desc TEXT, price INTEGER, url TEXT";
    
    //Create Table
//    [database executeUpdate:@"CREATE TABLE IF NOT EXISTS favoriteList(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, ts TIMESTAMP)"];
    
    if(![database open]){
        NSLog(@"DB Can't Open");
    }

    [ViewController tableCreator:@"favoriteList" schema:@"id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, ts TIMESTAMP"];
    [ViewController tableCreator:@"favoriteItem" schema:[NSString stringWithFormat:@"%@, %@", productSchema, @"listId INTEGER"]];
    [ViewController tableCreator:@"viewHistory" schema:[NSString stringWithFormat:@"%@, %@", productSchema, @"ts TIMESTAMP"]];
    [ViewController tableCreator:@"searchHistory" schema:@"id INTEGER PRIMARY KEY AUTOINCREMENT, keyword TEXT"];
    
    [database close];
}

- (IBAction)onDeleteTable:(id)sender {
    FMDatabase *database = [ViewController sharedDatabase];
    
    if(![database open]){
        NSLog(@"DB Can't Open");
    }
    
    [database executeUpdate:@"DROP TABLE favoriteList"];
    [database executeUpdate:@"DROP TABLE favoriteItem"];
    [database executeUpdate:@"DROP TABLE viewHistory"];
    [database executeUpdate:@"DROP TABLE searchHistory"];
    
    [database close];
}


- (IBAction)onInsert:(id)sender {
    FMDatabase *database = [ViewController sharedDatabase];
    if(![database open]){
        NSLog(@"DB Can't Open");
    }
    
    NSNumber *timestamp = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
    NSString *name = @"星期天記得買2";
   
    [database executeUpdate:@"INSERT INTO favoriteList(name,ts) VALUES ( ?, ?)", name, timestamp];

    [database close];
}

- (IBAction)onDelete:(id)sender {
    FMDatabase *database = [ViewController sharedDatabase];
    if(![database open]){
        NSLog(@"DB Can't Open");
    }
    
    [database executeUpdate:@"DELETE FROM favoriteList WHERE id=1"];
    
    [database close];
}


- (IBAction)onUpdate:(id)sender {
    
    FMDatabase *database = [ViewController sharedDatabase];
    if(![database open]){
        NSLog(@"DB Can't Open");
    }

    NSNumber *timestamp = [ViewController generateTimestamp];
    NSInteger favId = [NSNumber numberWithInt:1];
    
    [database executeUpdate:@"UPDATE favoriteList SET ts=? WHERE id=?", timestamp, favId];
    
    [database close];
}



- (IBAction)onSelect:(id)sender {
    
    FMDatabase *database = [ViewController sharedDatabase];
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
    
    FMDatabase *database = [ViewController sharedDatabase];
    
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

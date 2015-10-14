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
    
    if(![database open]){
        NSLog(@"DB Can't Open");
    }

    [database beginTransaction];
    [ViewController tableCreator:@"favoriteList" schema:@"id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE, ts TIMESTAMP"];

    [ViewController tableCreator:@"favoriteListToItem" schema:@"favListId INTEGER, favProductId TEXT, FOREIGN KEY(favListId) REFERENCES favoriteList(id), FOREIGN KEY(favProductId) REFERENCES favoriteItem(productId), UNIQUE (favListId, favProductId)"];
    
    [ViewController tableCreator:@"favoriteItem" schema:@"productId TEXT PRIMARY KEY, image TEXT, title TEXT, market TEXT, desc TEXT, price INTEGER, url TEXT, ts TIMESTAMP"];
    
    [ViewController tableCreator:@"viewHistory" schema:@"productId TEXT PRIMARY KEY, image TEXT, title TEXT, market TEXT, desc TEXT, price INTEGER, url TEXT, ts TIMESTAMP"];
    
    [ViewController tableCreator:@"searchHistory" schema:@"keyword TEXT PRIMARY KEY, ts TIMESTAMP"];
    [database commit];
    
    [database close];
}

- (IBAction)onInsertSearchHistory:(id)sender {
    NSInteger maxSearchHistory = 10;
    FMDatabase *database = [ViewController sharedDatabase];
    [database open];
    
    [database beginTransaction];
    NSNumber *timestamp = [ViewController generateTimestamp];
    NSString *keyword = @"iphone";
    
    // Update or insert
    if (![database executeUpdate:@"UPDATE searchHistory SET ts=? WHERE keyword=?", timestamp, keyword]) {
        [database executeUpdate:@"INSERT INTO searchHistory(keyword, ts) VALUES (?, ?)", @"iphone", timestamp];
        [database executeUpdate: [NSString stringWithFormat:@"DELETE FROM searchHistory WHERE ts NOT IN (SELECT ts FROM searchHistory ORDER BY -ts LIMIT %ld)", maxSearchHistory]];
    }
    
    [database commit];
    
    [database close];
}

- (IBAction)onInsertFavItem:(id)sender {
    FMDatabase *database = [ViewController sharedDatabase];
    if(![database open]){
        NSLog(@"DB Can't Open");
    }

    [database executeUpdate:@"PRAGMA foreign_keys = YES"];

    NSNumber *favListId = [NSNumber numberWithInteger:1];
    NSString *favProductId = @"A12345";
    
    [database beginTransaction];
    [database executeUpdate:@"INSERT INTO favoriteItem(productId, title) VALUES (?, ?)", favProductId, @"黑心商品"];
    
    if(![database executeUpdate:@"INSERT INTO favoriteListToItem(favListId, favProductId) VALUES (?, ?)", favListId, favProductId]){
        [database rollback];
    }else{
        [database commit];
    }
    
    [database close];
}


- (IBAction)onDeleteTable:(id)sender {
    FMDatabase *database = [ViewController sharedDatabase];
    
    if(![database open]){
        NSLog(@"DB Can't Open");
    }
    
    [database beginTransaction];
    [database executeUpdate:@"DROP TABLE IF EXISTS favoriteList"];
    [database executeUpdate:@"DROP TABLE IF EXISTS favoriteListToItem"];
    [database executeUpdate:@"DROP TABLE IF EXISTS favoriteItem"];
    [database executeUpdate:@"DROP TABLE IF EXISTS viewHistory"];
    [database executeUpdate:@"DROP TABLE IF EXISTS searchHistory"];
    [database commit];
    
    [database close];
}


- (IBAction)onInsert:(id)sender {
    FMDatabase *database = [ViewController sharedDatabase];
    if(![database open]){
        NSLog(@"DB Can't Open");
    }
    
    NSNumber *timestamp = [ViewController generateTimestamp];
    NSString *favListName = @"星期天記得買";
   
    [database executeUpdate:@"INSERT INTO favoriteList(name,ts) VALUES (?, ?)", favListName, timestamp];

    [database close];
}

- (IBAction)onDelete:(id)sender {
    FMDatabase *database = [ViewController sharedDatabase];
    if(![database open]){
        NSLog(@"DB Can't Open");
    }
 
    [database beginTransaction];
    NSNumber *favListId = [NSNumber numberWithInteger:1];
    [database executeUpdate:[NSString stringWithFormat:@"DELETE FROM favoriteList WHERE id=%@",favListId]];
    [database executeUpdate:[NSString stringWithFormat:@"DELETE FROM favoriteListToItem WHERE favListId=%@",favListId]];
    // Remove the favItems which are not existed in favoriteListToItem
    [database executeUpdate:[NSString stringWithFormat:@"DELETE FROM favoriteItem WHERE productId NOT IN (SELECT favProductId FROM favoriteListToItem)"]];
    [database commit];
    
    [database close];
}

- (IBAction)onDeleteMultipleFav:(id)sender {
    FMDatabase *database = [ViewController sharedDatabase];
    if(![database open]){
        NSLog(@"DB Can't Open");
    }
    [database executeUpdate:[NSString stringWithFormat:@"DELETE FROM favoriteList WHERE id IN ('1', '2', '3', '4')"]];
    [database close];
}

- (IBAction)onUpdate:(id)sender {
    
    FMDatabase *database = [ViewController sharedDatabase];
    if(![database open]){
        NSLog(@"DB Can't Open");
    }

    NSNumber *timestamp = [ViewController generateTimestamp];
    NSNumber *favId = [NSNumber numberWithInt:1];
    
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
    
    FMResultSet *results = [database executeQuery:@"SELECT * FROM favoriteList WHERE name=?",@"星期天記得買"];
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

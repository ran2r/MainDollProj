//
//  dataBase.h
//  BetaDoll
//
//  Created by ran turgeman on 7/5/11.
//  Copyright 2011 seebo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h> 

@interface dataBase : NSObject {
    
	NSString *name;
	NSString *basic_pic;
	NSString *event;
	NSString *spriteSheet;
	NSString *sound;
    NSString *parentMode;
	NSString *nextMode;
	NSMutableArray *rowInDataBase;
	
	
	// Database variables
	NSString *databaseName;
	NSString *databasePath;
	
	// Array to store the animal objects
	NSMutableArray *animals;
    
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *pic;
@property (nonatomic, retain) NSString *spriteSheet;;
@property (nonatomic, retain) NSString *sound;
@property (nonatomic, retain) NSString *event;
@property (nonatomic, retain) NSString *nextMode;
@property (nonatomic, retain) NSString *parentMode;
@property (nonatomic, retain) NSMutableArray *rowInDataBase;

//-(id)initWithName:(NSString *)n pic:(NSString *)b ;
- (void)setupDataBase;
-(void) checkAndCreateDatabase;
-(NSMutableArray*) readMediaFromDatabase:(NSString *)awaking_event;
-(NSString*) readEventFromDatabase:(NSMutableArray *)triger;


@end
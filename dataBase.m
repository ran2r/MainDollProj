//
//  dataBase.m
//  BetaDoll
//
//  Created by ran turgeman on 7/5/11.
//  Copyright 2011 seebo. All rights reserved.
//

#import "dataBase.h"
#include <stdlib.h>

@implementation dataBase
@synthesize name, pic,spriteSheet,sound,event,rowInDataBase;
@synthesize parentMode,nextMode;



const char *sql_for_event;
BOOL flags =0;
int s=0; // to calaculate the probability 

//roads portishead

- (void)setupDataBase
{	
	
	//NSLog(@"setupDataBase");
	// Setup some globals
	databaseName = @"DeerNice.sqlite";
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	
	// Execute the "checkAndCreateDatabase" function
	[self checkAndCreateDatabase];
	
    
    
}




-(void) checkAndCreateDatabase
{
	//NSLog(@"checkandcreate");
	
	
	// Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL success;
	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:databasePath];
	
	// If the database already exists then return without doing anything
	if(success) return;
	
	// If not then proceed to copy the database from the application to the users filesystem
	
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
	// Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	
	[fileManager release];
	
	
	
}




// first table where we get the event according to the sensor/touch coordinates
-(NSString*) readEventFromDatabase:(NSMutableArray *)triger
{
	//---------------read current mode from the plist, and if null(first time) give it regular mode
	
	
    //get touch/sensor parameters
	NSString *X,*Y;
    
    
	X=[triger objectAtIndex:0]; //coordinates
	Y=[triger objectAtIndex:1];
    
	
    
	
	
    //NSLog(@"%@",Y);
	//NSLog(@"%@",X);
	
	if(![Y isEqualToString:@"0"] && ![X isEqualToString:@"0"]) //TOUCH TRIGER
        sql_for_event= [[NSString stringWithFormat:@"SELECT * FROM DeerNoiseLowLevel WHERE minX<'%@' AND maxX>'%@' AND minY<'%@' AND maxY>'%@'",X,X,Y,Y] UTF8String];
	else //SENSOR TRIGER
		sql_for_event= [[NSString stringWithFormat:@"SELECT * FROM DeerNoiseLowLevel WHERE sensor='%@' ",X] UTF8String];
	
	
	//added!!!!!
	//sql_for_event= [[NSString stringWithFormat:@"SELECT * FROM dollDataBase WHERE event='check' AND name='regular'"] UTF8String];
	
	// Setup the database object
	sqlite3 *database;
	
	
	//NSLog(@"%s",sql_for_event);		// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK ) 
	{
		// Setup the SQL Statement and compile it for faster access
		const char *sqlStatement = sql_for_event; //"select * from dollDataBase"; //sql_for_event;
		sqlite3_stmt *compiledStatement;
		
		//int retVal = sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) ;
		//NSLog( @"Returned value = %d", retVal) ;
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
		{
            
			//NSLog(@"%s",sql_for_event);				
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW)
			{
				
				// Read the data from the result row
				event = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)]; //each cycle aName gets 1 row
                
				
			}
			
            
		}
        
		//NSLog(@"%@",event);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	
	sqlite3_close(database);
	
    
	return event;      // and then we go to the second table with this even
}













// second table where we input the event from previos table and get the media



-(NSMutableArray*) readMediaFromDatabase:(NSString *)awaking_event
{
	
	
	//create random number to choose event
	int random = arc4random() % 100;
	NSLog(@"random:%d",random);
	
	//initialize s
	s=0;
	
	
	
	
	//---------------read current mode from the plist, and if null(first time) give it regular mode
	
    
	NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docDirectory = [arrayPaths objectAtIndex:0];
	NSString *filePath = [docDirectory stringByAppendingString:@"/File.txt"];
	parentMode = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	if(flags==0)
	{
		flags=1;
		parentMode= @"regular";
	}
	
	
	//parentMode=@"regular";
	sql_for_event= [[NSString stringWithFormat:@"SELECT * FROM DeerNoise WHERE (event='%@' OR event='%@') AND name='%@' ",awaking_event,@"any",parentMode] UTF8String];
    
	
	
	// Setup the database object
    sqlite3 *database;
    
    
	
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK ) 
	{
        
		// Setup the SQL Statement and compile it for faster access
		const char *sqlStatement = sql_for_event; //"select * from dollDataBase"; //sql_for_event;
		sqlite3_stmt *compiledStatement;
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
		{
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW)
			{
				
				// Read the data from the result row
				name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)]; //each cycle aName gets 1 row
				basic_pic = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];// we read db like that: 1-> linedown 2-> 
				spriteSheet = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
				sound = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
				parentMode=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
				NSString *prob=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
				
				
				//put the selected row in a array //array count from index 0 and DB col starts from index1
				//rowInDataBase = [NSMutableArray arrayWithObjects: name,basic_pic,spriteSheet,sound,parentMode, nil];
                
				
				
				
                
				//-----------check for the probability and choose if to get that row into our array,or choose the next row
				
				
				
                //convert event's probability from nsstring to integer
				int probability = [prob intValue];
				NSLog(@"probability:%i",probability);
				NSLog(@"s:%i",s);
				
				//insert the value only if the random is in the probability area
				if( random>s &&  random<= (s+probability)   )
				{
					NSLog(@"got it ");
                    rowInDataBase = [NSMutableArray arrayWithObjects: name,basic_pic,spriteSheet,sound,parentMode, nil];
					
				}
				
                s=s+probability;
				
				//--------------------------------------------------------------------------------------------------------
                
				
				
			}
            
			//write the current mode to the plist to save it for turn off
			[parentMode writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
			NSLog(@"%@", parentMode);
			
			//NSLog(@"%@",rowInDataBase);
            
			
			
		}
		
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	
	sqlite3_close(database);
	
    
	return rowInDataBase;
	
}









- (void)dealloc {
    
	[super dealloc];
}







@end
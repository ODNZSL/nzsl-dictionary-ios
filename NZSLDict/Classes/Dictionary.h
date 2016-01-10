//
//  Dictionary.h
//  NZSL Dict
//
//  Created by Greg Hewgill on 24/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictEntry: NSObject

- (NSString *)handshapeImage;
- (NSString *)locationImage;

@property (strong) NSString *gloss;
@property (strong) NSString *minor;
@property (strong) NSString *maori;
@property (strong) NSString *image;
@property (strong) NSString *video;
@property (strong) NSString *handshape;
@property (strong) NSString *location;

@end

@interface Dictionary : NSObject

- (Dictionary *)initWithFile:(NSString *)fileName;
- (DictEntry *)findExact:(NSString *)target;
- (NSArray *)searchFor:(NSString *)target;
- (NSArray *)searchHandshape:(NSString *)targetHandshape location:(NSString *)targetLocation;
- (DictEntry *)wordOfTheDay;

@end

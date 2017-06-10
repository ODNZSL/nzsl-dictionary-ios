	//
//  Dictionary.m
//  NZSL Dict
//
//  Created by Greg Hewgill on 24/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignsDictionary.h"

#import <CommonCrypto/CommonDigest.h>
#import <sqlite3.h>

@implementation DictEntry

- (NSString *)handshapeImage
{
    return [NSString stringWithFormat:@"handshape.%@.png", self.handshape];
}

static NSString *Locations[][2] = {
    {@"in front of body", @"location.1.1.in_front_of_body.png"},
    //@"palm",
    {@"chest", @"location.4.12.chest.png"},
    {@"lower head", @"location.3.9.lower_head.png"},
    {@"fingers/thumb", @"location.6.20.fingers_thumb.png"},
    {@"in front of face", @"location.2.2.in_front_of_face.png"},
    {@"top of head", @"location.3.4.top_of_head.png"},
    {@"head", @"location.3.3.head.png"},
    {@"cheek", @"location.3.8.cheek.png"},
    {@"nose", @"location.3.6.nose.png"},
    {@"back of hand", @"location.6.22.back_of_hand.png"},
    {@"neck/throat", @"location.4.10.neck_throat.png"},
    {@"shoulders", @"location.4.11.shoulders.png"},
    //@"blades",
    {@"abdomen", @"location.4.13.abdomen.png"},
    {@"eyes", @"location.3.5.eyes.png"},
    {@"ear", @"location.3.7.ear.png"},
    {@"hips/pelvis/groin", @"location.4.14.hips_pelvis_groin.png"},
    {@"wrist", @"location.6.19.wrist.png"},
    {@"lower arm", @"location.5.18.lower_arm.png"},
    {@"upper arm", @"location.5.16.upper_arm.png"},
    {@"elbow", @"location.5.17.elbow.png"},
    {@"upper leg", @"location.4.15.upper_leg.png"},
};

- (NSString *)locationImage
{
    for (int i = 0; i < sizeof(Locations)/sizeof(Locations[0]); i++) {
        if ([Locations[i][0] isEqualToString:self.location]) {
            return Locations[i][1];
        }
    }
    return nil;
}

@end

void sort_results(NSMutableArray *sr)
{
    [sr sortUsingComparator:^(id obj1, id obj2) {
        NSString *s1 = [obj1 gloss];
        NSString *s2 = [obj2 gloss];
        NSString *(^skip_parens)(NSString *s) = ^(NSString *s) {
            if ([s characterAtIndex:0] == '(') {
                NSRange p = [s rangeOfString:@") "];
                if (p.location != NSNotFound) {
                    s = [s substringFromIndex:p.location+2];
                } else {
                    NSLog(@"expected to find closing parenthesis: %@", s);
                }
            }
            return s;
        };
        s1 = skip_parens(s1);
        s2 = skip_parens(s2);
        return [s1 caseInsensitiveCompare:s2];
    }];
}

@implementation SignsDictionary {
    sqlite3 *db;
    int count;
}

static NSString *normalise(NSString *s)
{
    NSData *d = [s dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    return [[[NSString alloc] initWithData:d encoding:NSASCIIStringEncoding] lowercaseString];
}

- (SignsDictionary *)initWithFile:(NSString *)xfileName
{
    NSString *fname = [[NSBundle mainBundle] pathForResource:@"nzsl.db" ofType:nil];
    if (sqlite3_open_v2([fname UTF8String], &db, SQLITE_OPEN_READONLY, NULL) != SQLITE_OK) {
        NSLog(@"unable to open db");
        exit(1);
    }

    sqlite3_stmt *st;
    if (sqlite3_prepare_v2(db, "select count(*) from words", -1, &st, NULL) != SQLITE_OK) {
        return nil;
    }
    if (sqlite3_step(st) != SQLITE_ROW) {
        return nil;
    }
    count = sqlite3_column_int(st, 0);
    sqlite3_finalize(st);
    
    return self;
}

- (void)dealloc
{
    sqlite3_close(db);
}

DictEntry *entry_from_row(sqlite3_stmt *st)
{
    DictEntry *r = [[DictEntry alloc] init];
    r.gloss = [NSString stringWithUTF8String:(char *)sqlite3_column_text(st, 0)];
    r.minor = [NSString stringWithUTF8String:(char *)sqlite3_column_text(st, 1)];
    r.maori = [NSString stringWithUTF8String:(char *)sqlite3_column_text(st, 2)];
    r.image = [NSString stringWithUTF8String:(char *)sqlite3_column_text(st, 3)];
    r.video = [NSString stringWithUTF8String:(char *)sqlite3_column_text(st, 4)];
    r.handshape = [NSString stringWithUTF8String:(char *)sqlite3_column_text(st, 5)];
    r.location = [NSString stringWithUTF8String:(char *)sqlite3_column_text(st, 6)];
    return r;
}

- (DictEntry *)findExact:(NSString *)target
{
    DictEntry *r = nil;
    sqlite3_stmt *st;
    if (sqlite3_prepare_v2(db, "select * from words where gloss = ?", -1, &st, NULL) != SQLITE_OK) {
        return nil;
    }
    sqlite3_bind_text(st, 1, [target UTF8String], -1, SQLITE_TRANSIENT);
    if (sqlite3_step(st) == SQLITE_ROW) {
        r = entry_from_row(st);
    }
    sqlite3_finalize(st);
    return r;
}

- (NSArray *)searchFor:(NSString *)target
{
    NSMutableArray *sr = [NSMutableArray array];
    NSString *exactTerm = normalise(target);
    NSString *containsTerm = [NSString stringWithFormat:@"%%%@%%", exactTerm];
    
    sqlite3_stmt *exactPrimaryMatchStmt;
    sqlite3_stmt *containsPrimaryMatchStmt;
    sqlite3_stmt *exactSecondaryMatchStmt;
    sqlite3_stmt *containsSecondaryMatchStmt;
    
    bool statementPreparedOk = true;
    statementPreparedOk = sqlite3_prepare_v2(db, "SELECT * FROM words WHERE gloss = ? OR maori = ?", -1, &exactPrimaryMatchStmt, NULL) == SQLITE_OK &&\
                          sqlite3_prepare_v2(db, "SELECT * FROM words WHERE gloss LIKE ? OR maori LIKE ?", -1, &containsPrimaryMatchStmt, NULL) == SQLITE_OK &&\
                          sqlite3_prepare_v2(db, "SELECT * FROM words WHERE minor = ?", -1, &exactSecondaryMatchStmt, NULL) == SQLITE_OK &&\
                          sqlite3_prepare_v2(db, "SELECT * FROM words WHERE minor LIKE ?", -1, &containsSecondaryMatchStmt, NULL) == SQLITE_OK;
    
    if (!statementPreparedOk) return nil;
    


    sqlite3_bind_text(exactPrimaryMatchStmt, 1, [exactTerm UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(exactPrimaryMatchStmt, 2, [exactTerm UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(containsPrimaryMatchStmt, 1, [containsTerm UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(containsPrimaryMatchStmt, 2, [containsTerm UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(exactSecondaryMatchStmt, 1, [exactTerm UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(containsSecondaryMatchStmt, 1, [containsTerm UTF8String], -1, SQLITE_TRANSIENT);

    
    while (sqlite3_step(exactPrimaryMatchStmt) == SQLITE_ROW) {
        [sr addObject:entry_from_row(exactPrimaryMatchStmt)];
    }
    
    sqlite3_finalize(exactPrimaryMatchStmt);
    
    while (sqlite3_step(containsPrimaryMatchStmt) == SQLITE_ROW) {
        [sr addObject:entry_from_row(containsPrimaryMatchStmt)];
    }
    
    sqlite3_finalize(containsPrimaryMatchStmt);
    
    
    while (sqlite3_step(exactSecondaryMatchStmt) == SQLITE_ROW) {
        [sr addObject:entry_from_row(exactSecondaryMatchStmt)];
    }
    
    sqlite3_finalize(exactSecondaryMatchStmt);
    
    
    while (sqlite3_step(containsSecondaryMatchStmt) == SQLITE_ROW) {
        [sr addObject:entry_from_row(containsSecondaryMatchStmt)];
    }
    
    sqlite3_finalize(containsSecondaryMatchStmt);
    
    NSMutableArray* uniqueResults = [[NSMutableArray alloc] init];
    for (id e in sr) {
        if ( ! [uniqueResults containsObject:e] ) [uniqueResults addObject:e];
    }

    return uniqueResults;
}

- (NSArray *)searchHandshape:(NSString *)targetHandshape location:(NSString *)targetLocation
{
    NSMutableArray *sr = [NSMutableArray array];
    sqlite3_stmt *st;
    if (targetHandshape != nil && targetLocation != nil) {
        if (sqlite3_prepare_v2(db, "select * from words where handshape = ? and location = ?", -1, &st, NULL) != SQLITE_OK) {
            return nil;
        }
        sqlite3_bind_text(st, 1, [targetHandshape UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(st, 2, [targetLocation UTF8String], -1, SQLITE_TRANSIENT);
    } else if (targetHandshape != nil) {
        if (sqlite3_prepare_v2(db, "select * from words where handshape = ?", -1, &st, NULL) != SQLITE_OK) {
            return nil;
        }
        sqlite3_bind_text(st, 1, [targetHandshape UTF8String], -1, SQLITE_TRANSIENT);
    } else if (targetLocation != nil) {
        if (sqlite3_prepare_v2(db, "select * from words where location = ?", -1, &st, NULL) != SQLITE_OK) {
            return nil;
        }
        sqlite3_bind_text(st, 1, [targetLocation UTF8String], -1, SQLITE_TRANSIENT);
    } else {
        if (sqlite3_prepare_v2(db, "select * from words", -1, &st, NULL) != SQLITE_OK) {
            return nil;
        }
    }
    while (sqlite3_step(st) == SQLITE_ROW) {
        [sr addObject:entry_from_row(st)];
    }
    sqlite3_finalize(st);
    sort_results(sr);
    return sr;
}

- (DictEntry *)wordOfTheDay
{
    NSSet *taboo = [NSSet setWithObjects:
        @"(vaginal) discharge",
        @"abortion",
        @"abuse",
        @"anus",
        @"asshole",
        @"attracted",
        @"balls",
        @"been to",
        @"bisexual",
        @"bitch",
        @"blow job",
        @"breech (birth)",
        @"bugger",
        @"bullshit",
        @"cervical smear",
        @"cervix",
        @"circumcise",
        @"cold (behaviour)",
        @"come",
        @"condom",
        @"contraction (labour)",
        @"cunnilingus",
        @"cunt",
        @"damn",
        @"defecate, faeces",
        @"dickhead",
        @"dilate (cervix)",
        @"ejaculate, sperm",
        @"episiotomy",
        @"erection",
        @"fart",
        @"foreplay",
        @"gay",
        @"gender",
        @"get intimate",
        @"get stuffed",
        @"hard-on",
        @"have sex",
        @"heterosexual",
        @"homo",
        @"horny",
        @"hysterectomy",
        @"intercourse",
        @"labour pains",
        @"lesbian",
        @"lose one's virginity",
        @"love bite",
        @"lust",
        @"masturbate (female)",
        @"masturbate, wanker",
        @"miscarriage",
        @"orgasm",
        @"ovaries",
        @"penis",
        @"period",
        @"period pains",
        @"promiscuous",
        @"prostitute",
        @"rape",
        @"sanitary pad",
        @"sex",
        @"sexual abuse",
        @"shit",
        @"smooch",
        @"sperm",
        @"strip",
        @"suicide",
        @"tampon",
        @"testicles",
        @"vagina",
        @"virgin",
        nil];

    time_t now = time(NULL);
    struct tm *tm = localtime(&now);
    char buf[20];
    snprintf(buf, sizeof(buf), "%04d-%02d-%02d", 1900+tm->tm_year, 1+tm->tm_mon, tm->tm_mday);
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(buf, (CC_LONG)strlen(buf), digest);
    int i = ((digest[0] << 8) | (digest[1])) % count;
    
    BOOL (^reject)(DictEntry *e) = ^(DictEntry *e) {
        if ([taboo containsObject:e.gloss]) {
            return YES;
        }
        if ([e.gloss rangeOfString:@"fuck"].location != NSNotFound
         || [e.minor rangeOfString:@"fuck"].location != NSNotFound) {
            return YES;
        }
        return NO;
    };
    
    DictEntry *r = nil;
    sqlite3_stmt *st;
    if (sqlite3_prepare_v2(db, "select * from words limit 100 offset ?", -1, &st, NULL) != SQLITE_OK) {
        return nil;
    }
    sqlite3_bind_int(st, 1, i);
    while (sqlite3_step(st) == SQLITE_ROW) {
        r = entry_from_row(st);
        if (reject(r)) {
            continue;
        }
        break;
    }
    sqlite3_finalize(st);
    return r;
}

@end

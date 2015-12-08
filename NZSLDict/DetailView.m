//
//  DetailView.m
//  NZSL Dict
//
//  Created by Greg Hewgill on 29/04/13.
//
//

#import "DetailView.h"

@implementation DetailView {
    UILabel *glossView;
    UILabel *minorView;
    UILabel *maoriView;
    UIImageView *handshapeView;
    UIImageView *locationView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];

        glossView = [[UILabel alloc] initWithFrame:CGRectMake(DETAIL_VIEW_INSET, DETAIL_VIEW_INSET, self.bounds.size.width-DETAIL_VIEW_INSET*2-120, 20)];
        glossView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        glossView.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:glossView];
    
        minorView = [[UILabel alloc] initWithFrame:CGRectMake(DETAIL_VIEW_INSET, DETAIL_VIEW_INSET+20, self.bounds.size.width-DETAIL_VIEW_INSET*2-120, 20)];
        minorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        minorView.font = [UIFont systemFontOfSize:15];
        [self addSubview:minorView];
    
        maoriView = [[UILabel alloc] initWithFrame:CGRectMake(DETAIL_VIEW_INSET, DETAIL_VIEW_INSET+40, self.bounds.size.width-DETAIL_VIEW_INSET*2-120, 20)];
        maoriView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        maoriView.font = [UIFont italicSystemFontOfSize:15];
        [self addSubview:maoriView];
    
        handshapeView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-DETAIL_VIEW_INSET-120, DETAIL_VIEW_INSET, 60, 60)];
        handshapeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        handshapeView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:handshapeView];
    
        locationView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-DETAIL_VIEW_INSET-60, DETAIL_VIEW_INSET, 60, 60)];
        locationView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        locationView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:locationView];
    }
    return self;
}

- (void)showEntry:(DictEntry *)entry
{
    glossView.text = entry.gloss;
    minorView.text = entry.minor;
    maoriView.text = entry.maori;
    handshapeView.image = [UIImage imageNamed:entry.handshapeImage];
    locationView.image = [UIImage imageNamed:entry.locationImage];
}

@end

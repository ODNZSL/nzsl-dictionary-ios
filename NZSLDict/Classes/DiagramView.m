////
////  DiagramView.m
////  NZSL Dict
////
////  Created by Greg Hewgill on 27/04/13.
////
////
//
//#import "DiagramView.h"
//#import "NZSLDict-Swift.h"
//
//@implementation DiagramView {
//    DetailView *detailView;
//    UIImageView *imageView;
//}
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        
//        detailView = [[DetailView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, DetailView.height)];
//        detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        [self addSubview:detailView];
//    
//        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, DetailView.height, self.bounds.size.width, self.bounds.size.height-DetailView.height)];
//        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        imageView.backgroundColor = [UIColor whiteColor];
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        [self addSubview:imageView];
//    }
//    return self;
//}
//
//- (void)showEntry:(DictEntry *)entry
//{
//    [detailView showEntry:entry];
//    imageView.image = [UIImage imageNamed:entry.image];
//}
//
//@end

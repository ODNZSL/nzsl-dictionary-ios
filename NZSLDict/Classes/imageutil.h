//
//  imageutil.h
//  NZSL Dict
//
//  Created by Greg Hewgill on 4/05/13.
//
//

// EOIN: this is only required before IOS7 so can be removed once other files are converted to swift
#import <UIKit/UIKit.h>

#ifndef NZSL_Dict_imageutil_h
#define NZSL_Dict_imageutil_h

UIImage *invert_image(UIImage *src);
UIImage *transparent_image(UIImage *src);

#endif

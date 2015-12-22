//
//  imageutil.c
//  NZSL Dict
//
//  Created by Greg Hewgill on 4/05/13.
//
//

#include "imageutil.h"

UIImage *invert_image(UIImage *src)
{
    UIGraphicsBeginImageContext(src.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, src.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGRect rect = CGRectMake(0, 0, src.size.width, src.size.height);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [[UIColor whiteColor] setFill];
    CGContextFillRect(context, rect);
    CGContextSetBlendMode(context, kCGBlendModeDifference);
    CGContextDrawImage(context, rect, src.CGImage);
    CGImageRef img = CGBitmapContextCreateImage(context);
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    unsigned char *bits = malloc(src.size.height * src.size.width * 4);
    CGContextRef bitcontext = CGBitmapContextCreate(bits, src.size.width, src.size.height, 8, src.size.width * 4, cs, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(cs);
    CGContextDrawImage(bitcontext, rect, img);
    for (int i = 0; i < src.size.height * src.size.width; i++) {
        bits[4*i+3] = bits[4*i];
    }
    CGImageRef aimg = CGBitmapContextCreateImage(bitcontext);
    UIImage *r = [UIImage imageWithCGImage:aimg];
    CGImageRelease(aimg);
    CGContextRelease(bitcontext);
    free(bits);
    
    CGImageRelease(img);
    UIGraphicsEndImageContext();
    return r;
}

UIImage *transparent_image(UIImage *src)
{
    UIGraphicsBeginImageContext(src.size);
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    unsigned char *bits = malloc(src.size.height * src.size.width * 4);
    CGContextRef bitcontext = CGBitmapContextCreate(bits, src.size.width, src.size.height, 8, src.size.width * 4, cs, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(cs);
    CGContextDrawImage(bitcontext, CGRectMake(0, 0, src.size.width, src.size.height), src.CGImage);
    for (int i = 0; i < src.size.height * src.size.width; i++) {
        unsigned char c = bits[4*i];
        bits[4*i  ] = 0;
        bits[4*i+1] = 0;
        bits[4*i+2] = 0;
        bits[4*i+3] = 0xff - c;
    }
    CGImageRef aimg = CGBitmapContextCreateImage(bitcontext);
    UIImage *r = [UIImage imageWithCGImage:aimg];
    CGImageRelease(aimg);
    CGContextRelease(bitcontext);
    free(bits);
    
    UIGraphicsEndImageContext();
    return r;
}
//
//  UIImage+TextureAtlas.m
//  ImageTest
//
//  Created by Jamie Kosoy on 2/11/14.
//  Copyright (c) 2014 JKosoy. All rights reserved.
//

#import "UIImage+TextureAtlas.h"

@implementation UIImage (TextureAtlas)

+ (NSDictionary *)atlas:(NSString *)filename {
    static NSMutableDictionary *cache = nil;

    if(!cache) {
        cache = [NSMutableDictionary dictionary];
    }
    
    if(cache[filename]) {
        return cache[filename];
    }

    NSString* file = [[filename lastPathComponent] stringByDeletingPathExtension];
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.atlasc/%@", file, file] ofType:@"plist"];
    NSDictionary *atlasDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];

    NSMutableDictionary *atlas = [NSMutableDictionary dictionary];

    NSArray *images = atlasDictionary[@"images"];
    NSArray *relevantImages;
    
    BOOL hasRetinaImages = NO;
    CGFloat scale = [UIScreen mainScreen].scale;

    if(scale == 2.0) {
        NSPredicate *retina = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            NSString *file = [evaluatedObject[@"path"] stringByDeletingPathExtension];
            return [file hasSuffix:@"@2x"];
        }];

        relevantImages = [images filteredArrayUsingPredicate:retina];
        hasRetinaImages = YES;
        
        // jk: TO DO :: ipad retina
        
        if(relevantImages.count == 0) {
            relevantImages = images;
        }
    }
    else {
        // jk: TO DO :: ipad
        relevantImages = images;
    }

    [relevantImages enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *imagePath = obj[@"path"];
        NSString *imageFile = [[imagePath lastPathComponent] stringByDeletingPathExtension];
        NSString *imageExtension = [imagePath pathExtension];

        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.atlasc/%@", file, imageFile] ofType:imageExtension];
        UIImage *atlasImage = [UIImage imageWithContentsOfFile:path];

        NSArray *subimages = obj[@"subimages"];
        
        CGSize atlasSize = atlasImage.size;
        CGImageRef atlasRef = atlasImage.CGImage;
        
        if(!atlasImage || CGSizeEqualToSize(atlasSize, CGSizeZero)) {
            *stop = YES;
            return;
        }

        [subimages enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            CGRect textureRect = CGRectFromString(obj[@"textureRect"]);
            CGSize spriteSize = CGSizeFromString(obj[@"spriteSourceSize"]);
            CGPoint spriteOffset = CGPointFromString(obj[@"spriteOffset"]);

            // jk: TO DO :: handle origin and make sure everything is the right size.
            CGImageRef sprite = CGImageCreateWithImageInRect(atlasRef, textureRect); {
                UIImage *spriteImage;
                UIGraphicsBeginImageContext(spriteSize); {
                    CGContextRef ctx = UIGraphicsGetCurrentContext();

                    CGRect rect = CGRectZero;
                    rect.origin = spriteOffset;
                    rect.size = textureRect.size;

                    CGContextDrawImage(ctx, rect, sprite);

                    spriteImage = UIGraphicsGetImageFromCurrentImageContext();
                } UIGraphicsEndImageContext();
                
                if(hasRetinaImages) {
                    spriteImage = [UIImage imageWithCGImage:spriteImage.CGImage scale:scale orientation:UIImageOrientationUp];
                }
                
                // jk: TO DO: optimize
                if(obj[@"textureRotated"]) {
                    float degrees = -90;

                    CGFloat rads = M_PI * degrees / 180;
                    float newSide = MAX(spriteImage.size.width, spriteImage.size.height);
                    CGSize size =  CGSizeMake(newSide, newSide);
                    UIGraphicsBeginImageContext(size);
                    CGContextRef ctx = UIGraphicsGetCurrentContext();
                    CGContextTranslateCTM(ctx, newSide/2, newSide/2);
                    CGContextRotateCTM(ctx, rads);
                    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(-spriteImage.size.width/2,-spriteImage.size.height/2,size.width, size.height),spriteImage.CGImage);
                    spriteImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                
                // remove @2x and what have you. not perfect right now.
                NSString *name = obj[@"name"];
                NSString *nameNoExt = [name stringByDeletingPathExtension];
                NSString *nameExt = [nameNoExt stringByReplacingOccurrencesOfString:nameNoExt withString:@""];
                
                if(scale == 2.0) {
                    nameNoExt = [name stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
                }

                atlas[[NSString stringWithFormat:@"%@%@",nameNoExt,nameExt]] = spriteImage;
            } CGImageRelease(sprite);
        }];
    }];
    

    cache[filename] = atlas;

    return cache[filename];
}

+ (NSArray *)spritesWithContentsOfAtlas:(NSString *)filename sequence:(NSString *)sequence start:(int)start end:(int)end {
    NSDictionary *atlas = [UIImage atlas:filename];
    
    NSMutableArray *sprites = [NSMutableArray array];

    __block int index = start;
    [atlas enumerateKeysAndObjectsUsingBlock:^(NSString *key, UIImage *obj, BOOL *stop) {
        UIImage *sprite = [atlas objectForKey:[NSString stringWithFormat:sequence, index]];

        if(!sprite) {
            *stop = YES;
            return;
        }
        
        [sprites addObject:sprite];

        index++;

        if(index >= end && end != -1) {
            *stop = YES;
        }
    }];
    
    return sprites;
}

+ (NSArray *)spritesWithContentsOfAtlas:(NSString *)filename sequence:(NSString *)sequence {
    return [UIImage spritesWithContentsOfAtlas:filename sequence:sequence start:0 end:-1];
}


@end
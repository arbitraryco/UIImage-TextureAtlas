//
//  UIImage+TextureAtlas.m
//  ImageTest
//
//  Created by Jamie Kosoy on 2/11/14.
//  Copyright (c) 2014 JKosoy. All rights reserved.
//

#import "UIImage+TextureAtlas.h"

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

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
            UIImage *image;

            CGSize sourceSize= CGSizeFromString(obj[@"spriteSourceSize"]); // the final source of the image
            CGPoint spriteOffset = CGPointFromString(obj[@"spriteOffset"]); // the offset we'll need to draw in the final source

            CGRect textureRect = CGRectFromString(obj[@"textureRect"]); // the current x/y/w/h of the image in the atlas
            BOOL textureRotated = [obj[@"textureRotated"] boolValue]; // whether the texture rotated or not

            CGImageRef sprite = CGImageCreateWithImageInRect(atlasRef, textureRect);

            // rotate the sprite if neccessary
            if(textureRotated) {
                float degrees = -90;
                CGSize size = CGSizeMake(CGRectGetHeight(textureRect), CGRectGetWidth(textureRect));
                
                CGImageRef oldSprite = sprite;

                UIGraphicsBeginImageContext(size);
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGContextTranslateCTM(ctx, size.width/2, size.height/2);
                CGContextRotateCTM(ctx, DegreesToRadians(degrees));
                CGContextScaleCTM(ctx, 1.0, -1.0);
                CGContextDrawImage(ctx, CGRectMake(-CGRectGetWidth(textureRect) / 2, -CGRectGetHeight(textureRect) / 2, CGRectGetWidth(textureRect), CGRectGetHeight(textureRect)), oldSprite);
                sprite = CGBitmapContextCreateImage(ctx);
                UIGraphicsEndImageContext();
                
                CGImageRelease(oldSprite);
            }
            
            // begin rendering our final image.
            UIGraphicsBeginImageContext(sourceSize);
            CGContextRef ctx = UIGraphicsGetCurrentContext();

            // flip the image as it is currently backward.
            CGContextTranslateCTM(ctx, 0, sourceSize.height);
            CGContextScaleCTM(ctx, 1.0f, -1.0f);
            
            // draw accounting for offset
            float w = !textureRotated ? CGRectGetWidth(textureRect) : CGRectGetHeight(textureRect);
            float h = !textureRotated ? CGRectGetHeight(textureRect) : CGRectGetWidth(textureRect);
            
            CGContextDrawImage(ctx, CGRectMake(spriteOffset.x, spriteOffset.y, w, h), sprite);

            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            // done

            if(hasRetinaImages) {
                image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
            }

            // preserve as the final filename, removing any references to @2x for ease of use.
            NSString *filename = obj[@"name"];
            NSString *filenameWithoutExtension = [filename stringByDeletingPathExtension];
            NSString *fileExtension = [filename stringByReplacingOccurrencesOfString:filenameWithoutExtension withString:@""];
            
            if(scale == 2.0) {
                filenameWithoutExtension = [filenameWithoutExtension stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
            }
            
            NSString *key = [NSString stringWithFormat:@"%@%@",filenameWithoutExtension,fileExtension];
            atlas[key] = image;

            CGImageRelease(sprite);
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
        NSString *imageName = [NSString stringWithFormat:sequence, index];
        UIImage *sprite = [atlas objectForKey:imageName];

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

+ (NSArray *)spritesWithContentsOfAtlas:(NSString *)filename sequence:(NSString *)sequence start:(int)start {
    return [UIImage spritesWithContentsOfAtlas:filename sequence:sequence start:start end:-1];
}


+ (NSArray *)spritesWithContentsOfAtlas:(NSString *)filename sequence:(NSString *)sequence {
    return [UIImage spritesWithContentsOfAtlas:filename sequence:sequence start:0 end:-1];
}

+ (void)removeAtlasFromCache:(NSString *)filename {
    static NSMutableDictionary *cache = nil;

    if(!cache) return;
    
    if(cache[filename]) {
        [cache removeObjectForKey:filename];
    }
}


@end
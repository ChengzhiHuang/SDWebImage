/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "NSImage+Additions.h"

#if SD_MAC

#import "SDWebImageCoderHelper.h"
#import "objc/runtime.h"

@implementation NSImage (Additions)

- (CGImageRef)CGImage {
    NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
    CGImageRef cgImage = [self CGImageForProposedRect:&imageRect context:nil hints:nil];
    return cgImage;
}

- (CGFloat)scale {
    CGFloat scale = 1;
    NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
    NSImageRep *imageRep = [self bestRepresentationForRect:imageRect context:nil hints:nil];
    CGFloat width = imageRep.size.width;
    CGFloat height = imageRep.size.height;
    NSUInteger pixelWidth = imageRep.pixelsWide;
    NSUInteger pixelHeight = imageRep.pixelsHigh;
    if (width > 0 && height > 0) {
        CGFloat widthScale = pixelWidth / width;
        CGFloat heightScale = pixelHeight / height;
        if (widthScale == heightScale && widthScale >= 1) {
            // Protect for image object which custom the size.
            scale = widthScale;
        }
    }
    
    return scale;
}

- (instancetype)initWithCGImage:(CGImageRef)cgImage scale:(CGFloat)scale {
    return [self initWithCGImage:cgImage scale:scale orientation:kCGImagePropertyOrientationUp];
}

- (instancetype)initWithCGImage:(CGImageRef)cgImage scale:(CGFloat)scale orientation:(CGImagePropertyOrientation)orientation {
    if (scale < 1) {
        scale = 1;
    }
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage scale:scale orientation:orientation];
    NSSize size = imageRep.size;
    self = [self initWithSize:size];
    if (self) {
        [self addRepresentation:imageRep];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data scale:(CGFloat)scale {
    if (scale < 1) {
        scale = 1;
    }
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:data scale:scale];
    if (!imageRep) {
        return nil;
    }
    NSSize size = imageRep.size;
    self = [self initWithSize:size];
    if (self) {
        [self addRepresentation:imageRep];
    }
    return self;
}

@end

@implementation NSBitmapImageRep (Additions)

- (instancetype)initWithCGImage:(CGImageRef)cgImage scale:(CGFloat)scale orientation:(CGImagePropertyOrientation)orientation {
    if (orientation != kCGImagePropertyOrientationUp) {
        // AppKit design is different from UIKit. Where CGImage based image rep does not respect to any orientation. Only data based image rep which contains the EXIF metadata can automatically detect orientation.
        // This should be nonnull, until the memory is exhausted cause `CGBitmapContextCreate` failed.
        cgImage = [SDWebImageCoderHelper CGImageCreateDecoded:cgImage orientation:orientation];
        self = [self initWithCGImage:cgImage];
        CGImageRelease(cgImage);
    } else {
        self = [self initWithCGImage:cgImage];
    }
    if (self) {
        if (scale < 1) {
            scale = 1;
        }
        NSSize size = NSMakeSize(self.pixelsWide / scale, self.pixelsHigh / scale);
        self.size = size;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data scale:(CGFloat)scale {
    self = [self initWithData:data];
    if (self) {
        if (scale < 1) {
            scale = 1;
        }
        NSSize size = NSMakeSize(self.pixelsWide / scale, self.pixelsHigh / scale);
        self.size = size;
    }
    return self;
}

@end

#endif

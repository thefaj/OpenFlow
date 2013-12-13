//
//  SDSOpenFlowView.m
//  JigSaw
//
//  Created by sergio on 3/4/12.
//  Copyright 2012 Freescapes Labs. All rights reserved.
//

#import "SDSOpenFlowView.h"

#define kLongTapIntervalOn 1.5
#define kLongTapIntervalOff 0.75
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
@implementation SDSOpenFlowView

@synthesize touchTimer = _touchTimer;

/////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    
    BOOL isInsideButton = NO;
    UIView* button = [selectedCoverView viewWithTag:100];
    if (_editMode && button) {
        //        CGPoint p = [self convertPoint:point toView:button];
        CGPoint p = [button convertPoint:point fromView:self];
        isInsideButton = [button pointInside:p withEvent:event];
    }
//    NSLog(@"HITTEST with event: %d/%d", [event type], [event subtype]);
    if (isInsideButton)
        return button;
    else
        return [super hitTest:point withEvent:event];
}

/////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    [super touchesBegan:touches withEvent:event];
    float interval = kLongTapIntervalOn;
    if (isDoubleTap) {
        NSLog(@"starting timer");
        if (_editMode)
            interval = kLongTapIntervalOff;
        self.touchTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                           target:self
                                                         selector:@selector(tapTimeout)
                                                         userInfo:nil repeats:NO];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    [super touchesMoved:touches withEvent:event];
    if (self.touchTimer != nil) {
        NSLog(@"invalidating timer");
        [self.touchTimer invalidate];
        self.touchTimer = nil;
    }
}

/////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    [super touchesEnded:touches withEvent:event];
	if (isSingleTap) {
        if (self.touchTimer != nil) {
            [self.touchTimer invalidate];
            self.touchTimer = nil;
            if (!_editMode)
                if ([self.viewDelegate respondsToSelector:@selector(openFlowView:selectionTap:)])
                    [(id)self.viewDelegate openFlowView:self selectionTap:selectedCoverView.number];
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////
- (void)tapTimeout {
    if (isSingleTap) {
        [self.touchTimer invalidate];
        self.touchTimer = nil;
        if ([self.viewDelegate respondsToSelector:@selector(openFlowView:selectionLongTap:)])
            [(id)self.viewDelegate openFlowView:self selectionLongTap:selectedCoverView.number];
    }
}

#define kDeleteButtonSize 24
/////////////////////////////////////////////////////////////////////////////////////////
- (void)shakeFlowView:(id)sender {
    
    //-- when called from outside, toggle mode
    if (sender != self)
        _editMode = !_editMode;
    
    if (_editMode) {
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect f = selectedCoverView.bounds;
        CGPoint p = CGPointMake(f.origin.x + f.size.width - kDeleteButtonSize/2,
                                f.origin.y - kDeleteButtonSize/3);
        //        p = [selectedCoverView convertPoint:p toView:self];
        
        button.frame = CGRectMake(p.x,
                                  p.y,
                                  kDeleteButtonSize, kDeleteButtonSize);
        [button setImage:[UIImage imageNamed:@"delPuzzle.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(removeSelectedPuzzle:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 100;
        [selectedCoverView addSubview:button];
        
        CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        [anim setToValue:[NSNumber numberWithFloat:0.0f]];
        [anim setFromValue:[NSNumber numberWithDouble:M_PI/90]];
        [anim setDuration:0.1];
        [anim setRepeatCount:NSUIntegerMax];
        [anim setAutoreverses:YES];
        [selectedCoverView.layer addAnimation:anim forKey:@"SpringboardShake"];
        
    } else        
        [selectedCoverView.layer removeAnimationForKey:@"SpringboardShake"];
}

/////////////////////////////////////////////////////////////////////////////////////////
- (void)rehashImageDictionaryFromIndex:(NSInteger)index {
    for (NSInteger i = index+1; i < self.numberOfImages; ++i) {
        UIImage* coverImage = [coverImages objectForKey:[NSNumber numberWithInt:i]];
        if (!coverImage)
            NSLog(@"AARRRGGGHHHH!!!!!");
        else {
            [coverImages setObject:coverImage forKey:[NSNumber numberWithInt:i-1]];
            id coverImageHeight = [coverImageHeights objectForKey:[NSNumber numberWithInt:i]];
            [coverImageHeights setObject:coverImageHeight forKey:[NSNumber numberWithInt:i-1]];
        }
    }
    [coverImages removeObjectForKey:[NSNumber numberWithInt:self.numberOfImages-1]];
    [coverImageHeights removeObjectForKey:[NSNumber numberWithInt:self.numberOfImages-1]];
}

/////////////////////////////////////////////////////////////////////////////////////////
- (void)removeSelectedPuzzle:(id)sender {
    
//    [selectedCoverView retain];
    int index = selectedCoverView.number;
    if (index >= self.numberOfImages)
        return;
    NSNumber *coverNumber = [NSNumber numberWithInt:index];
	[coverImages removeObjectForKey:coverNumber];
    for (id key in [coverImages allKeys]) {
        NSLog(@"COVER DESCRIPTION (%@): %@", [key description], [coverImages objectForKey:key]);
    }
	[coverImageHeights removeObjectForKey:coverNumber];
    [onscreenCovers removeAllObjects];
    [self rehashImageDictionaryFromIndex:index];
//    [self setNumberOfImages:self.numberOfImages-1];
    --numberOfImages;
//    [selectedCoverView release];
    selectedCoverView = nil;
    --index;
    [self setSelectedCover:MAX(index, 0)];
    [self centerOnSelectedCover:YES];
    
    if ([self.viewDelegate respondsToSelector:@selector(openFlowView:didRemoveImage:)])
        [(id)self.viewDelegate openFlowView:self didRemoveImage:(index+1)];
}

/////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelectedCover:(int)newSelectedCover {
	if (selectedCoverView && (newSelectedCover == selectedCoverView.number))
        return;
    
    AFItemView* oldView = selectedCoverView;
    [[oldView viewWithTag:100] removeFromSuperview];
    
    [super setSelectedCover:newSelectedCover];
    
    if (_editMode) {
        [oldView.layer removeAnimationForKey:@"SpringboardShake"];
        [self shakeFlowView:self];
    }
}

- (void)dealloc {
    [self.touchTimer invalidate];
    self.touchTimer = nil;
    [super dealloc];
}
@end


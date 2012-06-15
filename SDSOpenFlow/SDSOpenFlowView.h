//
//  SDSOpenFlowView.h
//  JigSaw
//
//  Created by sergio on 3/4/12.
//  Copyright 2012 Freescapes Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFOpenFlowView.h"

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
@interface SDSOpenFlowView : AFOpenFlowView {
    NSTimer* _touchTimer;
    BOOL _editMode;
}
@property (nonatomic, retain) NSTimer* touchTimer;

- (void)shakeFlowView:(id)sender;

@end

@protocol SDSOpenFlowViewDelegate <AFOpenFlowViewDelegate>
@optional
- (void)openFlowView:(AFOpenFlowView*)openFlowView selectionTap:(int)index;
- (void)openFlowView:(AFOpenFlowView*)openFlowView selectionLongTap:(int)index;
- (void)openFlowView:(AFOpenFlowView*)openFlowView didRemoveImage:(int)index;
@end

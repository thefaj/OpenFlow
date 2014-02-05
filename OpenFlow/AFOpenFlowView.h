/**
 * Copyright (c) 2009 Alex Fajkowski, Apparent Logic LLC
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
#import <UIKit/UIKit.h>
#import "AFItemView.h"
#import <QuartzCore/QuartzCore.h>


@protocol AFOpenFlowViewDataSource;
@protocol AFOpenFlowViewDelegate;

@interface AFOpenFlowView : UIView {
	id <AFOpenFlowViewDataSource>	dataSource;
	id <AFOpenFlowViewDelegate>	viewDelegate;
	NSMutableSet					*offscreenCovers;
	NSMutableDictionary				*onscreenCovers;
	NSMutableDictionary				*coverImages;
	NSMutableDictionary				*coverImageHeights;
	UIImage							*defaultImage;
	CGFloat							defaultImageHeight;

	UIScrollView					*scrollView;
	int								lowerVisibleCover;
	int								upperVisibleCover;
	int								numberOfImages;
	int								beginningCover;
	
	AFItemView						*selectedCoverView;

	CATransform3D leftTransform, rightTransform;
	
	CGFloat halfScreenHeight;
	CGFloat halfScreenWidth;
	
	Boolean isSingleTap;
	Boolean isDoubleTap;
	Boolean isDraggingACover;
	CGFloat startPosition;
}

@property (nonatomic, assign) id <AFOpenFlowViewDataSource> dataSource;
@property (nonatomic, assign) id <AFOpenFlowViewDelegate> viewDelegate;
@property (nonatomic, retain) UIImage *defaultImage;
@property int numberOfImages;

- (void)setSelectedCover:(int)newSelectedCover;
- (void)centerOnSelectedCover:(BOOL)animated;
- (void)setImage:(UIImage *)image forIndex:(int)index;

@end

@protocol AFOpenFlowViewDelegate <NSObject>
@optional
- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index;
@optional
- (void)selectedCoverIndex:(int)index;
@end

@protocol AFOpenFlowViewDataSource <NSObject>
- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index;
- (UIImage *)defaultImage;
@end
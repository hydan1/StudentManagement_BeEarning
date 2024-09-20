//
//  TableViewBackground.m
//  StudentManagement
//
//  Created by Hydan on 20/9/24.
//

#import "TableViewBackground.h"

@implementation TableViewBackground

// Override initWithCoder if you're using Interface Builder
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

// Override init if you're creating it programmatically
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

// Load the view from the XIB
- (void)commonInit {
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"TableViewBackground" owner:self options:nil] firstObject];
    view.frame = self.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:view];
}

@end

//
//  InterpreterView.m
//  EnglishReader
//
//  Created by QMTV on 17/1/8.
//  Copyright © 2017年 LFC. All rights reserved.
//


#import "InterpreterViewLocal.h"
#import "YYKit.h"
#import <UIKit/UIReferenceLibraryViewController.h>
#import "UIWebView+Category.h"
#import "UITextView+Method.h"
#import "Masonry.h"

@interface InterpreterViewLocal ()

@property (nonatomic, strong) YYTextView *contentView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIReferenceLibraryViewController *reference;
@property (nonatomic, copy) NSString *currentString;
@property (nonatomic, assign) BOOL notFirstSet;
@end

@implementation InterpreterViewLocal

- (void)dealloc {
    [_textView restoreSetAttributeText];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self.textView hookSetAttributeText];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewSetAttributedText:) name:@"textViewAttributedText" object:nil];
        
        [self addSubview:self.contentView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)interpretWithText:(NSString *)text {
    self.notFirstSet = NO;
    if (self.reference) {
        [self.reference.view removeFromSuperview];
        self.reference = nil;
    }
    self.currentString = text;
    self.reference = [[UIReferenceLibraryViewController alloc] initWithTerm:text];
    [self insertSubview:self.reference.view belowSubview:self.contentView];
    
    if ([self.delegate respondsToSelector:@selector(interpreterSuccessed)]) {
        [self.delegate interpreterSuccessed];
    }
}

- (void)showUnknownText {
    [self.contentView setAttributedText:[[NSAttributedString alloc] initWithString:@"没有找到" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0], NSForegroundColorAttributeName:[UIColor redColor]}]];
    if ([self.delegate respondsToSelector:@selector(interpreterFailure)]) {
        [self.delegate interpreterFailure];
    }
}

#pragma mark ---- Notification

- (void)textViewSetAttributedText:(NSNotification *)notification
{
    if (self.notFirstSet) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    NSAttributedString *attributedText = [userInfo valueForKey:@"attributedText"];
    [self.contentView setAttributedText:attributedText];
    self.notFirstSet = YES;
}

#pragma mark ---- getter
- (YYTextView *)contentView {
    if (!_contentView) {
        _contentView = [[YYTextView alloc] init];
    }
    
    return _contentView;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
    }
    
    return _textView;
}

@end

//
//  MCMathKeyboardRootView.m
//  MathChat
//
//  Created by MARIO ANDHIKA on 7/16/15.
//  Copyright (c) 2015 MathChat, Inc.
//
//  This software may be modified and distributed under the terms of the
//  MIT license. See the LICENSE file for details.
//

#import "MTMathKeyboardRootView.h"

static NSInteger const DEFAULT_KEYBOARD = 0;

@interface MTMathKeyboardRootView ()

@property (nonatomic) MTKeyboard *currentKeyboard;
@property (nonatomic) MTKeyboard *tab1Keyboard;
@property (nonatomic) MTKeyboard *tab2Keyboard;
@property (nonatomic) MTKeyboard *tab3Keyboard;
@property (nonatomic) MTKeyboard *tab4Keyboard;
@property (nonatomic, weak) MTEditableMathLabel *textView;
@property (nonatomic) NSInteger currentTab;
@property (nonatomic) NSArray *keyboards;

@end

@implementation MTMathKeyboardRootView {
    
}

// Keyboard should be singleton
+(instancetype)sharedInstance {
    static MTMathKeyboardRootView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSBundle* bundle = [self getMathKeyboardResourcesBundle];
        instance = [bundle loadNibNamed:@"MTMathKeyboardRootView" owner:nil options:nil][0];
        
    });
    
    return instance;
}

// Gets the math keyboard resources bundle
+(NSBundle *)getMathKeyboardResourcesBundle
{
    return [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"MathKeyboardResources" withExtension:@"bundle"]];
}

-(void)awakeFromNib
{
    // initialize all keyboards first
    NSBundle* bundle = [MTMathKeyboardRootView getMathKeyboardResourcesBundle];

    _tab1Keyboard = (MTKeyboard *)[[UINib nibWithNibName:@"MTKeyboard" bundle:bundle] instantiateWithOwner:self options:nil][0];
    _tab2Keyboard = (MTKeyboard *)[[UINib nibWithNibName:@"MTKeyboardTab2" bundle:bundle] instantiateWithOwner:self options:nil][0];
    _tab3Keyboard = (MTKeyboard *)[[UINib nibWithNibName:@"MTKeyboardTab3" bundle:bundle] instantiateWithOwner:self options:nil][0];
    _tab4Keyboard = (MTKeyboard *)[[UINib nibWithNibName:@"MTKeyboardTab4" bundle:bundle] instantiateWithOwner:self options:nil][0];

    // TODO Use keyboard array for operations involving all tabs
    _keyboards = @[_tab1Keyboard, _tab2Keyboard, _tab3Keyboard, _tab4Keyboard];
    _currentTab = -1;

    for (MTKeyboard *keyboard in _keyboards) {
        // TODO: [DisplayUtils addFullSizeView:keyboard to:_contentView];
    }

    [self switchKeyboard:DEFAULT_KEYBOARD];
}

// To allow resetting of keyboard to the default tab when changing problems
-(void)switchToDefaultTab
{
    [self switchKeyboard:DEFAULT_KEYBOARD];
}

- (void)setEditableMathLabel:(MTEditableMathLabel *)textView
{
    _textView = textView;
    _tab1Keyboard.textView = textView;
    _tab2Keyboard.textView = textView;
    _tab3Keyboard.textView = textView;
    _tab4Keyboard.textView = textView;
}

- (IBAction)switchTabs:(UIButton *)sender
{
    [self switchKeyboard:sender.tag];
}

-(void)greyTabButtons
{
    [_numbersTab setSelected:false];
    [_operationsTab setSelected:false];
    [_functionsTab setSelected:false];
    [_lettersTab setSelected:false];
}

-(void)switchKeyboard:(NSInteger)tabNumber
{
    [self greyTabButtons];
    
    switch (tabNumber) {
        case 0:
            [_numbersTab setSelected:true];
            break;
        case 1:
            [_operationsTab setSelected:true];
            break;
        case 2:
            [_functionsTab setSelected:true];
            break;
        case 3:
            [_lettersTab setSelected:true];
            break;
            
        default:
            break;
    }
    
    // check currently active keyboard by tabNumber, skip creation if tabNumber is already the active tab
    if (_currentTab != tabNumber) {
        _currentTab = tabNumber;
        // animate and hold reference to the correct keyboard depending on tabNumber
        [self assignAndAnimateKeyboard:tabNumber];
    }
}

-(void)assignAndAnimateKeyboard:(NSInteger)keyboardNumber
{
    MTKeyboard* newKeyboard = _keyboards[keyboardNumber];

    // animate creation
    // animate destruction
    newKeyboard.alpha = 0.5;
    _currentKeyboard.alpha = 1.0;
    [UIView animateWithDuration:0.1 animations:^{
        newKeyboard.alpha = 1.0;
        _currentKeyboard.alpha = 0.5;
    }];

    [_contentView bringSubviewToFront:newKeyboard];

    // Hold reference to this keyboard so it can be removed from superview
    _currentKeyboard = newKeyboard;
}

/*-(void)setKeyboardContext:(KeyboardContext *)context
{
    [_tab1Keyboard setKeyboardContext:context];
    [_tab2Keyboard setKeyboardContext:context];
    [_tab3Keyboard setKeyboardContext:context];
    [_tab4Keyboard setKeyboardContext:context];
}*/

@end

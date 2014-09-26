//
//  DataViewController.m
//  Granted
//
//  Created by James Womack on 9/26/14.
//  Copyright (c) 2014 James Womack. All rights reserved.
//

#import "DataViewController.h"
#import "NGTextPropertyHolder.h"

@interface DataViewController ()
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *textElements;
@end

@implementation DataViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.dataLabel.text = [self.dataObject description];
  [self adjustAccessibilityBoldTextStatusForTextElements:_textElements];
  [self beginListeningToAccessibilityBoldTextStatusForTextElements:_textElements];
}

- (void)viewWillDisappear:(BOOL)animated {
  [self endListeningToAccessibilityBoldTextStatusForTextElements:_textElements];
  [super viewWillDisappear:animated];
}

// TODO - add UIAccessibilityDarkerSystemColorsStatusDidChangeNotification & others
// UIAccessibilityBoldTextStatusDidChangeNotification
- (void)beginListeningToAccessibilityBoldTextStatusForTextElements:(NSArray *)textElements {
  [[NSNotificationCenter defaultCenter]
   addObserverForName:UIAccessibilityBoldTextStatusDidChangeNotification
   object:nil
   queue:[NSOperationQueue mainQueue]
   usingBlock:^(NSNotification *note) {
     [self adjustAccessibilityBoldTextStatusForTextElements:textElements];
   }];
}

- (void)endListeningToAccessibilityBoldTextStatusForTextElements:(NSArray *)textElements {
  [[NSNotificationCenter defaultCenter]
   removeObserver:self
   name:UIAccessibilityBoldTextStatusDidChangeNotification
   object:nil];
}

- (void)adjustAccessibilityBoldTextStatusForTextElements:(NSArray *)textElements {
  for (id <NGTextPropertyHolder> textElement in textElements) {
    [self adjustAccessibilityBoldTextStatusForTextElement:textElement];
  }
}

- (void)adjustAccessibilityBoldTextStatusForTextElement:(id <NGTextPropertyHolder>)textElement {
  CGFloat pointSize = [[textElement font] pointSize];
  NSString *fontName = UIAccessibilityIsBoldTextEnabled() ? @"Avenir-Heavy" : @"Avenir-Roman";
  [textElement setFont:[UIFont fontWithName:fontName size:pointSize]];
}



@end

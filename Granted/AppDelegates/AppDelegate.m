//
//  AppDelegate.m
//  Granted
//
//  Created by James Womack on 9/26/14.
//  Copyright (c) 2014 James Womack. All rights reserved.
//

#import "AppDelegate.h"
#import "Granted-Swift.h"


@interface AppDelegate (){
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  
  Server *server = [[Server alloc] init];
  [server start];
  
  NSURL *url = [NSURL URLWithString:@"http://localhost:3030/resources/test.json"];
  //NSURL *movieUrl = [NSURL URLWithString:@"http://localhost:3030/resources/giphy.mp4"];
  
  NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
    dataTaskWithURL:url
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      NSString *body = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
      NSLog(@"%@",body);
    }];
  
  [downloadTask resume];
  
  return YES;
}

@end

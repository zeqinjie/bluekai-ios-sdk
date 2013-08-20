/*
 * Copyright 2013-present BlueKai, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#import "BlueKai.h"
#import "Reachability.h"
#import "Database.h"
#include <QuartzCore/QuartzCore.h>
#import "Bluekai_OpenUDID.h"

NSString const *server_URL = @"http://199.204.23.142/m/";

@implementation BlueKai
@synthesize delegate;
UIWebView *web;
UIButton *cncl_Btn;
UIImageView *usrcheck_image;
UIImageView *tccheck_image;
NSArray *checkimage;
NSUserDefaults *user_defaults;
UIViewController *main_View;
UITapGestureRecognizer *tap1,*tap2,*tap3;
BOOL devMode;
NSString *siteId;
NSMutableString *web_URL;
NSString *key_str,*value_str;
NSMutableDictionary *keyVal_dict;
NSMutableDictionary *nonLoadkeyVal_dict;
NSMutableDictionary *remainkeyVal_dict;
BOOL loadFailedBool;
BOOL alertShowBool;
BOOL web_Loaded;
UIAlertView *alert_View;
NSString *appVersion;
int urlStringCount;
NSUInteger numberOfRunningRequests ;

-(id)initWithArgs:(BOOL)value withSiteId:(NSString *)siteID withAppVersion:(NSString *)version withView:(UIViewController *)view
{
    if(self=[super init])
    {
        [Database copyDataBaseIfNeeded];
        [Database openDataBase:[Database getDBPath]];
        appVersion=version;
        devMode=value;
        siteId=nil;
        siteId=siteID;
        main_View=nil;
        main_View=view;
        web=nil;
        cncl_Btn=nil;
        web_URL=[[NSMutableString alloc]init];
        nonLoadkeyVal_dict=[[NSMutableDictionary alloc]init];
        remainkeyVal_dict=[[NSMutableDictionary alloc]init];
        web_Loaded=NO;
        web=[[UIWebView alloc]init];
        web.delegate=self;
        web.layer.cornerRadius=5.0f;
        web.layer.borderColor=[[UIColor grayColor] CGColor];
        web.layer.borderWidth=4.0f;
        [main_View.view addSubview:web];
        
        if(devMode)
        {
            web.frame=CGRectMake(10, 10, 300,390);
            cncl_Btn=[UIButton buttonWithType:UIButtonTypeCustom];
            cncl_Btn.frame=CGRectMake(281, 9, 30,30);
            cncl_Btn.tag=10;
            [cncl_Btn setImage:[UIImage imageNamed:@"btn-sub-del-op.png"] forState:UIControlStateNormal];
            [cncl_Btn addTarget:self action:@selector(Cancel:) forControlEvents:UIControlEventTouchUpInside];
            cncl_Btn.hidden=YES;
            [main_View.view addSubview:cncl_Btn];
        }
        else{
            web.frame=CGRectMake(10, 10, 1,1);
        }
        
        web.hidden=YES;
        Database *db_obj=[[Database alloc]init];
        keyVal_dict=[[NSMutableDictionary alloc]initWithDictionary:[db_obj getKeyValues]];
        
        if([[keyVal_dict allKeys] count]!=0)
        {
            numberOfRunningRequests=-1;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
            if (networkStatus != NotReachable) {
                
                web_Loaded=YES;
                web.tag=1;
                [self startDataUpload];
            }
            else{
                alertShowBool=YES;
                [self webView:nil didFailLoadWithError:nil];
            }
            
        }
        
        [db_obj release];
    }
    return self;
}
-(id)init
{
    if(self=[super init])
    {
        appVersion=nil;
        devMode=FALSE;
        main_View=nil;
        siteId=nil;
    }
    return self;
}

-(void)setDevMode:(BOOL)mode
{
    devMode=mode;
    if(main_View!=nil && siteId!=nil && appVersion!=nil)
    {
        [self resume];
    }
}
-(void)setAppVersion:(NSString *)version
{
    appVersion=version;
    if(main_View!=nil && siteId!=nil)
    {
        [self resume];
    }
}
-(void)setViewController:(UIViewController *)view
{
    main_View=view;
    if(siteId!=nil)
    {
        web=nil;
        cncl_Btn=nil;
        if(web_URL==nil)
        {
            web_URL=[[NSMutableString alloc]init];
        }
        else
        {
            [web_URL replaceCharactersInRange:NSMakeRange(0, [web_URL length]) withString:@""];
        }
        web=[[UIWebView alloc]init];
        web.delegate=self;
        web.layer.cornerRadius=5.0f;
        web.layer.borderColor=[[UIColor grayColor] CGColor];
        web.layer.borderWidth=4.0f;
        [main_View.view addSubview:web];
        if(devMode)
        {
            web.frame=CGRectMake(10, 10, 300,390);
            cncl_Btn=[UIButton buttonWithType:UIButtonTypeCustom];
            cncl_Btn.frame=CGRectMake(281, 9, 30,30);
            cncl_Btn.tag=10;
            [cncl_Btn setImage:[UIImage imageNamed:@"btn-sub-del-op.png"] forState:UIControlStateNormal];
            [cncl_Btn addTarget:self action:@selector(Cancel:) forControlEvents:UIControlEventTouchUpInside];
            cncl_Btn.hidden=YES;
            [main_View.view addSubview:cncl_Btn];
        }
        else{
            web.frame=CGRectMake(1, 1, 1,1);
        }
        web.hidden=YES;
        
        [self resume];
    }
}
-(void)setSiteId:(int)siteid
{
    siteId=[NSString stringWithFormat:@"%d",siteid];
    if(main_View!=nil)
    {
        [self resume];
    }
}

-(void)put:(NSString *)key:(NSString *)value
{
    if(!web_Loaded)
    {
        
        if(web_URL==nil)
        {
            web_URL=[[NSMutableString alloc]init];
        }
        else
        {
            [web_URL replaceCharactersInRange:NSMakeRange(0, [web_URL length]) withString:@""];
        }
        key_str=nil;
        value_str=nil;
        key_str=[key copy];
        value_str=[value copy];
        Database *db_Obj=[[Database alloc]init];
        
        //Check the settings page to find the use data is allowed to send to server or not
        if(keyVal_dict!=nil)
        {
            [keyVal_dict removeAllObjects];
        }
        else{
            keyVal_dict=[[NSMutableDictionary alloc]init];
        }
        [keyVal_dict setValue:value_str forKey:key_str];
        NSString *user_value=[db_Obj getUserDataValue];
        if([user_value isEqualToString:@"YES"])
        {
            numberOfRunningRequests=-1;
            web_Loaded=YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
            if (networkStatus != NotReachable) {
                [self startDataUpload];
            }
            else{
                [self webView:nil didFailLoadWithError:nil];
            }
            
        }
        else
        {
            if(!web.hidden)
            {
                web.hidden=YES;
            }
        }
        [db_Obj release];
    }
    else
    {
        [nonLoadkeyVal_dict setValue:value forKey:key];
    }
    
}
-(void)updateWebview:(NSString *)url
{
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if(numberOfRunningRequests!=0)
    {
        numberOfRunningRequests=0;
        if([delegate respondsToSelector:@selector(onDataPosted:)])
        {
            [delegate onDataPosted:FALSE];
        }
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        Database *db_Obj=[[Database alloc]init];
        int flag=1;
        for(int i=0;i<[[keyVal_dict allKeys] count];i++)
        {
            if(![remainkeyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]] || [remainkeyVal_dict count]==0)
            {
                int attempts=[db_Obj checkForAttempts:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                if(attempts==0)
                {
                    [db_Obj insertUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:flag:1];
                    //NSLog(@"Inserted %@",webView.request.URL);
                    //  NSLog(@"Data Inserted");
                }
                else
                {
                    //NSLog(@"%d",attempts);
                    if(attempts<5)
                    {
                        [db_Obj updateUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:attempts+1];
                        //  NSLog(@"Data Updated");
                    }
                    else{
                        [db_Obj deleteKeyValue:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                        //NSLog(@"Data deleted");
                    }
                }
            }
        }
        web_Loaded=NO;
        if(remainkeyVal_dict!=nil || nonLoadkeyVal_dict!=nil)
        {
            if([remainkeyVal_dict count]!=0 || [nonLoadkeyVal_dict count]!=0)
            {
                [self loadAnotherRequest];
            }
        }
        [db_Obj release];
    }
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(numberOfRunningRequests==0)
    {
        numberOfRunningRequests = numberOfRunningRequests + 1 ;
    }
    else
    {
        if(numberOfRunningRequests==-1)
        {
            numberOfRunningRequests=0;
            numberOfRunningRequests = numberOfRunningRequests + 1;
        }
        else
        {
            numberOfRunningRequests = numberOfRunningRequests + 1;
        }
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    numberOfRunningRequests=numberOfRunningRequests-1;
    if (numberOfRunningRequests==0) {
        if(!alertShowBool)
        {
            Database *dbvalue=[[Database alloc]init];
            if(web.tag==1)
            {
                //Delete the key and value pairs from database after sent to server.
                for(int k=0;k<[keyVal_dict count];k++)
                {
                    if(![remainkeyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:k]])
                    {
                        int attempts=[dbvalue checkForAttempts:[[keyVal_dict allKeys] objectAtIndex:k]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:k]]];
                        if(attempts!=0)
                        {
                            [dbvalue deleteKeyValue:[[keyVal_dict allKeys] objectAtIndex:k]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:k]]];
                           // NSLog(@"Database Data deleted");
                        }
                    }
                }
            }
           // NSLog(@"Passed");
            [dbvalue release];
            if(devMode)
            {
                web.hidden=NO;
                cncl_Btn.hidden=NO;
            }
            web_Loaded=NO;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if([delegate respondsToSelector:@selector(onDataPosted:)])
            {
                [delegate onDataPosted:TRUE];
            }
            // NSLog(@"Passed %@",webView.request.URL);
            alertShowBool=YES;
            if(remainkeyVal_dict!=nil || nonLoadkeyVal_dict!=nil)
            {
                if([remainkeyVal_dict count]!=0 || [nonLoadkeyVal_dict count]!=0)
                {
                    [self loadAnotherRequest];
                }
            }
            NSArray *webviews=[main_View.view subviews];
            int web_count=0;
            int btn_count=0;
            for (UIView *view in webviews) {
                if([view isKindOfClass:[UIWebView class]]){
                    web_count++;
                }
                else{
                    if([view isKindOfClass:[UIButton class]]){
                        if(view.tag==10){
                            btn_count++;
                        }
                    }
                }
            }
            if(web_count>1){
                for (UIView *view in webviews) {
                    if([view isKindOfClass:[UIWebView class]]){
                        if(web_count>=2){
                            [view removeFromSuperview];
                            web_count--;
                        }
                        else{
                            view.hidden=YES;
                        }
                    }
                    else{
                        if([view isKindOfClass:[UIButton class]]){
                            if(view.tag==10){
                                if(btn_count>=2){
                                    [view removeFromSuperview];
                                    btn_count--;
                                }
                                else{
                                    view.hidden=YES;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
-(void)loadAnotherRequest
{
    if([remainkeyVal_dict count]==0)
    {
        if([nonLoadkeyVal_dict count]!=0)
        {
            web=[[UIWebView alloc]init];
            web.delegate=self;
            web.layer.cornerRadius=5.0f;
            web.layer.borderColor=[[UIColor grayColor] CGColor];
            web.layer.borderWidth=4.0f;
            web.hidden=YES;
            [main_View.view addSubview:web];
            if(devMode)
            {
                web.frame=CGRectMake(10, 10, 300,390);
                cncl_Btn=[UIButton buttonWithType:UIButtonTypeCustom];
                cncl_Btn.frame=CGRectMake(281, 9, 30,30);
                cncl_Btn.tag=10;
                [cncl_Btn setImage:[UIImage imageNamed:@"btn-sub-del-op.png"] forState:UIControlStateNormal];
                [cncl_Btn addTarget:self action:@selector(Cancel:) forControlEvents:UIControlEventTouchUpInside];
                cncl_Btn.hidden=YES;
                [main_View.view addSubview:cncl_Btn];
            }
            else
            {
                web.frame=CGRectMake(10, 10, 1,1);
            }
            
            web_Loaded=NO;
            if(keyVal_dict!=nil)
            {
                [keyVal_dict removeAllObjects];
            }
            else{
                keyVal_dict=[[NSMutableDictionary alloc]init];
            }
            numberOfRunningRequests=-1;
            if(web_URL==nil)
            {
                web_URL=[[NSMutableString alloc]init];
            }
            else
            {
                [web_URL replaceCharactersInRange:NSMakeRange(0, [web_URL length]) withString:@""];
            }
            
            //Code to send the multiple values forevery request.
            
            for(int i=0;i<[[nonLoadkeyVal_dict allKeys] count];i++)
            {
                NSString *key=[NSString stringWithFormat:@"%@",[[nonLoadkeyVal_dict allKeys] objectAtIndex:i]];
                NSString *value=[NSString stringWithFormat:@"%@",[nonLoadkeyVal_dict objectForKey:[[nonLoadkeyVal_dict allKeys] objectAtIndex:i]]];
                if((urlStringCount + key.length + value.length + 2) <= 255)
                {
                    [keyVal_dict setValue:[nonLoadkeyVal_dict valueForKey:[[nonLoadkeyVal_dict allKeys] objectAtIndex:i]] forKey:[[nonLoadkeyVal_dict allKeys] objectAtIndex:i]];
                    urlStringCount=urlStringCount+key.length + value.length + 2;
                }
            }
            for(int j=0;j<[[keyVal_dict allKeys] count];j++)
            {
                [nonLoadkeyVal_dict removeObjectForKey:[[keyVal_dict allKeys] objectAtIndex:j]];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [self startDataUpload];
        }
        else{
            [nonLoadkeyVal_dict release];
            nonLoadkeyVal_dict=nil;
            [remainkeyVal_dict release];
            remainkeyVal_dict=nil;
            [keyVal_dict release];
            keyVal_dict=nil;
            [web_URL release];
            web_URL=nil;
            
        }
    }
    else{
        web=[[UIWebView alloc]init];
        web.delegate=self;
        web.layer.cornerRadius=5.0f;
        web.layer.borderColor=[[UIColor grayColor] CGColor];
        web.layer.borderWidth=4.0f;
        web.tag=1;
        web.hidden=YES;
        [main_View.view addSubview:web];
        if(devMode)
        {
            web.frame=CGRectMake(10, 10, 300,390);
            cncl_Btn=[UIButton buttonWithType:UIButtonTypeCustom];
            cncl_Btn.frame=CGRectMake(281, 9, 30,30);
            cncl_Btn.tag=10;
            [cncl_Btn setImage:[UIImage imageNamed:@"btn-sub-del-op.png"] forState:UIControlStateNormal];
            [cncl_Btn addTarget:self action:@selector(Cancel:) forControlEvents:UIControlEventTouchUpInside];
            cncl_Btn.hidden=YES;
            [main_View.view addSubview:cncl_Btn];
        }
        else
        {
            web.frame=CGRectMake(10, 10, 1,1);
        }
        
        if(keyVal_dict!=nil)
        {
            [keyVal_dict removeAllObjects];
        }
        else{
            keyVal_dict=[[NSMutableDictionary alloc]init];
        }
        [keyVal_dict setValuesForKeysWithDictionary:remainkeyVal_dict];
        if(web_URL==nil)
        {
            web_URL=[[NSMutableString alloc]init];
        }
        else
        {
            [web_URL replaceCharactersInRange:NSMakeRange(0, [web_URL length]) withString:@""];
        }
        numberOfRunningRequests=-1;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self startDataUpload];
    }
}
-(void)put:(NSDictionary *)dictionary
{
    if(web_URL==nil)
    {
        web_URL=[[NSMutableString alloc]init];
    }
    else
    {
        [web_URL replaceCharactersInRange:NSMakeRange(0, [web_URL length]) withString:@""];
    }
    if(keyVal_dict!=nil)
    {
        [keyVal_dict removeAllObjects];
    }
    else{
        keyVal_dict=[[NSMutableDictionary alloc]init];
    }
    [keyVal_dict setValuesForKeysWithDictionary:dictionary];
    
    //Check the settings page to find the use data is allowed to send to server or not
    Database *db_Obj=[[Database alloc]init];
    NSString *value=[db_Obj getUserDataValue];
    if([value isEqualToString:@"YES"])
    {
        numberOfRunningRequests=-1;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        if (networkStatus != NotReachable)
        {
            [self startDataUpload];
        }
        else
        {
            [self webView:nil didFailLoadWithError:nil];
        }
    }
    else{
        if(!web.hidden)
        {
            web.hidden=YES;
        }
    }
    [db_Obj release];
    
}
-(void)startBackgroundJob:(NSDictionary *)dictionary
{
    if(remainkeyVal_dict!=nil)
    {
        [remainkeyVal_dict removeAllObjects];
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //send the dictinary details to blluekai server
    NSMutableString *url_string=[[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"%@%@?",server_URL,siteId]];
    [url_string appendString:[NSString stringWithFormat:@"appVersion=%@",appVersion]];
    [url_string appendString:[NSString stringWithFormat:@"&identifierForVendor=%@",[NSString stringWithFormat:@"%@",[self getVendorID]]]];
    urlStringCount=url_string.length;
    for(int i=0;i<[[keyVal_dict allKeys] count];i++)
    {
        NSString *key=[NSString stringWithFormat:@"%@",[[keyVal_dict allKeys] objectAtIndex:i]];
        NSString *value=[NSString stringWithFormat:@"%@",[keyVal_dict objectForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
        if((url_string.length + key.length + value.length + 2) > 255)
        {
            [remainkeyVal_dict setValue:value forKey:key];
        }
        else
        {
            [url_string appendString:[NSString stringWithFormat:@"&%@=%@",[self urlEncode:[[keyVal_dict allKeys] objectAtIndex:i]],[self urlEncode:[keyVal_dict objectForKey:[[keyVal_dict allKeys] objectAtIndex:i]]]]];
        }
    }
    // NSString *encode_String=[url_string urlencode];
  NSLog(@"Encoded Url:%@",url_string);
    [web_URL appendString:url_string];
    [url_string release];
    [pool release];
    alertShowBool=NO;
    
    
    // web.tag=1;
    [self updateWebview:web_URL];
}
- (NSString *)urlEncode:(NSString *)string
{
    NSMutableString *output = [NSMutableString string];
  
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
-(NSString *)getVendorID
{
    NSString *vendorId;
    NSString *osVersion=[[UIDevice currentDevice] systemVersion];
    if([osVersion floatValue]>=6.0)
    {
        vendorId=[[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    else{
        if([osVersion floatValue]>=5.0)
        {
            vendorId=[Bluekai_OpenUDID value];
        }
        else{
            vendorId=[[UIDevice currentDevice]uniqueIdentifier];
        }
    }
    return vendorId;
}

-(void)showSettingsScreen
{
//    NSArray *array=[main_View.view subviews];
//    for (UIView *view in array) {
//        if(![view isKindOfClass:[UIWebView class]])
//        {
//            [view removeFromSuperview];
//        }
//    }
    user_defaults=[NSUserDefaults standardUserDefaults];
    usrcheck_image=[[UIImageView alloc]initWithFrame:CGRectMake(25, 100, 40, 40)];
    checkimage=[[NSArray alloc]initWithObjects:@"chk-1.png",@"unchk-1.png",nil];
    
    UIGraphicsBeginImageContext(usrcheck_image.frame.size);
    Database *db=[[Database alloc]init];
    NSString *value=[db getUserDataValue];
    if([value isEqualToString:@"YES"])
    {
        [[UIImage imageNamed:@"chk-1.png"] drawInRect:usrcheck_image.bounds];
        [user_defaults setObject:@"YES" forKey:@"KeyTouserData"];
        usrcheck_image.tag=0;
    }
    else
    {
        [[UIImage imageNamed:@"unchk-1.png"] drawInRect:usrcheck_image.bounds];
        [user_defaults setObject:@"NO" forKey:@"KeyTouserData"];
        usrcheck_image.tag=1;
    }
    UIImage *lblimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    usrcheck_image.image=lblimage;
    usrcheck_image.userInteractionEnabled=YES;
    tap1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userData_Change:)];
    tap1.delegate=self;
    [usrcheck_image addGestureRecognizer:tap1];
    [main_View.view addSubview:usrcheck_image];
    
    UILabel *usrData_lbl=[[UILabel alloc]initWithFrame:CGRectMake(75, 95, 240, 50)];
    usrData_lbl.textColor=[UIColor blackColor];
    usrData_lbl.backgroundColor=[UIColor clearColor];
    usrData_lbl.textAlignment=UITextAlignmentLeft;
    usrData_lbl.numberOfLines=0;
    usrData_lbl.lineBreakMode=UILineBreakModeWordWrap;
    usrData_lbl.font=[UIFont systemFontOfSize:14];
    usrData_lbl.text=@"Allow Bluekai to receive my data";
    [main_View.view addSubview:usrData_lbl];
    [usrData_lbl release];
    
    UILabel *tclbl=[[UILabel alloc]initWithFrame:CGRectMake(25, 235, 280, 50)];
    tclbl.textColor=[UIColor blackColor];
    tclbl.backgroundColor=[UIColor clearColor];
    tclbl.textAlignment=UITextAlignmentLeft;
    tclbl.numberOfLines=3;
    tclbl.lineBreakMode=UILineBreakModeWordWrap;
    tclbl.font=[UIFont systemFontOfSize:14];
    tclbl.text=@"The BlueKai privacy policy is available";
    [main_View.view addSubview:tclbl];
    [tclbl release];
    
    UIButton *Here=[UIButton buttonWithType:UIButtonTypeCustom];
    Here.frame=CGRectMake(256, 253, 50, 14);
    [Here setTitle:@"here" forState:UIControlStateNormal];
    Here.titleLabel.font = [UIFont systemFontOfSize:14];
    [Here addTarget:self action:@selector(termsConditions:) forControlEvents:UIControlEventTouchUpInside];
    [Here setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [main_View.view addSubview:Here];
    
    
    UIButton *savebtn=[UIButton buttonWithType:UIButtonTypeCustom];
    savebtn.frame=CGRectMake(75, 290, 80, 35);
    [savebtn setTitle:@"Save" forState:UIControlStateNormal];
    [savebtn.layer setBorderWidth:2.0f];
    [savebtn.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [savebtn.layer setCornerRadius:5.0f];
    [savebtn addTarget:self action:@selector(saveSettings:) forControlEvents:UIControlEventTouchUpInside];
    [savebtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [main_View.view addSubview:savebtn];
    
    UIButton *Cnclbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    Cnclbtn.frame=CGRectMake(175, 290, 80, 35);
    [Cnclbtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [Cnclbtn.layer setBorderWidth:2.0f];
    [Cnclbtn.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [Cnclbtn.layer setCornerRadius:5.0f];
    [Cnclbtn addTarget:self action:@selector(Cancelbtn:) forControlEvents:UIControlEventTouchUpInside];
    [Cnclbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [main_View.view addSubview:Cnclbtn];
    [usrcheck_image release];
    [tccheck_image release];
    [db release];
    [main_View.view addSubview:web];
    [main_View.view addSubview:cncl_Btn];
}
-(void)userData_Change:(UITapGestureRecognizer *)recognizer
{
    if(usrcheck_image.tag==1)
    {
        UIGraphicsBeginImageContext(usrcheck_image.frame.size);
        [[UIImage imageNamed:@"chk-1.png"] drawInRect:usrcheck_image.bounds];
        UIImage *appsimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        usrcheck_image.image=appsimage;
        [user_defaults setObject:@"YES" forKey:@"KeyTouserData"];
        usrcheck_image.tag=0;
    }
    else
    {
        UIGraphicsBeginImageContext(usrcheck_image.frame.size);
        [[UIImage imageNamed:@"unchk-1.png"] drawInRect:usrcheck_image.bounds];
        UIImage *appsimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        usrcheck_image.image=appsimage;
        [user_defaults setObject:@"NO" forKey:@"KeyTouserData"];
        usrcheck_image.tag=1;
        
    }
    
}
-(IBAction)termsConditions:(id)sender
{
    NSString *shareUrlString = [NSString stringWithFormat:@"http://www.bluekai.com/consumers_privacyguidelines.php"];
    
    NSURL *Hereurl = [ [ NSURL alloc ] initWithString:shareUrlString ];
    //Create the URL object
    
    [[UIApplication sharedApplication] openURL:Hereurl];
    //Launch Safari with the URL you created
    [Hereurl release];
    
}
-(IBAction)Cancelbtn:(id)sender
{
    
}
-(IBAction)Cancel:(id)sender
{
    web.hidden=YES;
    cncl_Btn.hidden=YES;
}
-(void)setPreference:(BOOL)optIn
{
    user_defaults=[NSUserDefaults standardUserDefaults];
    if(optIn)
    {
        [user_defaults setObject:@"YES" forKey:@"KeyTouserData"];
    }
    else{
        [user_defaults setObject:@"NO" forKey:@"KeyTouserData"];
    }
    
    [self saveSettings:nil];
    
    [self updateServer];
}
-(IBAction)saveSettings:(id)sender
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    Database *dbvalue=[[Database alloc]init];
    NSString *userDataValue=[user_defaults objectForKey:@"KeyTouserData"];
    [dbvalue deleteUserData];
    [dbvalue insertUserDataValue:userDataValue];
    [dbvalue release];
    [self updateServer];
}
-(void)updateServer
{
    //web_URL=nil;
    if(web_URL==nil)
    {
        web_URL=[[NSMutableString alloc]init];
    }
    else
    {
        [web_URL replaceCharactersInRange:NSMakeRange(0, [web_URL length]) withString:@""];
    }
    keyVal_dict=[[NSMutableDictionary alloc]init];
    if([[user_defaults objectForKey:@"KeyTouserData"] isEqualToString:@"YES"])
    {
        value_str=@"1";
    }
    else
    {
        value_str=@"0";
    }
    [keyVal_dict setValue:value_str forKey:[NSString stringWithFormat:@"TC"]];
    numberOfRunningRequests=-1;
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus != NotReachable)
    {
        [self startDataUpload];
    }
    else
    {
        [self webView:nil didFailLoadWithError:nil];
    }
}
-(void)startDataUpload
{
    
    Database *db_Obj=[[Database alloc]init];
    int flag=1;
    if(main_View!=nil)
    {
        if(siteId!=nil)
        {
            if(appVersion!=nil)
            {
                [NSThread detachNewThreadSelector:@selector(startBackgroundJob:) toTarget:self withObject:keyVal_dict];
            }
            else{
                NSLog(@"appVersion parameter is nil");
                
                for(int i=0;i<[[keyVal_dict allKeys] count];i++)
                {
                    if(![remainkeyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]])
                    {
                        int attempts=[db_Obj checkForAttempts:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                        if(attempts==0)
                        {
                            [db_Obj insertUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:flag:1];
                        }
                        else
                        {
                            //NSLog(@"%d",attempts);
                            if(attempts<5)
                            {
                                [db_Obj updateUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:attempts+1];
                            }
                            else{
                                [db_Obj deleteKeyValue:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                            }
                        }
                    }
                }
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        }
        else{
            if(appVersion!=nil)
            {
                NSLog(@"siteId parameter is nil");
            }
            else{
                NSLog(@"siteId and appVersion parameters are nil");
            }
            
            for(int i=0;i<[[keyVal_dict allKeys] count];i++)
            {
                if(![remainkeyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]])
                {
                    int attempts=[db_Obj checkForAttempts:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                    if(attempts==0)
                    {
                        [db_Obj insertUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:flag:1];
                    }
                    else
                    {
                        if(attempts<5)
                        {
                            [db_Obj updateUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:attempts+1];
                        }
                        else{
                            [db_Obj deleteKeyValue:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                        }
                    }
                }
            }            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }
    else
    {
        if(siteId!=nil && appVersion!=nil)
        {
            NSLog(@"view parameter is nil");
        }
        else
        {
            if(siteId!=nil)
            {
                if(appVersion!=nil)
                {
                    NSLog(@"view parameter is nil");
                }
                else{
                    NSLog(@"view and appVersion parameters are nil");
                }
            }
            else{
                if(appVersion!=nil)
                {
                    NSLog(@"siteId and view parameters are nil");
                }
                else{
                    NSLog(@"siteId,view and appVersion parameters are nil");
                }
            }
        }
        int flag=1;
        for(int i=0;i<[[keyVal_dict allKeys] count];i++)
        {
            if(![remainkeyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]])
            {
                int attempts=[db_Obj checkForAttempts:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                if(attempts==0)
                {
                    [db_Obj insertUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:flag:1];
                }
                else
                {
                    if(attempts<5)
                    {
                        [db_Obj updateUserDetails:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]:attempts+1];
                    }
                    else{
                        [db_Obj deleteKeyValue:[[keyVal_dict allKeys] objectAtIndex:i]:[keyVal_dict valueForKey:[[keyVal_dict allKeys] objectAtIndex:i]]];
                    }
                }
            }
        }        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    }
    [db_Obj release];
}
-(void)resume
{
    Database *db_obj=[[Database alloc]init];
    if(web_URL==nil)
    {
        web_URL=[[NSMutableString alloc]init];
    }
    else
    {
        [web_URL replaceCharactersInRange:NSMakeRange(0, [web_URL length]) withString:@""];
    }
    keyVal_dict=[[NSMutableDictionary alloc]initWithDictionary:[db_obj getKeyValues]];
    if([[keyVal_dict allKeys] count]!=0)
    {
        numberOfRunningRequests=-1;
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        if (networkStatus != NotReachable)
        {
            web.tag=1;
            [self startDataUpload];
        }
        else
        {
            [self webView:nil didFailLoadWithError:nil];
        }
        
        
    }
    [db_obj release];
    
    
}
-(void)dealloc
{
    [super dealloc];
}

@end
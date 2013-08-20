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


#import <UIKit/UIKit.h>

@interface DevSettingsViewController : UIViewController<UITextFieldDelegate>
{
   IBOutlet UILabel *devMode_lbl,*url_Lbl;
   IBOutlet UIImageView *dev_image;
   IBOutlet UITextField *siteId_Txtfield;
    UITapGestureRecognizer *dev_tap;
    IBOutlet UIButton *dev_btn;
    NSMutableDictionary *config_dict;
    NSString *plist_path;
}

@end

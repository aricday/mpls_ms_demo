MASUI is the core UI framework of the iOS Mobile SDK, which is part of CA Mobile API Gateway. It provides resources to implement a user login dialog, Social Login, One-Time Password, and Proximity Login (QR code and BLE) saving developers the time of building those UI as well as providing them with a fast way for prototyping apps. 

## Features

The MASUI framework comes with the following features:

- Default log-in dialog
    + Built-in QR Code registration/authentication
    + Built-in BLE registration/authentication
    + Built-in social network (Google, Facebook, Salesforce, and LinkedIn) registration/authentication
- One-Time Password dialogs
  + Channel selection (i.e. email, sms)
  + OTP challenger
- Session lock

## Get Started

- Check out our [documentation][docs] for sample code, video tutorials, and more.
- [Download MASUI][download] 


## Communication

- *Have general questions or need help?*, use [Stack Overflow][StackOverflow]. (Tag 'massdk')
- *Find a bug?*, open an issue with the steps to reproduce it.
- *Request a feature or have an idea?*, open an issue.

## How You Can Contribute

Contributions are welcome and much appreciated. To learn more, see the [Contribution Guidelines][contributing].

## Installation

MASUI supports multiple methods for installing the library in a project.

### Cocoapods (Podfile) Install

To integrate MASUI into your Xcode project using CocoaPods, specify it in your **Podfile:**

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

pod 'MASUI'
```
Then, run the following command using the command prompt from the folder of your project:

```
$ pod install
```

### Manual Install

For manual install, you add the Mobile SDK to your Xcode project. Note that you must add the MASFoundation library. For complete MAS functionality, install all of the MAS libraries as shown.

1. Open your project in Xcode.
2. Drag the SDK library files, and drop them into your project in the left navigator panel in Xcode. Select the option, `Copy items if needed`.
3. Select `File->Add files to 'project name'` and add the msso_config.json file from your project folder.
4. In Xcode "Build Setting” of your Project Target, add `-ObjC` for `Other Linker Flags`.
5. Import the following Mobile SDK library header file to the classes or to the .pch file if your project has one.

```
#import <MASFoundation/MASFoundation.h>
#import <MASUI/MASUI.h>
```

## UI Templates

The MASUI library contains graphic and xib files to speed up development time. The library provides the following UI components:

- User Login Dialog
- Social Login
- One Time Password
- Session Lock

### User Login Dialog

<p style="text-align:center"><img src="http://mas.ca.com/docs/ios/1.3.00/guides/images/SocialLogin.png" width="300"></p>

To use the user login dialog, drag and drop `MASUI.framework` and `MASUIResources.bundle` into your project.  After the MASUI library is added to the project, MASFoundation automatically detects the presence of the MASUI library and processes the user login as needed.

MASUI provides the following method to enable or disable the login dialog.  If MASUI is disabled to handle the authentication,  `MASUserLoginBlock` is invoked to retrieve the username and password.

```
/**
 * Set the handling state of the authentication UI by this library.
 *
 * @param handle YES if you want the library to enable it, NO if not.
 *     YES is the default.
 */
+ (void)setWillHandleAuthentication:(BOOL)handle;
``` 

The user login dialog prompts whenever MASFoundation realizes that user authentication is required or you call the following method to present the login screen.

```
//
// Display the login screen
//
[[MASUser currentUser] presentLoginViewControllerWithCompletion:^(BOOL completed, NSError *error){
	
}];
```

### Customize User Login Dialog

To customize the user login dialog, you need the MASUI library and create your own login view controller, which inherits ```MASBaseLoginViewController```.  After creating your own user login dialog, you simply set the default user login screen in MASUI library, so that the custom login screen prompts whenever the user authentication is required.  

::: alert danger
**Important!** Do not modify properties of ```MASBaseLoginViewController``` for any reason.  These properties are used internally to process the authentication. Changing them can result in several types of app failures.  
:::

#### MASBaseLoginViewController

Before implementing the custom login dialog, implement the following methods and also invoke the parent's method.

*```- (void)viewWillReload;```*

This method is invoked **before** the user login screen prompt.  This method prepares the data source of the UI and other logic with the latest authentication information.  

```
- (void)viewWillReload
{
   [super viewWillReload];

	//
	// Prepare for data source and other logic
	//    
}
```


*```- (void)viewDidReload;```*

This method is invoked **after** the user login screen prompt.  This method reloads all UI elements and other logic.  

```
- (void)viewDidReload
{
   [super viewDidReload];

	//
	// Reload all UI elements and logic
	//    
}
```


*```- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(MASCompletionErrorBlock)completion;```*

This method can be invoked with the given user credentials to perform user authentication.  Note that successful authentication of this method does not dismiss the user login screen; it must be dismissed explicitly by calling the dismiss method.

```
// 
// On your custom IBAction, or other places to perform authentication
//
- (IBAction)onLoginButtonSelected:(id)sender
{
	[self loginWithUsername:@"username" password:@"password" completion:^(BOOL completed, NSError *error){
	
		//
		// handle the result
		//
	}];
}
```


*```- (void)loginWithAuthorizationCode:(NSString *)authorizationCode completion:(MASCompletionErrorBlock)completion;```*

This method can be invoked with the given authorization code to perform user authentication.  Note that successful authentication of this method does not dismiss the user login screen; it must be dismissed explicitly by calling the dismiss method.

```
// 
// On your custom IBAction or other places to perform authentication
//
- (IBAction)onLoginButtonSelected:(id)sender
{
	[self loginWithAuthorizationCode:@"auth_code" completion:^(BOOL completed, NSError *error){
	
		//
		// handle the result
		//
	}];
}
```


*```- (void)cancel;```*

This method can be invoked when users want to cancel the authentication process or close the user login screen. By invoking this method, the user login screen is dismissed.
  
```
- (void)cancel
{
   [super cancel];

	//
	// Do what you have to do upon cancel
	//    
}
```


*```- (void)dismissLoginViewControllerAnimated:(BOOL)animated completion: (void (^)(void))completion;```*

This method can be invoked to dismiss the user login screen upon successful authentication, or other times that you want to dismiss the login screen.
  
```
//
// Dismiss the view controller
//
[self dismissLoginViewControllerAnimated:YES completion:nil];
```

#### Set the custom login screen as default

After creating the custom login screen, you must create a view controller object and set it as the default login screen in the MASUI library with the following method.  

::: alert danger
**Important:** Note that the user login dialog view controller object is **reused**for multiple user logins.  It is important to properly organize the lifecycle of the UI elements before and after the user authentication with the provided methods.  
:::

```
/**
 Set the custom login view controller for handling by MASUI library

 @param viewController view controller object that inherited MASBaseLoginViewController
 */
+ (void)setLoginViewController:(MASBaseLoginViewController *)viewController;
```

### Social Login

The social login feature is included in the user login dialog (described in the previous section). No configuration is required to set up the social login.

### Session Lock Screen

<p style="text-align:center"><img src="http://mas.ca.com/docs/ios/1.3.00/guides/images/SessionLock.png" width="300"></p>
<p style="text-align:center"><img src="http://mas.ca.com/docs/ios/1.3.00/guides/images/SessionLock-default.png" width="300"></p>

Session lock screen is provided by simply dropping the MASUI.framework and MASUIResource.bundle into your project.  MASFoundation detects the presence of the MASUI library and presents the session lock screen upon the API call.

```
/**
 Display currently set lock screen view controller in MASUI for locked session
 
 @param completion MASCompletionErrorBlock to notify the result of the displaying lock screen.
 */
+ (void)presentSessionLockScreenViewController:(MASCompletionErrorBlock)completion;
```

#### Customize session lock screen

You can customize the session lock screen with custom logic for locking and unlocking the session, and for branding.  The session lock screen must inherit from the MASViewController (MASUI library).  For more information about fingerprint session lock APIs in the MASFoundation library, see [Fingerprint Sessions Lock section](#fingerprint-sessions-lock).

After creating your own screen, simply set the default session lock screen in the MASUI library; your own screen then prompts when you call to present the session lock screen.

```
/**
 Set custom lock screen view controller that inherits MASViewController

 @param viewController MASViewController of the lock screen
 */
+ (void)setLockScreenViewController:(MASViewController *)viewController
```

### One Time Password 

To use the One Time Password dialogs, drag and drop the MASUI.framework and MASUIResources.bundle into your project. The MASFoundation detects the presence of the MASUI library and processes the One Time Password.

#### OTP Delivery Channel Dialog   

<p style="text-align:center"><img src="http://mas.ca.com/docs/ios/1.3.00/guides/images/DeliveryChannel.png" width="300"></p>
  

MASUI provides the following method to enable or disable the OTP Delivery Channel dialog.         

```
/**
 * Set the handling state of the OTP authentication UI by this framework.
 *
 * @param handle YES if you want the framework to enable it, NO if not.
 *     YES is the default.
 */
+ (void)setWillHandleOTPAuthentication:(BOOL)handle;
```

If MASUI is disabled to handle the OTP authentication, MASOTPChannelSelectionBlock is invoked to retrieve the OTP delivery channels.

#### One Time Password Dialog

<p style="text-align:center"><img src="http://mas.ca.com/docs/ios/1.3.00/guides/images/OTP.png" width="300"></p>

MASUI provides the following method to enable or disable the One Time Password dialog.

```
/**
 * Set the handling state of the OTP authentication UI by this framework.
 *
 * @param handle YES if you want the framework to enable it, NO if not.
 *     YES is the default.
 */
+ (void)setWillHandleOTPAuthentication:(BOOL)handle;
```
If MASUI is disabled to handle the OTP authentication, MASOTPCredentialsBlock is invoked to retrieve the one time password.

## License

Copyright (c) 2016 CA. All rights reserved.

This software may be modified and distributed under the terms
of the MIT license. See the [LICENSE][license-link] file for details.

 [mag]: https://docops.ca.com/mag
 [mas.ca.com]: http://mas.ca.com/
 [get-started]: http://mas.ca.com/get-started/
 [docs]: http://mas.ca.com/docs/
 [blog]: http://mas.ca.com/blog/
 [videos]: https://www.ca.com/us/developers/mas/videos.html
 [StackOverflow]: http://stackoverflow.com/questions/tagged/massdk
 [download]: https://github.com/CAAPIM/iOS-MAS-UI/archive/master.zip
 [contributing]: https://github.com/CAAPIM/iOS-MAS-UI/blob/develop/CONTRIBUTING.md
 [license-link]: /LICENSE

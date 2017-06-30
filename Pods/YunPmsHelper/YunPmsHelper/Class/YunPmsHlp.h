//
// Created by yun on 2017/6/30.
// Copyright (c) 2017 yun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ClusterPrePermissions/ClusterPrePermissions.h>

@interface YunPmsHlp : NSObject {

}

/**
 * A general descriptor for the possible outcomes of a dialog.
 */
typedef NS_ENUM(NSInteger, YunDgRst) {
    /// User was not given the chance to take action.
    /// This can happen if the permission was
    /// already granted, denied, or restricted.
            YunDgRstNoActionTaken,
    /// User declined access in the user dialog or system dialog.
            YunDgRstDenied,
    /// User granted access in the user dialog or system dialog.
            YunDgRstGranted,
    /// The iOS parental permissions prevented access.
    /// This outcome would only happen on the system dialog.
            YunDgRstParentallyRestricted
};

/**
 * A general descriptor for the possible outcomes of Authorization Status.
 */
typedef NS_ENUM(NSInteger, YunAuthStatus) {
    /// Permission status undetermined.
            YunAuthStatusUnDetermined,
    /// Permission denied.
            YunAuthStatusDenied,
    /// Permission authorized.
            YunAuthStatusAuthorized,
    /// The iOS parental permissions prevented access.
            YunAuthStatusRestricted
};

/**
 * Authorization methods for the usage of location services.
 */
typedef NS_ENUM(NSInteger, YunLocAuthType) {
    /// the “when-in-use” authorization grants the app to start most
    /// (but not all) location services while it is in the foreground.
            YunLocAuthTypeWhenInUse,
    /// the “always” authorization grants the app to start all
    /// location services
            YunLocAuthTypeAlways,
};

/**
 * Authorization methods for the usage of event services.
 */
typedef NS_ENUM(NSInteger, YunEventAuthType) {
    /// Authorization for events only
            YunEventAuthTypeEvent,
    /// Authorization for reminders only
            YunEventAuthTypeReminder
};

/**
 * Authorization methods for the usage of Contacts services(Handling existing of AddressBook or Contacts framework).
 */
typedef NS_ENUM(NSInteger, YunContactsAuthType) {
    YunContactsAuthorizationStatusNotDetermined = 0,
    /*! The application is not authorized to access contact data.
     *  The user cannot change this application’s status, possibly due to active restrictions such as parental controls being in place. */
            YunContactsAuthorizationStatusRestricted,
    /*! The user explicitly denied access to contact data for the application. */
            YunContactsAuthorizationStatusDenied,
    /*! The application is authorized to access contact data. */
            YunContactsAuthorizationStatusAuthorized
};

/**
 * Authorization methods for the usage of AV services.
 */
typedef NS_ENUM(NSInteger, YunAVAuthType) {
    /// Authorization for Camera only
            YunAVAuthTypeCamera,
    /// Authorization for Microphone only
            YunAVAuthTypeMicrophone
};

typedef NS_OPTIONS(NSUInteger, YunPushNotiType) {
    YunPushNotiTypeNone = 0, // the application may not present any UI upon a notification being received
    YunPushNotiTypeBadge = 1 << 0, // the application may badge its icon upon a notification being received
    YunPushNotiTypeSound = 1 << 1, // the application may play a sound upon a notification being received
    YunPushNotiTypeAlert = 1 << 2, // the application may display an alert upon a notification being received
};

/**
 * General callback for permissions.
 * @param hasPms Returns YES if system permission was granted
 *                      or is already available, NO otherwise.
 * @param userDr Describes whether the user granted/denied access,
 *                         or if the user didn't have an opportunity to take action.
 *                         YunDgRstParentallyRestricted is never returned.
 * @param sysDr Describes whether the user granted/denied access,
 *                           or was parentally restricted, or if the user didn't
 *                           have an opportunity to take action.
 * @see YunDgRst
 */
typedef void (^YunPrePmsCmpHandler)(BOOL hasPms,
                                    YunDgRst userDr,
                                    YunDgRst sysDr);

+ (instancetype)instance;

+ (YunAuthStatus)cameraPmsAuthStatus;

+ (YunAuthStatus)microphonePmsAuthStatus;

+ (YunAuthStatus)photoPmsAuthStatus;

+ (YunAuthStatus)contactsPmsAuthStatus;

+ (YunAuthStatus)eventPmsAuthStatus:(YunEventAuthType)eventType;

+ (YunAuthStatus)locationPmsAuthStatus;

+ (YunAuthStatus)pushNotificationPmsAuthStatus;

- (void)showAVPmsWithType:(YunAVAuthType)mediaType
                    title:(NSString *)requestTitle
                  message:(NSString *)message
                  denyBtn:(NSString *)denyBtn
                 grantBtn:(NSString *)grantBtn
               cmpHandler:(YunPrePmsCmpHandler)cmpHandler;

- (void)showCameraPmsWithTitle:(NSString *)requestTitle
                       message:(NSString *)message
                       denyBtn:(NSString *)denyBtn
                      grantBtn:(NSString *)grantBtn
                    cmpHandler:(YunPrePmsCmpHandler)cmpHandler;

- (void)showMicrophonePmsWithTitle:(NSString *)requestTitle
                           message:(NSString *)message
                           denyBtn:(NSString *)denyBtn
                          grantBtn:(NSString *)grantBtn
                        cmpHandler:(YunPrePmsCmpHandler)cmpHandler;

- (void)showPhotoPmsWithTitle:(NSString *)requestTitle
                      message:(NSString *)message
                      denyBtn:(NSString *)denyBtn
                     grantBtn:(NSString *)grantBtn
                   cmpHandler:(YunPrePmsCmpHandler)cmpHandler;

- (void)showContactsPmsWithTitle:(NSString *)requestTitle
                         message:(NSString *)message
                         denyBtn:(NSString *)denyBtn
                        grantBtn:(NSString *)grantBtn
                      cmpHandler:(YunPrePmsCmpHandler)cmpHandler;

- (void)showEventPmsWithType:(YunEventAuthType)eventType
                       Title:(NSString *)requestTitle
                     message:(NSString *)message
                     denyBtn:(NSString *)denyBtn
                    grantBtn:(NSString *)grantBtn
                  cmpHandler:(YunPrePmsCmpHandler)cmpHandler;

- (void)showLocationPmsWithTitle:(NSString *)requestTitle
                         message:(NSString *)message
                         denyBtn:(NSString *)denyBtn
                        grantBtn:(NSString *)grantBtn
                      cmpHandler:(YunPrePmsCmpHandler)cmpHandler;

- (void)showLocPmsForAuthType:(YunLocAuthType)authorizationType
                        title:(NSString *)requestTitle
                      message:(NSString *)message
                      denyBtn:(NSString *)denyBtn
                     grantBtn:(NSString *)grantBtn
                   cmpHandler:(YunPrePmsCmpHandler)cmpHandler;

/**
 * @description (Experimental) This checks for your current push notifications
 * authorization and attempts to register for push notifications for you.
 * See discussion below.
 * @discussion This is NOT RECOMMENDED for using in your apps, unless
 * you are a simple app and don't care too much about push notifications.
 * In some cases, this will not reliably check for push notifications or request them.
 * * Uninstalling/reinstalling your app within 24 hours may break this, your callback may
 * not be fired.
 */
- (void)showPushNotiPmsWithType:(YunPushNotiType)requestedType
                          title:(NSString *)requestTitle
                        message:(NSString *)message
                        denyBtn:(NSString *)denyBtn
                       grantBtn:(NSString *)grantBtn
                     cmpHandler:(YunPrePmsCmpHandler)cmpHandler;

@end
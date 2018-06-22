//
// Created by yun on 2017/6/30.
// Copyright (c) 2017 yun. All rights reserved.
//

#import "YunPmsHlp.h"

@implementation YunPmsHlp

+ (YunPmsHlp *)instance {
    static YunPmsHlp *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

+ (YunAuthStatus)cameraPmsAuthStatus {
    return (YunAuthStatus) [ClusterPrePermissions cameraPermissionAuthorizationStatus];
}

+ (YunAuthStatus)microphonePmsAuthStatus {
    return (YunAuthStatus) [ClusterPrePermissions microphonePermissionAuthorizationStatus];
}

+ (YunAuthStatus)photoPmsAuthStatus {
    return (YunAuthStatus) [ClusterPrePermissions photoPermissionAuthorizationStatus];
}

+ (YunAuthStatus)contactsPmsAuthStatus {
    return (YunAuthStatus) [ClusterPrePermissions contactsPermissionAuthorizationStatus];
}

+ (YunAuthStatus)eventPmsAuthStatus:(YunEventAuthType)eventType {
    return (YunAuthStatus) [ClusterPrePermissions eventPermissionAuthorizationStatus:
                                                          (ClusterEventAuthorizationType) eventType];
}

+ (YunAuthStatus)locationPmsAuthStatus {
    return (YunAuthStatus) [ClusterPrePermissions locationPermissionAuthorizationStatus];
}

+ (YunAuthStatus)pushNotificationPmsAuthStatus {
    return (YunAuthStatus) [ClusterPrePermissions pushNotificationPermissionAuthorizationStatus];
}

- (void)showAVPmsWithType:(YunAVAuthType)mediaType
                    title:(NSString *)requestTitle
                  message:(NSString *)message
                  denyBtn:(NSString *)denyBtn
                 grantBtn:(NSString *)grantBtn
               cmpHandler:(YunPrePmsCmpHandler)cmpHandler {
    [[ClusterPrePermissions sharedPermissions]
                            showAVPermissionsWithType:(ClusterAVAuthorizationType) mediaType
                                                title:requestTitle
                                              message:message
                                      denyButtonTitle:denyBtn
                                     grantButtonTitle:grantBtn
                                    completionHandler:^(BOOL hasPermission,
                                                        ClusterDialogResult userDialogResult,
                                                        ClusterDialogResult systemDialogResult) {
                                        cmpHandler(hasPermission,
                                                   (YunDgRst) userDialogResult,
                                                   (YunDgRst) systemDialogResult);
                                    }];

}

- (void)showCameraPmsWithTitle:(NSString *)requestTitle
                       message:(NSString *)message
                       denyBtn:(NSString *)denyBtn
                      grantBtn:(NSString *)grantBtn
                    cmpHandler:(YunPrePmsCmpHandler)cmpHandler {
    [[ClusterPrePermissions sharedPermissions]
                            showCameraPermissionsWithTitle:requestTitle
                                                   message:message
                                           denyButtonTitle:denyBtn
                                          grantButtonTitle:grantBtn
                                         completionHandler:^(BOOL hasPermission,
                                                             ClusterDialogResult userDialogResult,
                                                             ClusterDialogResult systemDialogResult) {
                                             cmpHandler(hasPermission,
                                                        (YunDgRst) userDialogResult,
                                                        (YunDgRst) systemDialogResult);
                                         }];
}

- (void)showMicrophonePmsWithTitle:(NSString *)requestTitle
                           message:(NSString *)message
                           denyBtn:(NSString *)denyBtn
                          grantBtn:(NSString *)grantBtn
                        cmpHandler:(YunPrePmsCmpHandler)cmpHandler {
    [[ClusterPrePermissions sharedPermissions]
                            showMicrophonePermissionsWithTitle:requestTitle
                                                       message:message
                                               denyButtonTitle:denyBtn
                                              grantButtonTitle:grantBtn
                                             completionHandler:^(BOOL hasPermission,
                                                                 ClusterDialogResult userDialogResult,
                                                                 ClusterDialogResult systemDialogResult) {
                                                 cmpHandler(hasPermission,
                                                            (YunDgRst) userDialogResult,
                                                            (YunDgRst) systemDialogResult);
                                             }];
}

- (void)showPhotoPmsWithTitle:(NSString *)requestTitle
                      message:(NSString *)message
                      denyBtn:(NSString *)denyBtn
                     grantBtn:(NSString *)grantBtn
                   cmpHandler:(YunPrePmsCmpHandler)cmpHandler {
    [[ClusterPrePermissions sharedPermissions]
                            showPhotoPermissionsWithTitle:requestTitle
                                                  message:message
                                          denyButtonTitle:denyBtn
                                         grantButtonTitle:grantBtn
                                        completionHandler:^(BOOL hasPermission,
                                                            ClusterDialogResult userDialogResult,
                                                            ClusterDialogResult systemDialogResult) {
                                            cmpHandler(hasPermission,
                                                       (YunDgRst) userDialogResult,
                                                       (YunDgRst) systemDialogResult);
                                        }];
}

- (void)showContactsPmsWithTitle:(NSString *)requestTitle
                         message:(NSString *)message
                         denyBtn:(NSString *)denyBtn
                        grantBtn:(NSString *)grantBtn
                      cmpHandler:(YunPrePmsCmpHandler)cmpHandler {
    [[ClusterPrePermissions sharedPermissions]
                            showContactsPermissionsWithTitle:requestTitle
                                                     message:message
                                             denyButtonTitle:denyBtn
                                            grantButtonTitle:grantBtn
                                           completionHandler:^(BOOL hasPermission,
                                                               ClusterDialogResult userDialogResult,
                                                               ClusterDialogResult systemDialogResult) {
                                               cmpHandler(hasPermission,
                                                          (YunDgRst) userDialogResult,
                                                          (YunDgRst) systemDialogResult);
                                           }];
}

- (void)showEventPmsWithType:(YunEventAuthType)eventType
                       Title:(NSString *)requestTitle
                     message:(NSString *)message
                     denyBtn:(NSString *)denyBtn
                    grantBtn:(NSString *)grantBtn
                  cmpHandler:(YunPrePmsCmpHandler)cmpHandler {
    [[ClusterPrePermissions sharedPermissions]
                            showEventPermissionsWithType:(ClusterEventAuthorizationType) eventType
                                                   Title:requestTitle
                                                 message:message
                                         denyButtonTitle:denyBtn
                                        grantButtonTitle:grantBtn
                                       completionHandler:^(BOOL hasPermission,
                                                           ClusterDialogResult userDialogResult,
                                                           ClusterDialogResult systemDialogResult) {
                                           cmpHandler(hasPermission,
                                                      (YunDgRst) userDialogResult,
                                                      (YunDgRst) systemDialogResult);
                                       }];
}

- (void)showLocationPmsWithTitle:(NSString *)requestTitle
                         message:(NSString *)message
                         denyBtn:(NSString *)denyBtn
                        grantBtn:(NSString *)grantBtn
                      cmpHandler:(YunPrePmsCmpHandler)cmpHandler {
    [[ClusterPrePermissions sharedPermissions]
                            showLocationPermissionsWithTitle:requestTitle
                                                     message:message
                                             denyButtonTitle:denyBtn
                                            grantButtonTitle:grantBtn
                                           completionHandler:^(BOOL hasPermission,
                                                               ClusterDialogResult userDialogResult,
                                                               ClusterDialogResult systemDialogResult) {
                                               cmpHandler(hasPermission,
                                                          (YunDgRst) userDialogResult,
                                                          (YunDgRst) systemDialogResult);
                                           }];
}

- (void)showLocPmsForAuthType:(YunLocAuthType)authorizationType
                        title:(NSString *)requestTitle
                      message:(NSString *)message
                      denyBtn:(NSString *)denyBtn
                     grantBtn:(NSString *)grantBtn
                   cmpHandler:(YunPrePmsCmpHandler)cmpHandler {
    [[ClusterPrePermissions sharedPermissions]
                            showLocationPermissionsForAuthorizationType:(ClusterLocationAuthorizationType) authorizationType
                                                                  title:requestTitle
                                                                message:message
                                                        denyButtonTitle:denyBtn
                                                       grantButtonTitle:grantBtn
                                                      completionHandler:^(BOOL hasPermission,
                                                                          ClusterDialogResult userDialogResult,
                                                                          ClusterDialogResult systemDialogResult) {
                                                          cmpHandler(hasPermission,
                                                                     (YunDgRst) userDialogResult,
                                                                     (YunDgRst) systemDialogResult);
                                                      }];
}

- (void)showPushNotiPmsWithType:(YunPushNotiType)requestedType
                          title:(NSString *)requestTitle
                        message:(NSString *)message
                        denyBtn:(NSString *)denyBtn
                       grantBtn:(NSString *)grantBtn
                     cmpHandler:(YunPrePmsCmpHandler)cmpHandler {
    [[ClusterPrePermissions sharedPermissions]
                            showPushNotificationPermissionsWithType:(ClusterPushNotificationType) requestedType
                                                              title:requestTitle
                                                            message:message
                                                    denyButtonTitle:denyBtn
                                                   grantButtonTitle:grantBtn
                                                  completionHandler:^(BOOL hasPermission,
                                                                      ClusterDialogResult userDialogResult,
                                                                      ClusterDialogResult systemDialogResult) {
                                                      cmpHandler(hasPermission,
                                                                 (YunDgRst) userDialogResult,
                                                                 (YunDgRst) systemDialogResult);
                                                  }];
}

@end
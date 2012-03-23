//
//  XmlTags.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef CryptoARM_XmlTags_h
#define CryptoARM_XmlTags_h

#define TAG_OIDS @"OIDs"
#define TAG_OID @"OID"
#define TAG_VALUE @"Value"
#define TAG_FRND_NAME @"FriendlyName"

#define TAG_POLICY_PROFILE @"PolicyProfile"
#define TAG_CERTIFICATE_POLICIES @"CertificatePolicies"
#define TAG_POLICY @"Policy"
#define TAG_POLICY_ID @"PolicyID"
#define TAG_EKU @"EKU"
//#define TAG_OID @"OID"
//#define TAG_VALUE @"Value"
//#define TAG_FRIENDLY_NAME @"FriendlyName"
#define TAG_NEW_SIGNATURE @"NewSignature"
#define TAG_USE_POLICY @"UsePolicy"
#define TAG_VERIFY_SIGNATURE @"VerifySignature"
#define TAG_DECHIPHER_PARAMETERS @"DechipherParameters"
#define TAG_ENCHIPHER_PARAMETERS @"EnchipherParameters"

#define TAG_TRUSTEDDESKTOP @"TrustedDesktop"
#define TAG_PROFILESTORE @"ProfileStore"
#define TAG_PROFILES @"Profiles"

#define TAG_PROFILE @"Profile"
#define TAG_PROFILE_ID @"ID"
#define TAG_NAME @"Name"
#define TAG_DESCRIPTION @"Description"
#define TAG_CREATION_DATE @"CreationDate"
#define TAG_ENCRYPT_TO_SENDER @"EncryptToAddress"
#define TAG_ENCRYPT_P7M @"EncryptP7M"
#define TAG_ENCRYPT_PEM @"EncryptPEM"
#define TAG_ENCRYPT_CERTIFICATE @"EncryptCertificate"
#define TAG_ENCRYPT_RECIPIENTS_CERTIFICATE @"EncryptRecipientsCertificates"
#define TAG_DECRYPT_CERTIFICATE @"DecryptCertificate"
#define TAG_VERIFIED_CERTIFICATES @"VerifiedCertificates"

#define TAG_SIGN_COMMENT @"SignComment"
#define TAG_SIGN_CERTIFICATE @"SignCertificate"
#define TAG_SIGN_PIN @"SignPIN"
#define TAG_SIGN_HASH_ALGORITHM @"SignHashAlgorithm"
#define TAG_SIGN_DETACH @"SignDetach"
#define TAG_SIGN_RESOURCE @"SignResource"
#define TAG_SIGN_RESOURCE_IS_FILE @"SignResourceisFile"
#define TAG_SIGN_P7S @"SignP7S"
#define TAG_SIGN_PEM @"SignPEM"
#define TAG_SIGN_ARCHIVE_FILES @"SignArchiveFiles"
#define TAG_SIGN_TYPE @"SignType"

//#define TAG_ @""

enum oids_tag_type {
    TT_NONE = 0,
    TT_OIDS = 1,
    TT_OID = 2,
    TT_VALUE = 3,
    TT_FRND_NAME = 4
};

enum profile_tag_type {
    PTT_NONE = 0,
    PTT_UNKNOWN = 1,
    PTT_TRUSTEDDESKTOP = 2,
    PTT_PROFILESTORE = 3,
    PTT_PROFILES = 4,
    PTT_PROFILE = 5,
    PTT_ID = 6,
    PTT_NAME = 7,
    PTT_DESCRIPTION = 8,
    PTT_CREATION_DATE = 9,
    PTT_ENCRYPT_TO_SENDER = 10,
    PTT_ENCRYPT_P7M = 11,
    PTT_ENCRYPT_PEM = 12,
    PTT_ENCRYPT_CERTIFICATE = 13,
    PTT_ENCRYPT_RECIPIENTS_CERTIFICATE = 14,
    PTT_DECRYPT_CERTIFICATE = 15,
    
    PTT_POLICY_PROFILE = 16,
    PTT_CERTIFICATE_POLICIES = 17,
    PTT_POLICY = 18,
    PTT_POLICY_ID = 19,
    PTT_EKU = 20,
    PTT_OID = 21,
    PTT_VALUE = 22,
    PTT_FRIENDLY_NAME = 23,
    PTT_NEW_SIGNATURE = 24,
    PTT_USE_POLICY = 25,
    PTT_VERIFY_SIGNATURE = 26,
    PTT_DECHIPHER_PARAMETERS = 27,
    PTT_ENCHIPHER_PARAMETERS = 28,
    PTT_VERIFIED_CERTIFICATES = 29,
    
    PTT_SIGN_COMMENT = 30,
    PTT_SIGN_CERTIFICATE = 31,
    PTT_SIGN_PIN = 32,
    PTT_SIGN_HASH_ALGORITHM  = 33,
    PTT_SIGN_DETACH = 34,
    PTT_SIGN_RESOURCE = 35,
    PTT_SIGN_RESOURCE_IS_FILE = 36,
    PTT_SIGN_P7S = 37,
    PTT_SIGN_PEM = 38,
    PTT_SIGN_ARCHIVE_FILES = 39,
    PTT_SIGN_TYPE = 40
    
};

#endif

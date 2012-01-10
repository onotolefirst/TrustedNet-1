#import <Foundation/Foundation.h>

#include <time.h>
#include <Openssl/bio.h>
#include <Openssl/sha.h>
#include <Openssl/x509.h>
#include <Openssl/safestack.h>

@interface Utils : NSObject
{
}

+ (void) initialize; // important

// returns time_t from ASN1_TIME
+ (time_t) getTimeFromASN1:(ASN1_TIME *)aTime;

// returns readable presentation of HEX string(data) in NSString
// isNeedSpacing is needed to space representation of hex characters
+ (NSString*) hexDataToString:(unsigned char*)data length:(int) length isNeedSpacing:(bool)bIsSpacing;

// determines whether str value is in UTF16
+ (NSString*) asn1StringToNSString:(ASN1_STRING *)asn1str;

// global GUID of the CryptoARM
+ (const NSString *) getProductGUID;

// returns formatted string with file size
+ (NSString *)formattedFileSize:(unsigned long long)size;

@end
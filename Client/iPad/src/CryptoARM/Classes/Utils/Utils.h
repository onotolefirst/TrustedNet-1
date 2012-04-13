#import <Foundation/Foundation.h>

#include <time.h>
#include <Openssl/bio.h>
#include <Openssl/sha.h>
#include <Openssl/x509.h>
#include <Openssl/safestack.h>

// Magic numbers for PIN code encryption and decryption
//TODO: define magic numbers in safe way
#define uchEncryptPinMagicNumberXor 0x26d3
#define uchEncryptPinMagicNumberAdd 0x1a3e

struct SST_Entry {
    UInt32 id;
    UInt32 encodingType;
    UInt32 length;
    unsigned char data[];
};

#define SSTEntryIsTerminating(pEntry) (!(pEntry->id || pEntry->encodingType || pEntry->length))

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

// Returns NSArray with CertificateInfo extracted from SST store
+ (NSArray*)certificatesFromSST:(NSData*)sstData;
+ (NSData*)createSSTEntryWithId:(UInt32)entryId coding:(UInt32)entryCoding andValue:(NSData*)entryData;
+ (NSData*)packCertsOnlyIntoSST:(NSArray*)certificatesArray;

+ (NSString*)generateUUID;
+ (NSString*)generateUUIDWithBraces:(BOOL)addBraces;

+ (NSData*)encryptPin:(NSString*)encodingPin;
+ (NSString*)decryptPin:(NSData*)pinData;

+ (NSString*)formatDateForCertificateView:(NSDate*)formattingDate;

+ (UIImage*)constructImageWithIcon:(UIImage*)iconImage andAccessoryIcon:(UIImage*)accessoryIcon;

@end
// common static crypto functions
#import <Foundation/Foundation.h>
#import "AddressBook/AddressBook.h"
#import "../Utils/Utils.h"
#import "Certificate.h"

#include "time.h"
#include <Openssl/bio.h>
#include <Openssl/sha.h>
#include <Openssl/x509.h>
#include <Openssl/safestack.h>
#include <Openssl/blowfish.h>
#include <Openssl/evp.h>
#include <Openssl/rsa.h>
#include <Openssl/err.h>
#include <Openssl/asn1.h>
#include <Openssl/ctiosrsa.h>
#include <Openssl/store.h>

@interface Crypto : NSObject
{
}

+ (void) initialize; // important

// functions for working with certificates
// Extracts subDN value from X509_NAME
+ (NSString *) getDNFromX509_NAME:(X509_NAME *)x509_Name withNid:(int)iNid;
+ (NSMutableArray *) getMultipleDNFromX509_NAME:(X509_NAME *)x509_Name withNid:(int)iNid;

// encrypt or decrypt plain data(pInBuffer); if performEncrypt = true -> encrypt operation; else - decrypt
+ (int) blowfishEncrypt:(const void *)pInBuffer outBuffer:(void *)pOutBuffer size:(unsigned long)dwSize initializationVector:(const unsigned char *)pszPassPhrase performEncrypt:(bool)bEncrypt;

// encrypt file with a certificate public key
// recipient - array of the CertificateInfo objects
// inFilePath - path to file that need to be encrypted
+ (int)encode_message:(NSString *)inFilePath recipientsArray:(STACK_OF(X509) *)encerts outFilePath:(NSString *)strOutFile;
//+ (int)decode_message:(PKCS7 *)encodedMessage privateKey:(EVP_PKEY *)pKey outMessageBIO:(BIO *)outMessage recipient:(X509 *)recipient;
+ (int)decode_message:(PKCS7 *)p7 privateKey:(EVP_PKEY *)pkey recipient:(X509 *)cert outFilePath:(NSString *)filePath;
// extract cert stack from store by URL placed in an address book person record
+ (void)getCertificatesFromURL:(STACK_OF(X509) *)skCerts withURLCertList:(ABMutableMultiValueRef)multiURLCertList andStore:(NSString *)strStoreName;

@end
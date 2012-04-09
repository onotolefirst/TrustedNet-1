//
//  CertificateStore.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CertificateStore.h"

@implementation CertificateStore

@synthesize storeType;
@synthesize store;

- (id)initWithStoreType:(enum CERT_STORE_TYPE)type;
{
    self = [super init];
    if (self)
    {
        storeType = type;
        
        if( (CST_MY == storeType) || (CST_ADDRESS_BOOK == storeType) || (CST_CA == storeType) || (CST_ROOT == storeType) )
        {
            e = ENGINE_by_id(CTIOSRSA_ENGINE_ID);
            store = STORE_new_engine(e);
            
            STORE_ctrl(store, CTIOSRSA_STORE_CTRL_SET_NAME, 0, (void*)[CertificateStore storeNameByTypeId:storeType], NULL);
        }
    }
    return self;
}

- (void)dealloc {
    STORE_free(store);
    ENGINE_free(e);
    
    [super dealloc];
}

- (STACK_OF(X509)*)x509Certificates
{
    if( (CST_MY == storeType) || (CST_ADDRESS_BOOK == storeType) || (CST_CA == storeType) || (CST_ROOT == storeType) )
    {
        STACK_OF(X509) *resultCertificates = sk_X509_new_null();
        
        void *handle = nil;
        OPENSSL_ITEM emptyAttrs[] = {{ STORE_ATTR_END }};
        OPENSSL_ITEM emptyParams[] = {{ STORE_PARAM_KEY_NO_PARAMETERS }};
        
        if ((handle = STORE_list_certificate_start(store, emptyAttrs, emptyParams)))
        {
            for (int i = 0; !STORE_list_certificate_endp(store, handle); i++)
            {
                X509 *cert = STORE_list_certificate_next(store, handle);
                
                if (cert)
                {
                    sk_X509_push(resultCertificates, cert);
                }
                else
                {
                    NSLog(@"Error: Error reading certificate with index %d from store \"%s\"", i, [CertificateStore storeNameByTypeId:storeType]);
                }
            }
        }
        else
        {
            NSLog(@"Error: Unable read certificates from store \"%s\"", [CertificateStore storeNameByTypeId:storeType]);
        }
        
        return resultCertificates;
    }
    else
    {
        //TODO: read other store types
    }
    
    return NULL;
}

- (NSArray*)certificates
{
    if( (CST_MY == storeType) || (CST_ADDRESS_BOOK == storeType) || (CST_CA == storeType) || (CST_ROOT == storeType) )
    {
        //STACK_OF(X509) *resultCertificates = sk_X509_new_null();
        NSMutableArray *resultCertificates = [[NSMutableArray alloc] init];
        
        void *handle = nil;
        OPENSSL_ITEM emptyAttrs[] = {{ STORE_ATTR_END }};
        OPENSSL_ITEM emptyParams[] = {{ STORE_PARAM_KEY_NO_PARAMETERS }};
        
        if ((handle = STORE_list_certificate_start(store, emptyAttrs, emptyParams)))
        {
            for (int i = 0; !STORE_list_certificate_endp(store, handle); i++)
            {
                X509 *cert = STORE_list_certificate_next(store, handle);
                
                if (cert)
                {
                    CertificateInfo *addingCert = [[CertificateInfo alloc] initWithX509:cert doNotCopy:YES];
                    [resultCertificates addObject:addingCert];
                    [addingCert release];
                }
                else
                {
                    NSLog(@"Error: Error reading certificate with index %d from store \"%s\"", i, [CertificateStore storeNameByTypeId:storeType]);
                }
            }
        }
        else
        {
            NSLog(@"Error: Unable read certificates from store \"%s\"", [CertificateStore storeNameByTypeId:storeType]);
        }
        
        return [resultCertificates autorelease];
    }
    else
    {
        //TODO: read other store types
    }
    
    return nil;
}

- (void)addCertificate:(X509*)newCert
{
    OPENSSL_ITEM emptyAttrs[] = {{ STORE_ATTR_END }};
    OPENSSL_ITEM emptyParams[] = {{ STORE_PARAM_KEY_NO_PARAMETERS }};

    int addResult = STORE_store_certificate(store, newCert, emptyAttrs, emptyParams);
    
    if( !addResult )
    {
        NSLog(@"Error: unable to add certificate into store. Error code %d", addResult);
    }
}

//TODO: method not tested
- (void)removeCertificate:(X509*)removingCert
{
    int keyIdLen = -1;
    unsigned char *keyId = X509_keyid_get0(removingCert, &keyIdLen);

    BIGNUM *serialInBignum = ASN1_INTEGER_to_BN(removingCert->cert_info->serialNumber, NULL);
    
    OPENSSL_ITEM attrs[] = {
        {STORE_ATTR_KEYID, keyId, keyIdLen },
        {STORE_ATTR_ISSUERKEYID, removingCert->cert_info->issuerUID->data, removingCert->cert_info->issuerUID->length},
        {STORE_ATTR_SUBJECTKEYID, removingCert->cert_info->subjectUID->data, removingCert->cert_info->subjectUID->length},
        {STORE_ATTR_ISSUER, removingCert->cert_info->issuer, sizeof(removingCert->cert_info->issuer)},
        {STORE_ATTR_ISSUER, removingCert->cert_info->subject, sizeof(removingCert->cert_info->subject)},
        {STORE_ATTR_SERIAL, serialInBignum, sizeof(BIGNUM)},
        {STORE_ATTR_END}
    };
    
    OPENSSL_ITEM params[] = {
        {STORE_PARAM_KEY_NO_PARAMETERS}
    };
    
    int deleteResult = STORE_delete_certificate(store, attrs, params);
    if( !deleteResult )
    {
        NSLog(@"Error while deleting certificate. Error code: %d", deleteResult);
    }
}

+ (const char*)storeNameByTypeId:(enum CERT_STORE_TYPE)typeId
{
    switch (typeId) {
        case CST_MY:
            return "My";
            break;
            
        case CST_ADDRESS_BOOK:
            return "AddressBook";
            break;
            
        case CST_CA:
            return "CA";
            break;
            
        case CST_ROOT:
            return "Root";
            break;
            
        default:
            break;
    }
    
    return "";
}

@end

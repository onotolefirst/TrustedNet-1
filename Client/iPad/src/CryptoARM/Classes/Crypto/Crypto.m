#import "Crypto.h"

void list_md(const EVP_MD *md, const char *from, const char *to, void *out)
{
    if( md )
    {
        NSMutableArray *algs = (NSMutableArray*)out;
        [algs addObject:[NSNumber numberWithInt:EVP_MD_nid(md)]];
    }
    //    else
    //    {
    //        if( !from )
    //        {
    //            from = "<undefined>";
    //        }
    //        
    //        if( !to )
    //        {
    //            to = "<undefined>";
    //        }
    //        NSLog(@"%s => %s", from, to);
    //    }
}

void list_ciph(const EVP_CIPHER *cph, const char *from, const char *to, void *out)
{
    if( cph )
    {
        NSMutableArray *algs = (NSMutableArray*)out;
        [algs addObject:[NSString stringWithCString:EVP_CIPHER_name(cph) encoding:NSUTF8StringEncoding]];
    }
}

@implementation Crypto

-(id) init {
    self = [super init];

    return self;
}

+ (void) initialize
{
}

+ (NSString *) getDNFromX509_NAME:(X509_NAME *)x509_Name withNid:(int)iNid {
    if (nil != x509_Name)
    {
        X509_NAME_ENTRY *entry = NULL;    
        int i = 0;
        
        // fing X509_NAME_ENTRY value by object's nid
        while( nil != ( entry = sk_X509_NAME_ENTRY_value( x509_Name->entries, i) ) )
        {
            if ( iNid == OBJ_obj2nid(entry->object) )
            {
                return [Utils asn1StringToNSString:entry->value];
            }
            
            i++;
        }
    }
    
    return @"";
}

+ (NSMutableArray *) getMultipleDNFromX509_NAME:(X509_NAME *)x509_Name withNid:(int)iNid {
    NSMutableArray *arrayDn = [[[NSMutableArray alloc] init] autorelease];
    
    if (nil != x509_Name)
    {
        X509_NAME_ENTRY *entry = NULL;    
        int i = 0;
        
        // fing X509_NAME_ENTRY value by object's nid
        while( nil != ( entry = sk_X509_NAME_ENTRY_value( x509_Name->entries, i) ) )
        {
            if ( iNid == OBJ_obj2nid(entry->object) )
            {
                [arrayDn addObject:[Utils asn1StringToNSString:entry->value]];
            }
            
            i++;
        }
    }
    
    return arrayDn;
}

+ (int) blowfishEncrypt:(const void *)pInBuffer outBuffer:(void *)pOutBuffer
    size:(unsigned long)dwSize initializationVector:(const unsigned char *)pszPassPhrase
          performEncrypt:(bool)bEncrypt
{
    BF_KEY bfKey;
    unsigned char ivec[8];
    int num = 0;
    int iEnc = BF_DECRYPT;
    
    if (!(pszPassPhrase && pInBuffer && pOutBuffer))
    {
        return 1; // error
    }
    
    memset(ivec, 0, sizeof(ivec));
    
    BF_set_key(&bfKey, strlen((const char *)pszPassPhrase), pszPassPhrase);
    
    if (bEncrypt)
    {
        iEnc = BF_ENCRYPT;
    }
    else
    {
        iEnc = BF_DECRYPT;
    }
    
    BF_cfb64_encrypt(pInBuffer, pOutBuffer, dwSize, &bfKey, ivec, &num, iEnc);
    
    return 0; // success
}

+ (int)encode_message:(NSString *)inFilePath recipientsArray:(STACK_OF(X509) *)encerts outFilePath:(NSString *)strOutFile
{
    OpenSSL_add_all_algorithms();
    OpenSSL_add_all_ciphers();

    BIO *bioInputFile;
    if (!(bioInputFile = BIO_new_file([inFilePath cStringUsingEncoding:NSASCIIStringEncoding], "r")))
    {
        return 1; // file not found
    }

    BIO *bioOutputFile;
    if (!(bioOutputFile = BIO_new_file([strOutFile cStringUsingEncoding:NSASCIIStringEncoding], "w")))
    {
        return 1; // error
    }

    PKCS7 *pkcsEncerts = PKCS7_encrypt(encerts, NULL, EVP_des_ede3_cbc(), PKCS7_STREAM );
    // TODO: PEM_write_bio_PKCS7_stream - for base 64
    i2d_PKCS7_bio_stream(bioOutputFile, pkcsEncerts, bioInputFile, PKCS7_STREAM);

  //  return PKCS7_encrypt(encerts, bioInputFile, EVP_des_ede3_cbc(), PKCS7_DETACHED );

  //  int outformat = FORMAT_ASN1; //DER
   // if (outformat == FORMAT_PEM)
    {
        
        //PEM_write_bio_PKCS7_stream(, p7, bioInputFile, 0);
    }
   // else if (outformat == FORMAT_ASN1)
    //{
      //  i2d_PKCS7_bio_stream(out,p7, in, flags);
   // }
    BIO_free(bioInputFile);
    BIO_free(bioOutputFile);

    return 0;
}

+ (int)decode_message:(PKCS7 *)p7 privateKey:(EVP_PKEY *)pkey recipient:(X509 *)cert outFilePath:(NSString *)filePath
{
    OpenSSL_add_all_algorithms();
    OpenSSL_add_all_ciphers();
        
	BIO *outMessageBIO = BIO_new_file([filePath cStringUsingEncoding:NSASCIIStringEncoding], "w");
    if (!outMessageBIO)
    {                         
        return 2; // error
    }

    if (!PKCS7_decrypt(p7, pkey, cert, outMessageBIO, PKCS7_STREAM))
    {                         
        return 1; // we have not any private key corresponding public key in the recipient cert list
    }
    
    if( !BIO_flush(outMessageBIO) )
    {
        return 3;
    }
    
    BIO_free(outMessageBIO);

    return 0;     // success
}

+ (void)getCertificatesFromURL:(STACK_OF(X509) *)skCerts withURLCertList:(ABMutableMultiValueRef)multiURLCertList andStore:(NSString *)strStoreName
{
    if (multiURLCertList)
    {
        ENGINE *e = ENGINE_by_id(CTIOSRSA_ENGINE_ID);
        STORE *store = STORE_new_engine(e);
        OPENSSL_ITEM emptyParams[] = {{ STORE_PARAM_KEY_NO_PARAMETERS }};
        
        STORE_ctrl(store, CTIOSRSA_STORE_CTRL_SET_NAME, 0, (void *)[strStoreName cStringUsingEncoding:NSASCIIStringEncoding], NULL);
        
        // find all records in the address book that contain cert ref url
        for (CFIndex j = 0; j < ABMultiValueGetCount(multiURLCertList); j++)
        {
            // check the extracted url to find 'cryptoarm' prefix
            CFTypeRef type = ABMultiValueCopyValueAtIndex(multiURLCertList, j);
            NSArray *arrUrlComponents = [[NSString stringWithString:type] componentsSeparatedByString:@"/"];
            CFRelease(type);
            NSString *strCertHashID = @"";
            
            NSRange subStrRange = [[arrUrlComponents objectAtIndex:0] rangeOfString:@"cryptoarm"]; // this is the prefix for the application
            if (subStrRange.location != NSNotFound)
            {
                for (CFIndex iCount = 1; iCount < [arrUrlComponents count]; iCount++)
                {
                    if ([[arrUrlComponents objectAtIndex:iCount] isEqualToString:@"certificate"])
                    {
                        strCertHashID = [arrUrlComponents objectAtIndex:iCount+1];
                        break;
                    }
                }
            }
            
            if ([strCertHashID length])
            {
                // extract cert from store 'AddressBook' by its id
                OPENSSL_ITEM attributeIssuerSerialHash[] = {
                    { STORE_ATTR_ISSUERSERIALHASH, (void *)[strCertHashID cStringUsingEncoding:NSASCIIStringEncoding], [strCertHashID length] },
                    { STORE_ATTR_END } }; // 160 bit string (SHA1)
                
                X509 *certFound = STORE_get_certificate(store, attributeIssuerSerialHash, emptyParams);
                if (certFound)
                {
                    sk_X509_push( skCerts, certFound );
                }
            }
        }
        
        // dealloc
        STORE_free(store);
        ENGINE_free(e);
    }
}

+ (NSString*)convertAsnObjectToString:(ASN1_OBJECT*)object noName:(BOOL)noname
{
    unsigned long requiredLength = OBJ_obj2txt(NULL, 0, object, (noname ? 1 : 0));
    NSMutableData *bufferForString = [[NSMutableData alloc] initWithLength:(requiredLength+2)];
    
    OBJ_obj2txt((char*)bufferForString.bytes, bufferForString.length, object, (noname ? 1 : 0));
    NSString *resultString = [[NSString alloc] initWithCString:(const char *)bufferForString.bytes encoding:NSUTF8StringEncoding];
    
    [bufferForString release];
    return [resultString autorelease];
}

+ (NSArray*)getDigestAlgorithmList
{
    NSMutableArray *tmpList = [[NSMutableArray alloc] init];
    
    OpenSSL_add_all_digests();
    EVP_MD_do_all_sorted( list_md, (void*)tmpList );
    
    return [tmpList autorelease];
}

+ (NSArray*)getCiphersAlgorithmList
{
    NSMutableArray *tmpList = [[NSMutableArray alloc] init];
    
    OpenSSL_add_all_ciphers();
    EVP_CIPHER_do_all_sorted( list_ciph, (void*)tmpList );
    
    return [tmpList autorelease];
}

@end
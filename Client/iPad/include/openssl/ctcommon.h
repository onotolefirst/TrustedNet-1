/*
* Copyright(C) 2011-2011 ООО <<Цифровые технологии>>
*
* Этот файл содержит информацию, являющуюся
* собственностью компании ООО <<Цифровые технологии>>.
*
* Любая часть этого файла не может быть скопирована,
* исправлена, переведена на другие языки,
* локализована или модифицирована любым способом,
* откомпилирована, передана по сети или на
* любую компьютерную систему без предварительного
* заключения соглашения с ООО <<Цифровые технологии>>.
*/

#ifndef CTCOMMON_H__INCLUDED
#define CTCOMMON_H__INCLUDED


#if defined(UNIX)
#include <ctype.h>
#include <string.h>
#include <strings.h>

#define CTCOMMON_API

#ifndef stricmp
#define stricmp strcasecmp
#endif // !stricmp
#ifndef strnicmp
#define strnicmp strncasecmp
#endif // !strnicmp

#ifdef __APPLE__
// Apple specific
#include <CoreFoundation/CFString.h>

#define CFRELEASE(x) \
		if (x) { CFRelease(x); x = NULL; }
#endif // __APPLE__
#else // !UNIX
#include <windows.h>
#include <tchar.h>

#if defined(CTCOMMON_STATIC)
#define CTCOMMON_API
#elif defined(CTCOMMON_EXPORTS)
#define CTCOMMON_API __declspec(dllexport)
#else // !CTCOMMON_EXPORTS
#define CTCOMMON_API __declspec(dllimport)
#endif // !CTCOMMON_EXPORTS

#endif // !UNIX

#include <openssl/pem.h>
#include <openssl/evp.h>
#include <openssl/asn1.h>
#include <openssl/engine.h>
#ifndef OPENSSL_NO_STORE
#include <openssl/store.h>
#endif // !OPENSSL_NO_STORE

#include <sys/stat.h> // for stat()


// === engine specific definitions ===
#define CTCOMMON_ENGINE_CTRL_BASE                           570
#define CTCOMMON_ENGINE_CTRL_GET_X509_LOOKUP_METHOD			(CTCOMMON_ENGINE_CTRL_BASE + 1)

// evp_pkey:
#define CTCOMMON_EVP_PKEY_CTX_get_keyid(ctx, keytype, buff, buflen) \
	EVP_PKEY_CTX_ctrl(ctx, keytype, -1, CTCOMMON_PKEY_CTRL_GET_KEYID, \
		buflen, buff)

#define CTCOMMON_EVP_PKEY_CTX_get_friendly_name(ctx, keytype, buff, buflen) \
	EVP_PKEY_CTX_ctrl(ctx, keytype, -1, CTCOMMON_PKEY_CTRL_GET_FRIENDLY_NAME, \
		buflen, buff)

#define CTCOMMON_EVP_PKEY_CTX_is_decrypted_key(ctx, keytype) \
	EVP_PKEY_CTX_ctrl(ctx, keytype, -1, CTCOMMON_PKEY_CTRL_IS_DECRYPTED_KEY, \
		0, NULL)

#define CTCOMMON_EVP_PKEY_CTX_decrypt_key(ctx, keytype, flags, password) \
	EVP_PKEY_CTX_ctrl(ctx, keytype, -1, CTCOMMON_PKEY_CTRL_DECRYPT_KEY, \
		flags, password)

#define CTCOMMON_EVP_PKEY_CTX_change_password(ctx, keytype, flags, new_password) \
	EVP_PKEY_CTX_ctrl(ctx, keytype, -1, CTCOMMON_PKEY_CTRL_CHANGE_PASSWORD, \
		flags, new_password)

#define CTCOMMON_PKEY_CTRL_BASE                 (EVP_PKEY_ALG_CTRL + 570)
#define CTCOMMON_PKEY_CTRL_GET_KEYID            (CTCOMMON_PKEY_CTRL_BASE + 1)   /* returns keyid (pkey must be linked to ctx) */
#define CTCOMMON_PKEY_CTRL_GET_FRIENDLY_NAME    (CTCOMMON_PKEY_CTRL_BASE + 2)   /* returns friendly name (pkey must be linked to ctx) */
#define CTCOMMON_PKEY_CTRL_IS_DECRYPTED_KEY     (CTCOMMON_PKEY_CTRL_BASE + 3)   /* verify existing decrypted key (pkey must be linked to ctx) */
#define CTCOMMON_PKEY_CTRL_DECRYPT_KEY          (CTCOMMON_PKEY_CTRL_BASE + 4)   /* decipher encrypted key using password_cb (pkey must be linked to ctx) */
#define CTCOMMON_PKEY_CTRL_CHANGE_PASSWORD      (CTCOMMON_PKEY_CTRL_BASE + 5)   /* change password (pkey must be linked to ctx and key must be decrypted) */

#define CTCOMMON_PKEY_CTRL_STR_PARAM_KEYID          "keyid"   /* key id */
#define CTCOMMON_PKEY_CTRL_STR_PARAM_PASSWORD       "password"   /* password */
#define CTCOMMON_PKEY_CTRL_STR_PARAM_STORE          "store"   /* save to store after generation */
#define CTCOMMON_PKEY_CTRL_STR_VALUE_YES            "yes"   /* common value "yes" */
#define CTCOMMON_PKEY_CTRL_STR_VALUE_NO             "no"   /* common value "no" */

// store:
#define CTCOMMON_STORE_CTRL_SET_TYPE		STORE_CTRL_SET_DIRECTORY   /* see follow CTCOMMON_STORE_TYPE_xxx */
#define CTCOMMON_STORE_CTRL_SET_NAME        STORE_CTRL_SET_FILE   /* "My", "AddressBook", "CA", "Root" & any other (case insensitive) */

#define CTCOMMON_STORE_TYPE_CURRENT_USER        (1 << 0)
#define CTCOMMON_STORE_TYPE_LOCAL_MACHINE       (1 << 1)


// === other definitions ===
#ifndef _countof
#define _countof(array) (sizeof(array)/sizeof(array[0]))
#endif

#ifndef MIN
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#endif

#ifndef MAX
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#endif

#ifndef UNUSED
#define UNUSED(x) (void)(x)
#endif

#ifndef BOOL2STR
#define BOOL2STR(x) ((x) ? "TRUE" : "FALSE")
#endif

#if (SIZEOF_VOID_P == 8) || defined(_WIN64)
#define PTR_FORMAT "(ptr) %016p"
#else
#define PTR_FORMAT "(ptr) %08p"
#endif

#define LOG_IMPLEMENT_ME(szComment) \
	LOG_PRINTF((LL_ERROR, "// TODO: implement me - " szComment));

#define EXBOOL    int
#define EXAUTODETECT -1
#define EXEMPTY   0
#define EXFALSE   1
#define EXTRUE    2
#define EXB2BOOL(x) (x - 1)
#define BOOL2EXB(x) (x + 1)
#define IS_EXBOOL_HOLD_VALUE(x) ((EXFALSE == x) || (EXTRUE == x))
#define ASN2EXB(x) (x ? (-1 == x ? EXEMPTY : EXTRUE) : EXFALSE)

#define COMMON_FREE(t, x) \
	if (x) { t ## _free(x); x = NULL; }
#define OPENSSL_FREE(x) COMMON_FREE(OPENSSL, x)
#define BUF_MEM_FREE(x) COMMON_FREE(BUF_MEM, x)
#define BN_FREE(x) COMMON_FREE(BN, x)
#define BIO_FREE(x) COMMON_FREE(BIO, x)
#define RSA_FREE(x) COMMON_FREE(RSA, x)
#define ASN1_INTEGER_FREE(x) COMMON_FREE(ASN1_INTEGER, x)
#define ASN1_OCTET_STRING_FREE(x) COMMON_FREE(ASN1_OCTET_STRING, x)
#define PKCS7_FREE(x) COMMON_FREE(PKCS7, x)
#define PKCS8_PRIV_KEY_INFO_FREE(x) COMMON_FREE(PKCS8_PRIV_KEY_INFO, x)
#define PKCS12_SAFEBAG_FREE(x) COMMON_FREE(PKCS12_SAFEBAG, x)
#define PKCS12_FREE(x) COMMON_FREE(PKCS12, x)
#define EVP_PKEY_FREE(x) COMMON_FREE(EVP_PKEY, x)
#define EVP_PKEY_CTX_FREE(x) COMMON_FREE(EVP_PKEY_CTX, x)
#define X509_FREE(x) COMMON_FREE(X509, x)
#define X509_NAME_FREE(x) COMMON_FREE(X509_NAME, x)
#define X509_PKEY_FREE(x) COMMON_FREE(X509_PKEY, x)
#define X509_SIG_FREE(x) COMMON_FREE(X509_SIG, x)
#define STORE_OBJECT_FREE(x) COMMON_FREE(STORE_OBJECT, x)
#define STORE_FREE(x) COMMON_FREE(STORE, x)
#define STORE_LIST_CTX_FREE(x) COMMON_FREE(STORE_LIST_CTX, x)
#define SK_POP_FREE(t, x) \
	if (x) { sk_ ## t ## _pop_free(x, t ## _free); x = NULL; }

#define SQLITE3_CLOSE(x) \
	if (x) { sqlite3_close(x); x = NULL; }
#define SQLITE3_FINALIZE(x) \
	if (x) { sqlite3_finalize(x); x = NULL; }

#include "ctcommon_stack.h"
#include "ctcommon_debug.h"


// TODO: remove this OPENSSL's struct from project(?)
typedef struct openssl_pw_cb_data
{
	const void *pPassword;
	const char *pszPromptInfo;
} OPENSSL_PW_CB_DATA;

// helper functions
CTCOMMON_API void OPENSSL_STRING_free(OPENSSL_STRING); // for sk_OPENSSL_STRING_pop_free()

CTCOMMON_API void ERR_load_CTCOMMON_strings(void);
CTCOMMON_API void ERR_unload_CTCOMMON_strings(void);
CTCOMMON_API void ERR_CTCOMMON_errnoerror(char *file, int line);
#define CTCOMMONerrnoerr() ERR_CTCOMMON_errnoerror(__FILE__,__LINE__)

CTCOMMON_API char *strndupEx(const char *src, size_t n); // not requires NULL-terminating of src contrary to BUF_strndup()

CTCOMMON_API BUF_MEM * buf_newWithLen(size_t size, int bZeroMemory);
CTCOMMON_API BUF_MEM * buf_newWithData(const void *ptr, size_t size);
CTCOMMON_API BUF_MEM * buf_newWithStr(const char *str, int bAppendNull);
CTCOMMON_API BUF_MEM * buf_newWithPrintf(const char *format, ...);
CTCOMMON_API BUF_MEM * buf_newWithVprintf(const char *format, va_list args);
CTCOMMON_API size_t buf_printf(BUF_MEM *buf, const char *format, ...);
CTCOMMON_API size_t buf_vprintf(BUF_MEM *buf, const char *format, va_list args);
CTCOMMON_API size_t buf_appendData(BUF_MEM *buf, const void *ptr, size_t size);
CTCOMMON_API size_t buf_appendStr(BUF_MEM *buf, const char *str, int bAppendNull);
CTCOMMON_API size_t buf_appendNull(BUF_MEM *buf);
CTCOMMON_API size_t buf_appendPrintf(BUF_MEM *buf, const char *format, ...);
CTCOMMON_API size_t buf_appendVprintf(BUF_MEM *buf, const char *format, va_list args);

CTCOMMON_API int num2bit(unsigned long long int ullValue, int iReturnFirstBitIfSeveral);
CTCOMMON_API int str2bool(const char * pszValue, int iDefaultValue);
CTCOMMON_API char * data2hex(const void *ptr, size_t len, const char *format); // for output to BIO use printDataAsHex()
CTCOMMON_API char * str2hex(const char *str, const char *format); // for output to BIO use printStrAsHex()
CTCOMMON_API char * asn2str(ASN1_STRING *asn1s); // for output to BIO use printAsn1Str()
CTCOMMON_API char * asn2hexStr(ASN1_STRING *asn1s, const char *format); // for output to BIO use printAsn1StrAsHex()
CTCOMMON_API char * asnTime2iso8601(ASN1_TIME *asn1time); // for output to BIO use printAsn1TimeAsIso8601()

CTCOMMON_API int printDataAsHex(BIO *bio, const void *ptr, size_t len, const char *format);
CTCOMMON_API int printStrAsHex(BIO *bio, const char *str, const char *format);
CTCOMMON_API int printAsn1Str(BIO *bio, ASN1_STRING *asn1s);
CTCOMMON_API int printAsn1StrAsHex(BIO *bio, ASN1_STRING *asn1s, const char *format);
CTCOMMON_API int printAsn1TimeAsIso8601(BIO *bio, ASN1_TIME *asn1time);
CTCOMMON_API int printDN(BIO *bio, X509_NAME *name);
CTCOMMON_API int printBigNum(BIO *bio, BIGNUM *number);
CTCOMMON_API int printSubjectDN(BIO *bio, X509 *cert);
CTCOMMON_API int printIssuerDN(BIO *bio, X509 *cert);
CTCOMMON_API int printSerialNumber(BIO *bio, X509 *cert);
CTCOMMON_API int printNotBefore(BIO *bio, X509 *cert);
CTCOMMON_API int printNotAfter(BIO *bio, X509 *cert);
CTCOMMON_API int printEKU(BIO *bio, X509 *cert, const char *szSeparator,
	const char *szPreffix, const char *szSuffix, const char *szTextIfEkuIsAbsent);
CTCOMMON_API int printCertHash(BIO *bio, X509 *cert);
//CTCOMMON_API char * printEmail(BIO *bio, X509_NAME *name, int flags); - use X509_get1_email() instead this
//CTCOMMON_API int printCertEmail(BIO *bio, X509 *cert, int flags, int iFindInOtherPlaces);

CTCOMMON_API int printPubKeyHash(BIO *bio, EVP_PKEY *pkey);

// for getApplicationPath()
#define CT_APT_HOME         (1 << 0)   /* application home */
#define CT_APT_BINARY       (1 << 1)   /* application itself */
#define CT_APT_CACHES       (1 << 2)   /* cache files */
#define CT_APT_DATA         (1 << 3)   /* created by application (not user data) */
#define CT_APT_DESKTOP      (1 << 4)   /* desktop folder */
#define CT_APT_DOCUMENTS    (1 << 5)   /* user documents */
#define CT_APT_DOWNLOADS    (1 << 6)   /* downloaded documents */
#define CT_APT_MOVIES       (1 << 7)   /* user video files */
#define CT_APT_MUSIC        (1 << 8)   /* user audio files */
#define CT_APT_PICTURES     (1 << 9)   /* user pictures */
#define CT_APT_TEMP         (1 << 10)  /* temporary files */

CTCOMMON_API int statMode(const char *name); // it returns st_mode on success and 0 if entry is absent
#if defined(UNIX)
CTCOMMON_API char * getApplicationPath(int iType, const char *szAppendDir); // iType must be one of CT_APT_xxx, function returns pointer to allocated string on success and NULL if fail
CTCOMMON_API int mkdirRecursively(const char *path, mode_t mode);
CTCOMMON_API int removeRecursively(const char *path);
#else // !UNIX
CTCOMMON_API int mkdirRecursively(LPCTSTR path, SECURITY_ATTRIBUTES *psa);
CTCOMMON_API int removeRecursively(LPCTSTR path);
#endif // !UNIX

CTCOMMON_API const char * cmpPrefix(const char * pszStr, const char * pszPrefix, size_t *pValueLen); // returns NULL is prefix is not match else ptr to it's value
CTCOMMON_API const char * getAttrValue(const char * pszStr, const char * pszParam, size_t *pValueLen); // returns ptr to value from string with format "param1:value1,param2:value2;param3:value3"
CTCOMMON_API const char * getAsn1PkeyCtrlStr(int op);
CTCOMMON_API const char * getEvpCtrlStr(int type);
CTCOMMON_API const char * getEvpPkeyCtrlStr(int type);
CTCOMMON_API const char * getEngineCtrlStr(int cmd);

#ifndef OPENSSL_NO_STORE
CTCOMMON_API const char * getStoreObjectTypeStr(STORE_OBJECT_TYPES type);
CTCOMMON_API const char * getStoreAttrTypeStr(STORE_ATTR_TYPES type);

// must return negative on error, 0 if equal and positive - if not equal
typedef int (*fnCmpStoreCert)(X509 *cert, const char *szAttr, const X509_NAME *nameAttr,
	const BIGNUM *numAttr, void *pOtherAttr);

CTCOMMON_API fnCmpStoreCert getCmpStoreCertFnByAttr(STORE_ATTR_TYPES attr);
CTCOMMON_API int CmpStoreCertByKeyId(X509 *cert, const char *szAttr,
	const X509_NAME *nameAttr, const BIGNUM *numAttr, void *pOtherAttr);
CTCOMMON_API int CmpStoreCertByIssuerKeyId(X509 *cert, const char *szAttr,
	const X509_NAME *nameAttr, const BIGNUM *numAttr, void *pOtherAttr);
CTCOMMON_API int CmpStoreCertBySubjectKeyId(X509 *cert, const char *szAttr,
	const X509_NAME *nameAttr, const BIGNUM *numAttr, void *pOtherAttr);
CTCOMMON_API int CmpStoreCertByIssuerSerialHash(X509 *cert, const char *szAttr,
	const X509_NAME *nameAttr, const BIGNUM *numAttr, void *pOtherAttr);
CTCOMMON_API int CmpStoreCertByEmail(X509 *cert, const char *szAttr,
	const X509_NAME *nameAttr, const BIGNUM *numAttr, void *pOtherAttr);
CTCOMMON_API int CmpStoreCertByFilename(X509 *cert, const char *szAttr,
	const X509_NAME *nameAttr, const BIGNUM *numAttr, void *pOtherAttr);
CTCOMMON_API int CmpStoreCertByAlias(X509 *cert, const char *szAttr,
	const X509_NAME *nameAttr, const BIGNUM *numAttr, void *pOtherAttr);

CTCOMMON_API int checkStoreCertByFilters(fnCmpStoreCert fnsCmp[], X509 *cert,
	const char *szAttr, const X509_NAME *nameAttr, const BIGNUM *numAttr, void *pOtherAttr);
CTCOMMON_API int filterStoreCerts(fnCmpStoreCert fnsCmp[], STACK_OF(X509) *skCerts, void (*fnFree)(X509 *),
	const char *szAttr, const X509_NAME *nameAttr, const BIGNUM *numAttr, void *pOtherAttr);


// must return negative on error, 0 if equal and positive - if not equal
typedef int (*fnCmpStoreKey)(EVP_PKEY *pkey, const char *szAttr, const X509_NAME *nameAttr,
	const BIGNUM *numAttr, void *pOtherAttr);


CTCOMMON_API int find_attribute(OPENSSL_ITEM *attributes, STORE_ATTR_TYPES type,
	char ** ppStr, unsigned char ** ppuStr, X509_NAME ** ppName, BIGNUM ** ppNum);
#endif // !OPENSSL_NO_STORE

#ifdef __APPLE__
// Apple specific
CTCOMMON_API char *CFStringCopyToCString(CFStringRef cfstr);
CTCOMMON_API char *lowercase(const char *str);
#endif // __APPLE__

#endif // !CTCOMMON_H__INCLUDED

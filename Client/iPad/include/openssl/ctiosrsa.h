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

#ifndef CTIOSRSA_H__INCLUDED
#define CTIOSRSA_H__INCLUDED

#include <openssl/opensslconf.h>

#if defined(OPENSSL_NO_CTIOSRSA)
#error CTIOSRSA is disabled.
#endif

#ifndef OPENSSL_NO_STORE
#include <openssl/store.h>
#endif
#include <openssl/engine.h>
#include <openssl/ctcommon.h>

// engine:
#define CTIOSRSA_ENGINE_ID	"ctiosrsa"

#define CTIOSRSA_ENGINE_CTRL_GET_X509_LOOKUP_METHOD         CTCOMMON_ENGINE_CTRL_GET_X509_LOOKUP_METHOD

// pkey:
#define CTIOSRSA_EVP_PKEY_CTX_get_keyid(ctx, buff, buflen) \
	CTCOMMON_EVP_PKEY_CTX_get_keyid(ctx, EVP_PKEY_RSA, buff, buflen)

#define CTIOSRSA_EVP_PKEY_CTX_get_friendly_name(ctx, buff, buflen) \
	CTCOMMON_EVP_PKEY_CTX_get_friendly_name(ctx, EVP_PKEY_RSA, buff, buflen)

#define CTIOSRSA_EVP_PKEY_CTX_is_decrypted_key(ctx) \
	CTCOMMON_EVP_PKEY_CTX_is_decrypted_key(ctx, EVP_PKEY_RSA)

#define CTIOSRSA_EVP_PKEY_CTX_decrypt_key(ctx, flags, password) \
	CTCOMMON_EVP_PKEY_CTX_decrypt_key(ctx, EVP_PKEY_RSA, flags, password)

#define CTIOSRSA_EVP_PKEY_CTX_change_password(ctx, flags, new_password) \
	CTCOMMON_EVP_PKEY_CTX_change_password(ctx, EVP_PKEY_RSA, flags, new_password)

#define CTIOSRSA_PKEY_CTRL_STR_PARAM_KEYID          CTCOMMON_PKEY_CTRL_STR_PARAM_KEYID   /* default: "" */
#define CTIOSRSA_PKEY_CTRL_STR_PARAM_PASSWORD       CTCOMMON_PKEY_CTRL_STR_PARAM_PASSWORD /* default: "" */
//#define CTIOSRSA_EVP_PKEY_CTRL_STR_STORE            CTCOMMON_EVP_PKEY_CTRL_STR_STORE /* save to store after generation, default: "no" */

// store:
#define CTIOSRSA_STORE_CTRL_SET_TYPE        CTCOMMON_STORE_CTRL_SET_TYPE /* see follow, default - CTIOSRSA_STORE_TYPE_CURRENT_USER */
#define CTIOSRSA_STORE_CTRL_SET_NAME        CTCOMMON_STORE_CTRL_SET_NAME /* "My", "AddressBook", "CA", "Root" & any other (case insensitive) */

#define CTIOSRSA_STORE_TYPE_CURRENT_USER        CTCOMMON_STORE_TYPE_CURRENT_USER
//#define CTIOSRSA_STORE_TYPE_LOCAL_MACHINE       CTCOMMON_STORE_TYPE_LOCAL_MACHINE

#endif // !CTIOSRSA_H__INCLUDED

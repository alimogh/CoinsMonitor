
; Donations are welcome and will be accepted via below addresses:
; 	BTC:	13e2SdFuyEzqw8dPjRNkyp6rDuTGKaW2rY
; 	LTC:	LTAJo4s5eGGMtao5gVjXSCULXV7iSc9ZnL
; Thank you for the shiny stuff :kiss:

#cs License

	Copyright 2017 Vu Quang Trong <vuquangtrong at gmail dot com>

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.

#ce

#cs

	AutoIt Version: 	3.3.14.2
	Author:				Vu Quang Trong
	Project:			Bitcoin Alert System
	Script Function:	Hash HMAC

#ce

#include-once
#include <Crypt.au3>

; #INDEX# ===================================================================================
; Title ...............: Hash_Hmac
; File Name............: Hash_Hmac.au3
; File Version.........: 1.0.0.1
; Min. AutoIt Version..: v3.3.7.20
; Description .........: AutoIt wrapper for calculating Hash HMAC using SHA512
; Author... ...........: vuquangtrong
; Dll .................: none
; ===========================================================================================

; ===========================================================================================
; Public Functions:
; 	hash_hmac_sha512($data, $key)
; ===========================================================================================

Global Const $CALG_SHA_256 = 0x0000800c
Global Const $CALG_SHA_384 = 0x0000800d
Global Const $CALG_SHA_512 = 0x0000800e

#cs function pseudo code

	function hmac (key, message) {
	if (length(key) > blocksize) {
	key = hash(key) // keys longer than blocksize are shortened
	}
	if (length(key) < blocksize) {
	// keys shorter than blocksize are zero-padded (where ∥ is concatenation)
	key = key ∥ [0x00 * (blocksize - length(key))] // Where * is repetition.
	}

	o_key_pad = [0x5c * blocksize] ⊕ key // Where blocksize is that of the underlying hash function
	i_key_pad = [0x36 * blocksize] ⊕ key // Where ⊕ is exclusive or (XOR)

	return hash(o_key_pad ∥ hash(i_key_pad ∥ message)) // Where ∥ is concatenation
	}

#ce

;==============================================================================
; hash_hmac_sha512($data, $key)
;==============================================================================
Func hash_hmac_sha512($message, $key)

	Local Const $oconst = 0x5C, $iconst = 0x36 ; 92 / 54 DEC
	Local $blocksize = 128 ; Block size for SHA512
	Local $a_opad[$blocksize], $a_ipad[$blocksize]
	Local $opad = Binary(''), $ipad = Binary('')
	$key = Binary($key)
	$message = Binary($message)

	If BinaryLen($key) > $blocksize Then
		$key = _Crypt_HashData($key, $CALG_SHA_512)
	EndIf

	If BinaryLen($key) < $blocksize Then
		For $i = BinaryLen($key) To $blocksize - 1
			$key &= Binary("0x00")
		Next
	EndIf

	For $i = 1 To BinaryLen($key)
		$a_ipad[$i - 1] = Number(BinaryMid($key, $i, 1))
		$a_opad[$i - 1] = Number(BinaryMid($key, $i, 1))
	Next

	For $i = 0 To $blocksize - 1
		$a_opad[$i] = BitXOR($a_opad[$i], $oconst)
		$a_ipad[$i] = BitXOR($a_ipad[$i], $iconst)
	Next

	For $i = 0 To $blocksize - 1
		$ipad &= Binary("0x" & Hex($a_ipad[$i], 2))
		$opad &= Binary("0x" & Hex($a_opad[$i], 2))
	Next

	Local $hash_hmac = StringRegExpReplace(_Crypt_HashData($opad & _Crypt_HashData($ipad & $message, $CALG_SHA_512), $CALG_SHA_512), "0x", "")

	Return $hash_hmac

EndFunc   ;==>hash_hmac_sha512



Func test_hash_hmac_sha512()

	; start engine
	_Crypt_Startup()

	; testing data
	Local $key = "key"
	Local $uri = "uri"
	Local $sign = hash_hmac_sha512($uri, $key)

	; compare with returned value at https://www.freeformatter.com/hmac-generator.html
	If $sign == StringUpper("c7b94d757a3eb4caf45362c8f738d2f8fd6f270d94d572d4e9429e243910c2619b4c0236c1f603079a615e8870cdc8c842a33d7838c5cd60b4f583b43cf39c1a") Then
		MsgBox(0, "Result", "HASH HMAC CONFIRMED!")
	EndIf

	; shutdown
	_Crypt_Shutdown()

EndFunc   ;==>test_hash_hmac_sha512

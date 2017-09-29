
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
	Script Function:	BitTrex API

#ce

#include-once
#include <Crypt.au3>
#include <Date.au3>
#include "Debug.au3"
#include "Json.au3"
#include "Hash_Hmac.au3"
#include "WinHttp.au3"

; #INDEX# ===================================================================================
; Title ...............: BitTrex
; File Name............: BitTrex.au3
; File Version.........: 1.0.0.1
; Min. AutoIt Version..: v3.3.7.20
; Description .........: AutoIt wrapper for BitTrex API
; Author... ...........: vuquangtrong
; Dll .................: none
; ===========================================================================================

; ===========================================================================================
; Public Functions:
; 	time($startDate = "1970/01/01")
; 	bittrex_openConnection()
; 	bittrex_closeConnection()
; 	bittrex_getMarketSummary($sMarket)
; 	bittrex_getMarketHistory($sMarket)
; 	bittrex_getTicker($sMarket)
; 	bittrex_buyLimit($sMarket, $fQuantity, $fRate)
; 	bittrex_sellLimit($sMarket, $fQuantity, $fRate)
; 	bittrex_cancel($sUUID)
; 	bittrex_getOpenOrders($sMarket="")
; 	bittrex_getBalances()
; 	bittrex_getBalance($sCurrency)
; 	bittrex_getDepositAddress($sCurrency)
; ===========================================================================================

; HTTPS Section
Global Const $g_bittrex_sHttpURL = "https://bittrex.com/"
Global $g_bittrex_hHttpOpen = Null
Global $g_bittrex_hHttpConnect = Null
Global $g_bittrex_hHttpRequestSSL = Null
Global $g_bittrex_sHttpReturned = ""
Global $g_bittrex_oJsonObject = Null

; API Key
Global $g_bittrex_API_Key = ""
Global $g_bittrex_API_Secret = ""
Global $g_bittrex_Nounce = ""
Global $g_bittrex_Sign = ""

;==============================================================================
; time($startDate)
; 	return timestamp in miliseconds
;==============================================================================
Func time($startDate = "1970/01/01")

	; generates a timestamp
	Return _DateDiff("s", $startDate & " 00:00:00", _NowCalc()) & @MSEC

EndFunc   ;==>time

;==============================================================================
; bittrex_openConnection()
; 	open a connection to BitTrex exchange, read user keys
;==============================================================================
Func bittrex_openConnection()

	; open connection
	$g_bittrex_hHttpOpen = _WinHttpOpen()
	$g_bittrex_hHttpConnect = _WinHttpConnect($g_bittrex_hHttpOpen, $g_bittrex_sHttpURL, $INTERNET_DEFAULT_HTTPS_PORT)

	Debug("$g_bittrex_hHttpConnect = " & $g_bittrex_hHttpConnect)

	; read account info
	$g_bittrex_API_Key = IniRead(@ScriptDir & "\settings.ini", "Bittrex", "key", "")
	$g_bittrex_API_Secret = IniRead(@ScriptDir & "\settings.ini", "Bittrex", "secret", "")

	Debug("$g_bittrex_API_Key = " & $g_bittrex_API_Key & " $g_bittrex_API_Secret = " & $g_bittrex_API_Secret)

EndFunc   ;==>bittrex_openConnection

;==============================================================================
; bittrex_closeConnection()
; 	close connection to BitTrex exchange
;==============================================================================
Func bittrex_closeConnection()

	If Not $g_bittrex_hHttpConnect Then
		_WinHttpCloseHandle($g_bittrex_hHttpConnect)
		$g_bittrex_hHttpConnect = Null
	EndIf

	If Not $g_bittrex_hHttpOpen Then
		_WinHttpCloseHandle($g_bittrex_hHttpOpen)
		$g_bittrex_hHttpOpen = Null
	EndIf

EndFunc   ;==>bittrex_closeConnection

;==============================================================================
; bittrex_getMarketSummary($sMarket)
; 	return $Price[2] information of market in last 24h with details as below:
; 		$Price[0] - lowest price
; 		$Price[1] - highest price
;==============================================================================
Func bittrex_getMarketSummary($sMarket)
	Local $Success = False
	Local $Price[2] = [0, 0]

	Debug("getMarketSummary " & $sMarket)

	If $g_bittrex_hHttpConnect = Null Then
		Debug("$g_bittrex_hHttpConnect is not openned")
		Return $Price
	EndIf

	$g_bittrex_hHttpRequestSSL = _WinHttpSimpleSendSSLRequest($g_bittrex_hHttpConnect, Default, "api/v1.1/public/getmarketsummary?market=" & $sMarket)

	; Read...
	$g_bittrex_sHttpReturned = _WinHttpSimpleReadData($g_bittrex_hHttpRequestSSL)
	Debug($g_bittrex_sHttpReturned)

	#cs
		{
		"success" : true,
		"message" : "",
		"result" : [{
		"MarketName" : "BTC-LTC",
		"High" : 0.01350000,
		"Low" : 0.01200000,
		"Volume" : 3833.97619253,
		"Last" : 0.01349998,
		"BaseVolume" : 47.03987026,
		"TimeStamp" : "2014-07-09T07:22:16.72",
		"Bid" : 0.01271001,
		"Ask" : 0.01291100,
		"OpenBuyOrders" : 45,
		"OpenSellOrders" : 45,
		"PrevDay" : 0.01229501,
		"Created" : "2014-02-13T00:00:00",
		"DisplayMarketName" : null
		}
		]
		}
	#ce

	; Decode JSON result
	$g_bittrex_oJsonObject = Json_Decode($g_bittrex_sHttpReturned)

	If (Not Json_IsObject($g_bittrex_oJsonObject)) Then
		Debug("NOT Json Object $g_bittrex_oJsonObject")
		Return $Price
	EndIf

	; Check success
	$Success = Json_Get($g_bittrex_oJsonObject, "[success]")
	If $Success Then
		; Get info
		$Price[0] = Number(Json_Get($g_bittrex_oJsonObject, "[result][0][Low]"))
		$Price[1] = Number(Json_Get($g_bittrex_oJsonObject, "[result][0][High]"))
	Else
		Debug("Request failed!!!")
	EndIf

	; Clear JSON object
	Json_ObjClear($g_bittrex_oJsonObject)

	Debug("$PriceMax = " & $Price[1] & " $PriceMin = " & $Price[0])

	Return $Price
EndFunc   ;==>bittrex_getMarketSummary

;==============================================================================
; bittrex_getMarketHistory($sMarket)
;	return $PriceHistory as an array of transactions
; 	$PriceHistory[0][0] - the number of transactions
; 		$PriceHistory[i][0] - TimeStamp
; 		$PriceHistory[i][1] - Quantity
; 		$PriceHistory[i][2] - Price
; 		$PriceHistory[i][3] - OrderType
;==============================================================================
Func bittrex_getMarketHistory($sMarket)
	Local $Success = False
	Local $ItemCount = 0
	Local $PriceHistory[1][4] = [[0, 0, 0, 0]] ; TimeStamp, Quantity, Price, OrderType

	Debug("getMarketHistory " & $sMarket)

	If $g_bittrex_hHttpConnect = Null Then
		Debug("$g_bittrex_hHttpConnect is not openned")
		Return $PriceHistory
	EndIf

	$g_bittrex_hHttpRequestSSL = _WinHttpSimpleSendSSLRequest($g_bittrex_hHttpConnect, Default, "api/v1.1/public/getmarkethistory?market=" & $sMarket)

	; Read...
	$g_bittrex_sHttpReturned = _WinHttpSimpleReadData($g_bittrex_hHttpRequestSSL)
	Debug($g_bittrex_sHttpReturned)

	#cs
		{
		"success" : true,
		"message" : "",
		"result" : [{
		"Id" : 319435,
		"TimeStamp" : "2014-07-09T03:21:20.08",
		"Quantity" : 0.30802438,
		"Price" : 0.01263400,
		"Total" : 0.00389158,
		"FillType" : "FILL",
		"OrderType" : "BUY"
		}, {
		...
		}
		]
		}
	#ce

	; Decode JSON result
	$g_bittrex_oJsonObject = Json_Decode($g_bittrex_sHttpReturned)

	If (Not Json_IsObject($g_bittrex_oJsonObject)) Then
		Debug("NOT Json Object $g_bittrex_oJsonObject")
		Return $PriceHistory
	EndIf

	; Check success
	$Success = Json_Get($g_bittrex_oJsonObject, "[success]")
	If $Success Then
		; Get info
		Local $oJson_Result = Json_Get($g_bittrex_oJsonObject, "[result]")

		$ItemCount = UBound($oJson_Result)
		Debug("$ItemCount = " & $ItemCount)

		ReDim $PriceHistory[$ItemCount + 1][4]

		$PriceHistory[0][0] = $ItemCount

		For $i = 1 To $ItemCount
			$PriceHistory[$i][0] = Json_Get($oJson_Result[$i - 1], "[TimeStamp]")
			$PriceHistory[$i][1] = Number(Json_Get($oJson_Result[$i - 1], "[Quantity]"))
			$PriceHistory[$i][2] = Number(Json_Get($oJson_Result[$i - 1], "[Price]"))
			$PriceHistory[$i][3] = Json_Get($oJson_Result[$i - 1], "[OrderType]")
		Next
	Else
		Debug("Request failed!!!")
	EndIf

	; Clear JSON object
	Json_ObjClear($g_bittrex_oJsonObject)

	Return $PriceHistory
EndFunc   ;==>bittrex_getMarketHistory

;==============================================================================
; getTicker($sMarket)
; 	return the lastest price of a market
;==============================================================================
Func bittrex_getTicker($sMarket)
	Local $Success = False
	Local $PriceLast = 0

	If $g_bittrex_hHttpConnect = Null Then
		Debug("$g_bittrex_hHttpConnect is not openned")
		Return $PriceLast
	EndIf

	; Make a SimpleSSL request
	$g_bittrex_hHttpRequestSSL = _WinHttpSimpleSendSSLRequest($g_bittrex_hHttpConnect, Default, "api/v1.1/public/getticker?market=" & $sMarket)

	; Read
	$g_bittrex_sHttpReturned = _WinHttpSimpleReadData($g_bittrex_hHttpRequestSSL)
	Debug($g_bittrex_sHttpReturned)

	#cs
		{
		"success" : true,
		"message" : "",
		"result" : {
		"Bid" : 2.05670368,
		"Ask" : 3.35579531,
		"Last" : 3.35579531
		}
		}
	#ce

	; Decode JSON result
	$g_bittrex_oJsonObject = Json_Decode($g_bittrex_sHttpReturned)

	If (Not Json_IsObject($g_bittrex_oJsonObject)) Then
		Debug("NOT Json Object $g_bittrex_oJsonObject")
		Return $PriceLast
	EndIf

	; Check success
	$Success = Json_Get($g_bittrex_oJsonObject, "[success]")
	If $Success Then
		; Get info
		$PriceLast = Number(Json_Get($g_bittrex_oJsonObject, "[result][Last]"))
		Debug("$sMarket = " & $sMarket & " $PriceLast = " & $PriceLast)
	Else
		Debug("Request failed!!!")
	EndIf

	; Clear JSON object
	Json_ObjClear($g_bittrex_oJsonObject)

	Return $PriceLast

EndFunc   ;==>bittrex_getTicker


#cs Sign a request

	$market='xxx';
	$apikey='xxx';
	$apisecret='xxx';
	$nonce=time();
	$uri='https://bittrex.com/api/v1.1/market/getopenorders?apikey='.$apikey.'&nonce='.$nonce.<pram=value>;
	$sign=hash_hmac('sha512',$uri,$apisecret);
	$ch = curl_init($uri);
	curl_setopt($ch, CURLOPT_HTTPHEADER, array('apisign:'.$sign));
	$execResult = curl_exec($ch);
	$obj = json_decode($execResult);

#ce

;==============================================================================
; bittrex_buyLimit($sMarket, $fQuantity, $fRate)
; 	return UUID of requested order, null if the order is failed
;==============================================================================
Func bittrex_buyLimit($sMarket, $fQuantity, $fRate)
	Local $Success = False
	Local $UUID = ""

	If $g_bittrex_API_Key == "" Or $g_bittrex_API_Secret == "" Then
		Debug("API Key and Secret pharse are not set!!!")
		Return $UUID
	EndIf

	If $g_bittrex_hHttpConnect = Null Then
		Debug("$g_bittrex_hHttpConnect is not openned")
		Return $UUID
	EndIf

	Local $nonce = time()
	Local $uri = "api/v1.1/market/buylimit?apikey=" & $g_bittrex_API_Key & "&nonce=" & $nonce & "&market=" & $sMarket & "&quantity=" & $fQuantity & "&rate=" & $fRate
	Local $sign = hash_hmac_sha512($g_bittrex_sHttpURL & $uri, $g_bittrex_API_Secret) ; the hash data needs full url

	Debug("buylimit:" & @CRLF & "$nonce = " & $nonce & @CRLF & "$uri = " & $uri & @CRLF & "$sign = " & $sign)

	; Make a SimpleSSL request
	; _WinHttpSimpleSendSSLRequest($hConnect [, $sType [, $sPath [, $sReferrer = Default [, $sDta = Default [, $sHeader = Default ]]]]])
	$g_bittrex_hHttpRequestSSL = _WinHttpSimpleSendSSLRequest($g_bittrex_hHttpConnect, Default, $uri, Default, Default, "apisign:" & $sign)

	; Read
	$g_bittrex_sHttpReturned = _WinHttpSimpleReadData($g_bittrex_hHttpRequestSSL)
	Debug($g_bittrex_sHttpReturned)

	#cs
		{
		"success" : true,
		"message" : "",
		"result" : {
		"uuid" : "e606d53c-8d70-11e3-94b5-425861b86ab6"
		}
		}
	#ce

	; Decode JSON result
	$g_bittrex_oJsonObject = Json_Decode($g_bittrex_sHttpReturned)

	If (Not Json_IsObject($g_bittrex_oJsonObject)) Then
		Debug("NOT Json Object $g_bittrex_oJsonObject")
		Return $UUID
	EndIf

	; Check success
	$Success = Json_Get($g_bittrex_oJsonObject, "[success]")
	If $Success Then
		; Get info
		$UUID = Json_Get($g_bittrex_oJsonObject, "[result][uuid]")
		Debug("$UUID = " & $UUID)
	Else
		Debug("Request failed!!!")
	EndIf

	; Clear JSON object
	Json_ObjClear($g_bittrex_oJsonObject)

	Return $UUID
EndFunc   ;==>bittrex_buyLimit

;==============================================================================
; bittrex_sellLimit($sMarket, $fQuantity, $fRate)
; 	return UUID of requested order, null if the order is failed
;==============================================================================
Func bittrex_sellLimit($sMarket, $fQuantity, $fRate)
	Local $Success = False
	Local $UUID = ""

	If $g_bittrex_API_Key == "" Or $g_bittrex_API_Secret == "" Then
		Debug("API Key and Secret pharse are not set!!!")
		Return $UUID
	EndIf

	If $g_bittrex_hHttpConnect = Null Then
		Debug("$g_bittrex_hHttpConnect is not openned")
		Return $UUID
	EndIf

	Local $nonce = time()
	Local $uri = "api/v1.1/market/selllimit?apikey=" & $g_bittrex_API_Key & "&nonce=" & $nonce & "&market=" & $sMarket & "&quantity=" & $fQuantity & "&rate=" & $fRate
	Local $sign = hash_hmac_sha512($g_bittrex_sHttpURL & $uri, $g_bittrex_API_Secret) ; the hash data needs full url

	Debug("selllimit:" & @CRLF & "$nonce = " & $nonce & @CRLF & "$uri = " & $uri & @CRLF & "$sign = " & $sign)

	; Make a SimpleSSL request
	; _WinHttpSimpleSendSSLRequest($hConnect [, $sType [, $sPath [, $sReferrer = Default [, $sDta = Default [, $sHeader = Default ]]]]])
	$g_bittrex_hHttpRequestSSL = _WinHttpSimpleSendSSLRequest($g_bittrex_hHttpConnect, Default, $uri, Default, Default, "apisign:" & $sign)

	; Read
	$g_bittrex_sHttpReturned = _WinHttpSimpleReadData($g_bittrex_hHttpRequestSSL)
	Debug($g_bittrex_sHttpReturned)

	#cs
		{
		"success" : true,
		"message" : "",
		"result" : {
		"uuid" : "e606d53c-8d70-11e3-94b5-425861b86ab6"
		}
		}
	#ce

	; Decode JSON result
	$g_bittrex_oJsonObject = Json_Decode($g_bittrex_sHttpReturned)

	If (Not Json_IsObject($g_bittrex_oJsonObject)) Then
		Debug("NOT Json Object $g_bittrex_oJsonObject")
		Return $UUID
	EndIf

	; Check success
	$Success = Json_Get($g_bittrex_oJsonObject, "[success]")
	If $Success Then
		; Get info
		$UUID = Json_Get($g_bittrex_oJsonObject, "[result][uuid]")
		Debug("$UUID = " & $UUID)
	Else
		Debug("Request failed!!!")
	EndIf

	; Clear JSON object
	Json_ObjClear($g_bittrex_oJsonObject)

	Return $UUID
EndFunc   ;==>bittrex_sellLimit

;==============================================================================
; bittrex_cancel($sUUID)
; 	cancel an order having $sUUID
; 	return True or False
;==============================================================================
Func bittrex_cancel($sUUID)
	Local $Success = False
	Local $Canceled = False

	If $g_bittrex_API_Key == "" Or $g_bittrex_API_Secret == "" Then
		Debug("API Key and Secret pharse are not set!!!")
		Return $Canceled
	EndIf

	If $g_bittrex_hHttpConnect = Null Then
		Debug("$g_bittrex_hHttpConnect is not openned")
		Return $Canceled
	EndIf

	Local $nonce = time()
	Local $uri = "api/v1.1/market/cancel?apikey=" & $g_bittrex_API_Key & "&nonce=" & $nonce & "&uuid=" & $sUUID
	Local $sign = hash_hmac_sha512($g_bittrex_sHttpURL & $uri, $g_bittrex_API_Secret) ; the hash data needs full url

	Debug("cancel:" & @CRLF & "$nonce = " & $nonce & @CRLF & "$uri = " & $uri & @CRLF & "$sign = " & $sign)

	; Make a SimpleSSL request
	; _WinHttpSimpleSendSSLRequest($hConnect [, $sType [, $sPath [, $sReferrer = Default [, $sDta = Default [, $sHeader = Default ]]]]])
	$g_bittrex_hHttpRequestSSL = _WinHttpSimpleSendSSLRequest($g_bittrex_hHttpConnect, Default, $uri, Default, Default, "apisign:" & $sign)

	; Read
	$g_bittrex_sHttpReturned = _WinHttpSimpleReadData($g_bittrex_hHttpRequestSSL)
	Debug($g_bittrex_sHttpReturned)

	#cs
		{
		"success" : true,
		"message" : "",
		"result" : null
		}
	#ce

	; Decode JSON result
	$g_bittrex_oJsonObject = Json_Decode($g_bittrex_sHttpReturned)

	If (Not Json_IsObject($g_bittrex_oJsonObject)) Then
		Debug("NOT Json Object $g_bittrex_oJsonObject")
		Return $Canceled
	EndIf

	; Check success
	$Success = Json_Get($g_bittrex_oJsonObject, "[success]")
	If $Success Then
		$Canceled = True
	Else
		Debug("Request failed!!!")
	EndIf

	; Clear JSON object
	Json_ObjClear($g_bittrex_oJsonObject)

	Return $Canceled
EndFunc   ;==>bittrex_cancel

;==============================================================================
; bittrex_getOpenOrders($sMarket)
; 	return an array $OpenOrders of open order
; 	$OpenOrders[0][0] - number of orders
; 		$OpenOrders[i][0] -	Exchange
; 		$OpenOrders[i][1] -	OrderUuid
; 		$OpenOrders[i][2] -	OrderType
; 		$OpenOrders[i][3] -	Quantity
; 		$OpenOrders[i][4] -	Limit
;==============================================================================
Func bittrex_getOpenOrders($sMarket = "")
	Local $Success = False
	Local $ItemCount = 0
	Local $OpenOrders[1][5] = [[0, 0, 0, 0, 0]] ; Exchange, OrderUuid, OrderType, Quantity, Limit

	If $g_bittrex_API_Key == "" Or $g_bittrex_API_Secret == "" Then
		Debug("API Key and Secret pharse are not set!!!")
		Return $OpenOrders
	EndIf

	If $g_bittrex_hHttpConnect = Null Then
		Debug("$g_bittrex_hHttpConnect is not openned")
		Return $OpenOrders
	EndIf

	Local $nonce = time()
	Local $uri = "api/v1.1/market/getopenorders?apikey=" & $g_bittrex_API_Key & "&nonce=" & $nonce & "&market=" & $sMarket
	Local $sign = hash_hmac_sha512($g_bittrex_sHttpURL & $uri, $g_bittrex_API_Secret) ; the hash data needs full url

	Debug("getOpenOrders:" & @CRLF & "$nonce = " & $nonce & @CRLF & "$uri = " & $uri & @CRLF & "$sign = " & $sign)

	; Make a SimpleSSL request
	; _WinHttpSimpleSendSSLRequest($hConnect [, $sType [, $sPath [, $sReferrer = Default [, $sDta = Default [, $sHeader = Default ]]]]])
	$g_bittrex_hHttpRequestSSL = _WinHttpSimpleSendSSLRequest($g_bittrex_hHttpConnect, Default, $uri, Default, Default, "apisign:" & $sign)

	; Read
	$g_bittrex_sHttpReturned = _WinHttpSimpleReadData($g_bittrex_hHttpRequestSSL)
	Debug($g_bittrex_sHttpReturned)

	#cs
		{
		"success": true,
		"message": "",
		"result": [{
		"Uuid": null,
		"OrderUuid": "xxx",
		"Exchange": "USDT-LTC",
		"OrderType": "LIMIT_SELL",
		"Quantity": xxx,
		"QuantityRemaining": xxx,
		"Limit": 57.50000000,
		"CommissionPaid": 0.00000000,
		"Price": 0.00000000,
		"PricePerUnit": null,
		"Opened": "2017-09-19T15:04:44.37",
		"Closed": null,
		"CancelInitiated": false,
		"ImmediateOrCancel": false,
		"IsConditional": false,
		"Condition": "NONE",
		"ConditionTarget": null
		}, {
		"Uuid": null,
		"OrderUuid": "xxx",
		"Exchange": "USDT-LTC",
		"OrderType": "LIMIT_SELL",
		"Quantity": xxx,
		"QuantityRemaining": xxx,
		"Limit": 57.00000000,
		"CommissionPaid": 0.00000000,
		"Price": 0.00000000,
		"PricePerUnit": null,
		"Opened": "2017-09-19T15:03:24.707",
		"Closed": null,
		"CancelInitiated": false,
		"ImmediateOrCancel": false,
		"IsConditional": false,
		"Condition": "NONE",
		"ConditionTarget": null
		}]
		}
	#ce

	; Decode JSON result
	$g_bittrex_oJsonObject = Json_Decode($g_bittrex_sHttpReturned)
	If (Not Json_IsObject($g_bittrex_oJsonObject)) Then
		Debug("NOT Json Object $g_bittrex_oJsonObject")
		Return $OpenOrders
	EndIf

	; Check success
	$Success = Json_Get($g_bittrex_oJsonObject, "[success]")
	If $Success Then
		; Get info
		Local $oJson_Result = Json_Get($g_bittrex_oJsonObject, "[result]")

		$ItemCount = UBound($oJson_Result)
		Debug("$ItemCount = " & $ItemCount)

		ReDim $OpenOrders[$ItemCount + 1][5]

		$OpenOrders[0][0] = $ItemCount

		For $i = 1 To $ItemCount
			$OpenOrders[$i][0] = Json_Get($oJson_Result[$i - 1], "[Exchange]")
			$OpenOrders[$i][1] = Json_Get($oJson_Result[$i - 1], "[OrderUuid]")
			$OpenOrders[$i][2] = Json_Get($oJson_Result[$i - 1], "[OrderType]")
			$OpenOrders[$i][3] = Number(Json_Get($oJson_Result[$i - 1], "[Quantity]"))
			$OpenOrders[$i][4] = Number(Json_Get($oJson_Result[$i - 1], "[Limit]"))
		Next
	Else
		Debug("Request failed!!!")
	EndIf

	; Clear JSON object
	Json_ObjClear($g_bittrex_oJsonObject)

	Return $OpenOrders
EndFunc   ;==>bittrex_getOpenOrders

;==============================================================================
; bittrex_getbalances()
; 	return an array $Balances of all your currencies
; 	$Balances[0][0] - the number of currencies
; 		$Balances[i][0] - Currency
; 		$Balances[i][1] - Balance
; 		$Balances[i][2] - Available
; 		$Balances[i][3] - Pending
; 		$Balances[i][4] - CryptoAddress
;==============================================================================
Func bittrex_getBalances()
	Local $Success = False
	Local $ItemCount = 0
	Local $Balances[1][5] = [[0, 0, 0, 0, 0]] ; Currency, Balance, Available, Pending, CryptoAddress

	If $g_bittrex_API_Key == "" Or $g_bittrex_API_Secret == "" Then
		Debug("API Key and Secret pharse are not set!!!")
		Return $Balances
	EndIf

	If $g_bittrex_hHttpConnect = Null Then
		Debug("$g_bittrex_hHttpConnect is not openned")
		Return $Balances
	EndIf

	Local $nonce = time()
	Local $uri = "api/v1.1/market/getbalances?apikey=" & $g_bittrex_API_Key & "&nonce=" & $nonce
	Local $sign = hash_hmac_sha512($g_bittrex_sHttpURL & $uri, $g_bittrex_API_Secret) ; the hash data needs full url

	Debug("getbalances:" & @CRLF & "$nonce = " & $nonce & @CRLF & "$uri = " & $uri & @CRLF & "$sign = " & $sign)

	; Make a SimpleSSL request
	; _WinHttpSimpleSendSSLRequest($hConnect [, $sType [, $sPath [, $sReferrer = Default [, $sDta = Default [, $sHeader = Default ]]]]])
	$g_bittrex_hHttpRequestSSL = _WinHttpSimpleSendSSLRequest($g_bittrex_hHttpConnect, Default, $uri, Default, Default, "apisign:" & $sign)

	; Read
	$g_bittrex_sHttpReturned = _WinHttpSimpleReadData($g_bittrex_hHttpRequestSSL)
	Debug($g_bittrex_sHttpReturned)

	#cs
		{
		"success" : true,
		"message" : "",
		"result" : [{
		"Currency" : "DOGE",
		"Balance" : 0.00000000,
		"Available" : 0.00000000,
		"Pending" : 0.00000000,
		"CryptoAddress" : "DLxcEt3AatMyr2NTatzjsfHNoB9NT62HiF",
		"Requested" : false,
		"Uuid" : null

		}, {
		"Currency" : "BTC",
		"Balance" : 14.21549076,
		"Available" : 14.21549076,
		"Pending" : 0.00000000,
		"CryptoAddress" : "1Mrcdr6715hjda34pdXuLqXcju6qgwHA31",
		"Requested" : false,
		"Uuid" : null
		}
		]
	#ce

	; Decode JSON result
	$g_bittrex_oJsonObject = Json_Decode($g_bittrex_sHttpReturned)
	If (Not Json_IsObject($g_bittrex_oJsonObject)) Then
		Debug("NOT Json Object $g_bittrex_oJsonObject")
		Return $Balances
	EndIf

	; Check success
	$Success = Json_Get($g_bittrex_oJsonObject, "[success]")
	If $Success Then
		; Get info
		Local $oJson_Result = Json_Get($g_bittrex_oJsonObject, "[result]")

		$ItemCount = UBound($oJson_Result)
		Debug("$ItemCount = " & $ItemCount)

		ReDim $Balances[$ItemCount + 1][5]

		$Balances[0][0] = $ItemCount

		For $i = 1 To $ItemCount
			$Balances[$i][0] = Json_Get($oJson_Result[$i - 1], "[Currency]")
			$Balances[$i][1] = Number(Json_Get($oJson_Result[$i - 1], "[Balance]"))
			$Balances[$i][2] = Number(Json_Get($oJson_Result[$i - 1], "[Available]"))
			$Balances[$i][3] = Number(Json_Get($oJson_Result[$i - 1], "[Pending]"))
			$Balances[$i][4] = Json_Get($oJson_Result[$i - 1], "[CryptoAddress]")
		Next
	Else
		Debug("Request failed!!!")
	EndIf

	; Clear JSON object
	Json_ObjClear($g_bittrex_oJsonObject)

	Return $Balances
EndFunc   ;==>bittrex_getBalances

;==============================================================================
; bittrex_getbalance($sCurrency)
; 	return an array $Balance of all your currency
; 	$Balances[0] - Balance
; 	$Balances[1] - Available
; 	$Balances[2] - Pending
; 	$Balances[3] - CryptoAddress
;==============================================================================
Func bittrex_getBalance($sCurrency)
	Local $Success = False
	Local $Balance[4] = [0, 0, 0, 0] ; Balance, Available, Pending, CryptoAddress

	If $g_bittrex_API_Key == "" Or $g_bittrex_API_Secret == "" Then
		Debug("API Key and Secret pharse are not set!!!")
		Return $Balance
	EndIf

	If $g_bittrex_hHttpConnect = Null Then
		Debug("$g_bittrex_hHttpConnect is not openned")
		Return $Balance
	EndIf

	Local $nonce = time()
	Local $uri = "api/v1.1/market/getbalance?apikey=" & $g_bittrex_API_Key & "&nonce=" & $nonce & "&currency=" & $sCurrency
	Local $sign = hash_hmac_sha512($g_bittrex_sHttpURL & $uri, $g_bittrex_API_Secret) ; the hash data needs full url

	Debug("getbalance:" & @CRLF & "$nonce = " & $nonce & @CRLF & "$uri = " & $uri & @CRLF & "$sign = " & $sign)

	; Make a SimpleSSL request
	; _WinHttpSimpleSendSSLRequest($hConnect [, $sType [, $sPath [, $sReferrer = Default [, $sDta = Default [, $sHeader = Default ]]]]])
	$g_bittrex_hHttpRequestSSL = _WinHttpSimpleSendSSLRequest($g_bittrex_hHttpConnect, Default, $uri, Default, Default, "apisign:" & $sign)

	; Read
	$g_bittrex_sHttpReturned = _WinHttpSimpleReadData($g_bittrex_hHttpRequestSSL)
	Debug($g_bittrex_sHttpReturned)

	#cs
		{
		"success" : true,
		"message" : "",
		"result" : {
		"Currency" : "BTC",
		"Balance" : 4.21549076,
		"Available" : 4.21549076,
		"Pending" : 0.00000000,
		"CryptoAddress" : "1MacMr6715hjds342dXuLqXcju6fgwHA31",
		"Requested" : false,
		"Uuid" : null
		}
		}
	#ce

	; Decode JSON result
	$g_bittrex_oJsonObject = Json_Decode($g_bittrex_sHttpReturned)
	If (Not Json_IsObject($g_bittrex_oJsonObject)) Then
		Debug("NOT Json Object $g_bittrex_oJsonObject")
		Return $Balance
	EndIf

	; Check success
	$Success = Json_Get($g_bittrex_oJsonObject, "[success]")
	If $Success Then
		; Get info
		$Balance[0] = Number(Json_Get($g_bittrex_oJsonObject, "[success][Balance]"))
		$Balance[1] = Number(Json_Get($g_bittrex_oJsonObject, "[success][Available]"))
		$Balance[2] = Number(Json_Get($g_bittrex_oJsonObject, "[success][Pending]"))
		$Balance[3] = Json_Get($g_bittrex_oJsonObject, "[success][CryptoAddress]")
	Else
		Debug("Request failed!!!")
	EndIf

	; Clear JSON object
	Json_ObjClear($g_bittrex_oJsonObject)

	Return $Balance
EndFunc   ;==>bittrex_getBalance

;==============================================================================
; bittrex_getDepositAddress($sCurrency)
; 	return address
;==============================================================================
Func bittrex_getDepositAddress($sCurrency)
	Local $Success = False
	Local $Address = ""

	If $g_bittrex_API_Key == "" Or $g_bittrex_API_Secret == "" Then
		Debug("API Key and Secret pharse are not set!!!")
		Return $Address
	EndIf

	If $g_bittrex_hHttpConnect = Null Then
		Debug("$g_bittrex_hHttpConnect is not openned")
		Return $Address
	EndIf

	Local $nonce = time()
	Local $uri = "api/v1.1/market/buylimit?apikey=" & $g_bittrex_API_Key & "&nonce=" & $nonce & "&currency=" & $sCurrency
	Local $sign = hash_hmac_sha512($g_bittrex_sHttpURL & $uri, $g_bittrex_API_Secret) ; the hash data needs full url

	Debug("getDepositAddress:" & @CRLF & "$nonce = " & $nonce & @CRLF & "$uri = " & $uri & @CRLF & "$sign = " & $sign)

	; Make a SimpleSSL request
	; _WinHttpSimpleSendSSLRequest($hConnect [, $sType [, $sPath [, $sReferrer = Default [, $sDta = Default [, $sHeader = Default ]]]]])
	$g_bittrex_hHttpRequestSSL = _WinHttpSimpleSendSSLRequest($g_bittrex_hHttpConnect, Default, $uri, Default, Default, "apisign:" & $sign)

	; Read
	$g_bittrex_sHttpReturned = _WinHttpSimpleReadData($g_bittrex_hHttpRequestSSL)
	Debug($g_bittrex_sHttpReturned)

	#cs
		{
		"success" : true,
		"message" : "",
		"result" : {
		"Currency" : "VTC",
		"Address" : "Vy5SKeKGXUHKS2WVpJ76HYuKAu3URastUo"
		}
		}
	#ce

	; Decode JSON result
	$g_bittrex_oJsonObject = Json_Decode($g_bittrex_sHttpReturned)

	If (Not Json_IsObject($g_bittrex_oJsonObject)) Then
		Debug("NOT Json Object $g_bittrex_oJsonObject")
		Return $Address
	EndIf

	; Check success
	$Success = Json_Get($g_bittrex_oJsonObject, "[success]")
	If $Success Then
		; Get info
		$Address = Json_Get($g_bittrex_oJsonObject, "[result][Address]")
		Debug("$Address = " & $Address)
	Else
		Debug("Request failed!!!")
	EndIf

	; Clear JSON object
	Json_ObjClear($g_bittrex_oJsonObject)

	Return $Address
EndFunc   ;==>bittrex_getDepositAddress

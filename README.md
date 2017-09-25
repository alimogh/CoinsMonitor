CoinsMonitor
===========
__Monitor the price of your coins, popup alerts, manage your portfolio in realtime__

(September 24th, 2017)

_Currently only support [BITTREX](https://bittrex.com/)_

## Author
* **vuquangtrong** at gmail dot com
Donations are welcome and will be accepted via below addresses:
	BTC:	13e2SdFuyEzqw8dPjRNkyp6rDuTGKaW2rY
	LTC:	LTAJo4s5eGGMtao5gVjXSCULXV7iSc9ZnL
Thank you for the shiny stuff :kiss:

## Components
I'd like to write some small modules first for some purposes:
* Learning: to get firmiliar with script language, libraries
* Testing: to debug and fix issues easier

1. **CoinGraph**
This module is to display the price in a nice graph area. When its code is tested, it will be integarated into **CoinsMonitor**.
Practicing in GUI, Json, Graphics

2. **CoinAlert**
This module is to popup an alert when the price of selected coins go up/down to a threshold value. When its code is tested, it will be integarated into **CoinsMonitor**.
Practicing in Json, ListView, Multiple Windows

3. **CoinsMonitor**
This will be the main program that has all feature of **CoinGraph**, and **CoinAlert**.
It will support **TRADING** and **STOP-LIMIT** feature

## Run
* Run **.au3** script directly, or
* Run **.exe** binary files

## Changes
**0.0.0.0**		24/09/2017		20:00
* 	Initialize file

**0.0.0.1**		25/09/2017		15:00
* 	Add Bittrex API
* 	Add Hash HMAC
* 	Add dependent files

## Dependencies
* **WinHttp** for handling connections, requests
* **Json** for handling returned value from exchanges
* **GraphGDIPlus** for displaying
* **Hash HMAC** using SHA512 hashing for encrypted-method of account management
* **Bittrex** for openning API to exchange

currently support Bittex APIs:
	; ===========================================================================================
	; Public Functions:
	; 	time($startDate = "1970/01/01")
	; 	bittrex_openConnection()
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

## Contributing guidelines
I’d love you to help me improve this project. To help me keep this project high
quality, I request that contributions adhere to the following guidelines.

- **Provide a link to the application or project’s homepage**. Unless it’s
  extremely popular, there’s a chance the maintainers don’t know about or use
  the language, framework, editor, app, or project your change applies to.

- **Explain why you’re making a change**. Even if it seems self-evident, please
  take a sentence or two to tell me why your change or addition should happen.
  It’s especially helpful to articulate why this change applies to *everyone*
  who works with the applicable technology, rather than just you or your team.

In general, the more you can do to help me understand the change you’re making,
the more likely I’ll be to accept your contribution quickly.

## Contributing workflow
Here’s how I suggest you go about proposing a change to this project:

1. [Fork this project][fork] to your account.
2. [Create a branch][branch] for the change you intend to make.
3. Make your changes to your fork.
4. [Send a pull request][pr] from your fork’s branch to our `master` branch.

Using the web-based interface to make changes is fine too, and will help you
by automatically forking the project and prompting to send a pull request too.

[fork]: https://help.github.com/articles/fork-a-repo/
[branch]: https://help.github.com/articles/creating-and-deleting-branches-within-your-repository
[pr]: https://help.github.com/articles/using-pull-requests/

## License
[Apache-2.0](./LICENSE).

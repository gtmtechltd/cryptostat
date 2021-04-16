cryptostat
==========

`cryptostat` is a simple tool to go off and query all your exchanges and wallets, cross-reference them with the latest prices from coinmarketcap and provide a summary of what you own where. It was written as a simple alternative to Blockfolio which doesn't always work and is overcomplex.

Features:

* **new** - Eth wallet (ERC20) scanning now supported
* **new** - Currency conversions to your favourite currency
* **new** - Test mode for development using dummy API responses
* Gets realtime prices from coinmarketcap
* Scans Kucoin, Kraken and Binance exchanges
* Ability to specify offline coins 
* Ability to split total holdings into portfolios
* Ability to inject fake (historical) prices

Setup
-----

`cryptostat` is written using ruby (version 3.0.1) so install like this:

```
bundle install
```

Copy `config.json.example` to `config.json` and edit it to supply it with all your api keys. For any exchanges you dont care about, just delete that section in the config document. 

Note: Please allow only read access on your API keys for safety.

The following API keys are mandatory

* coinmarketcap - used to generate price list in USD

The following API keys are optional

* binance
* kraken
* kucoin
* fixer.io  - for currency conversions e.g. display in GBP

**Optionally** if you want to override current prices, you can create a `prices.json` file with whatever prices you want. This is meant to help work out what your portfolio might have looked like in the past, as querying historical prices on coinmarketcap is a paid-for service.

```
{ 
   "ETH": "1000.00",
   "BTC": "1000000.00"
}
```

**Optionally** if you want to divide the total amount into different portfolios (e.g. you are managing funds for different people), you can create a portfolios.json file full of percentages (make sure they add up to 100.0 %):

```
{
    "alice": "27.5",
    "bob":   "72.5"
}
```

Running
-------

To test in development mode (using dummy files, so as not to query actual APIs):

```
export CRYPTOSTAT_TEST=true
bundle exec main.rb
```

To run normally against real APIs:

```
bundle exec main.rb
```

Example output:

```
- coin -| -- holdings --- | ---- price USD ---- | ---- price GBP ---- | ---- total USD ---- | ---- total GBP ---- | EXCHANGES
==================================================================================================================================================
ETH             4.01176901    2448.39732825 USD     1781.78440084 GBP     9822.40453729 USD     7148.10745026 GBP           kraken=       3.50000928
                                                                                                                      binance.free=       0.49875831
                                                                                                                    ledger-0x0568F=       0.00325036
                                                                                                                  metamask-0x3e714=       0.00325036
                                                                                                                  coinbase-0x0B6c8=       0.00325036
                                                                                                                       mew-0x5d628=       0.00325036
BNB            14.00577059     550.38712320 USD      400.53596662 GBP     7708.59578320 USD     5609.81486149 GBP     binance.free=      14.00577059
BTC             0.09983056   62706.29950640 USD    45633.56813273 GBP     6260.00478832 USD     4555.62451090 GBP           kraken=       0.09983047
                                                                                                                      kucoin.trade=       0.00000009
XRP          1787.50000002       1.74608890 USD        1.27068999 GBP     3121.13391299 USD     2271.35835141 GBP           kraken=       0.00000002
                                                                                                                      binance.free=    1787.50000000
KCS           163.99715611      15.84871637 USD       11.53366542 GBP     2599.14441268 USD     1891.48832855 GBP     kucoin.trade=     163.98583232
                                                                                                                       kucoin.main=       0.01132379
USDT         2581.93374899       1.00313434 USD        0.73001596 GBP     2590.02641232 USD     1884.85284066 GBP           kraken=       0.90397000
                                                                                                                      binance.free=       0.02977899
                                                                                                                            inbots=    2281.00000000
                                                                                                                           pancake=     300.00000000
FET          4029.65080000       0.63427655 USD        0.46158524 GBP     2555.91300067 USD     1860.02731744 GBP     binance.free=       0.65080000
                                                                                                                           staking=    4029.00000000
TEL        313593.96060772       0.00735067 USD        0.00534934 GBP     2305.12628707 USD     1677.52105137 GBP     kucoin.trade=  313593.96060772
TRX         12728.05500000       0.15610916 USD        0.11360609 GBP     1986.96591691 USD     1445.98461814 GBP     binance.free=   12728.05500000
ZEC             3.57000000     248.84302035 USD      181.09177249 GBP      888.36958267 USD      646.49762778 GBP     binance.free=       3.57000000
==================================================================================================================================================
TOTAL                                                                    39842.86090844 USD    28995.04391393 GBP

Portfolios
=========================================================
alice            10438.82955801 USD        7596.70150545 GBP
bob              29404.03135043 USD       21398.34240848 GBP
```

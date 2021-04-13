cryptostat
==========

`cryptostat` is a simple tool to go off and query all your exchanges and wallets, cross-reference them with the latest prices from coinmarketcap and provide a summary of what you own where. It was written as a simple alternative to Blockfolio which doesn't always work and is overcomplex.

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

To run:

```
bundle exec main.rb
```

Example output:

```
            COIN        SUPPLY            EXCHANGES                       USD-AMOUNT
===============================================================================================
             ETH        4.15194867           kraken=    2.00000928     $ 8585.77738908
                                       binance.free=    2.15193939
             BTC        0.09983056           kraken=    0.09983047     $ 5814.09585257
                                       kucoin.trade=    0.00000009
             BNB        9.89597804     binance.free                    $ 4491.56681965
             TRX    33939.05500000     binance.free                    $ 3935.84434825
             KCS      163.99715611     kucoin.trade=  163.98583232     $ 2776.71642748
                                        kucoin.main=    0.01132379
```

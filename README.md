cryptostat
==========

`cryptostat` is a simple tool to go off and query all your exchanges and wallets, cross-reference them with the latest prices from coinmarketcap and provide a summary of what you own where. It was written as a simple alternative to Blockfolio which doesn't always work and is overcomplex.

Features:

* **new** - 10 May 2021, Every time `cryptostat` requests an API, it now logs the results to the `history/` dir
* 23 April 2021, Every time `cryptostat` is run without cacheing, write results to `snapshots/` dir
* 22 April 2021, MXC exchange
* 17 April 2021, Now you can specify multiple accounts on the same exchange
* 17 April 2021, Cacheing of coinmarketcap/fixer prices to not exhaust API limits (1x hourly)
* 16 April 2021, Probit exchange
* 16 April 2021, `test.sh` for testing individual cryptostat classes
* 15 April 2021, Dont mix up coin names with the same ticker - e.g. ATM != ATM(chain). Use contract address for lookups
* 15 April 2021, Docker version
* 15 April 2021, Eth wallet (ERC20) scanning now supported
* 14 April 2021, Currency conversions to your favourite currency
* 13 April 2021, Test mode for development using dummy API responses
* Gets realtime prices from coinmarketcap
* Scans Kucoin, Kraken and Binance exchanges
* Ability to specify offline coins 
* Ability to split total holdings into portfolios
* Ability to inject fake (historical) prices

Setup
-----

At the very minimum, you will need:

* an API key for `coinmarketcap.com` (it can be the free one) - this is to query prices of crypto tokens.
* an API key for `fixer.io` if you wish the prices to be displayed in a currency other than USD.

Copy `config/config.json.example` to `config/config.json` and edit it to supply it with these and other api keys for your exchanges in the relevant sections. You will see examples of many exchanges - delete the entries you are not interested in.

**Note:** Please allow only read access on your API keys for safety.

config.json - exchanges
-----------------------

A typical exchange entry looks like:

```
{
  "exchanges": {
    "kraken": {
      "api_key": "...some..api..key..",
      "api_secret": "...some..api..secret.."
    }
  }
}
```

Sometimes you may wish to analyse 2 or more accounts on the same exchange. To do that, give each a different name, but use the "exchange" special attribute to set it to the same exchange:

```
{
  "exchanges": {
    "kraken1": {
      "exchange": "kraken",
      "api_key": "...some..api..key..",
      "api_secret": "...some..api..secret.."
    },
    "kraken2": {
      "exchange": "kraken",
      "api_key": "...another..api..key..",
      "api_secret": "...another..api..secret.."
    }
  }
}
```

config.json - wallets
---------------------

A typical wallet to analyse looks like this:

```
  "wallets": {
    "eth": [
      { "name": "ledger",   "address": "....some...wallet...address..............." }
    ]
  }
```

config.json - prices
--------------------

Prices are obtained by analysing coinmarketcap (mandatory) and fixer.io (for currency conversions)

Coinmarketcap section looks like this:

```
  "prices": {
    "coinmarketcap": {
      "api_key": "...some..api..key..................."
    }
  }
```

Fixer.io section is optional but looks like this:

```
  "prices": {
    "fixer.io": {
      "api_key": "...some..api.key................",
      "currency": "GBP"
    }
  }
```

You set the target currency of the report with the `currency` field

prices.json
-----------

**Optionally** Create a `config/prices.json` if you want to override current prices. This is useful if you wish to find out what your portfolio looked like in the past.

```
{ 
   "ETH": "1000.00",
   "BTC": "1000000.00"
}
```

portfolios.json
---------------

**Optionally** Create a `config/portfolios.json` if you want to divide your total crypto holdings into different portfolios (e.g. you are managing funds for different people)

```
{
    "alice": "27.5%",
    "bob":   "72.5%"
}
```

If you wish to add an unspecified fixed amount of target currency to alice's portfolio, independent of crypto coin analysis, you can do the following in `config.json`

```
{
  "extras": {
    "alice": "1250.0"
  }
}
```

Running
-------

Using docker:

```
./docker-build.sh     # First build the docker image
./docker-run.sh       # Run the docker image - which mounts your config/ directory inside the running container
```

Using ruby3.0.1:

```
bundle install
bundle exec lib/main.rb
```

Example output:

```
- coin -| -- holdings --- | ---- price USD ---- | ---- price GBP ---- | ---- total GBP ---- | EXCHANGES
==================================================================================================================================================
ETH             4.01176901    2448.39732825 USD     1781.78440084 GBP     7148.10745026 GBP            kraken=       3.50000928
                                                                                                 binance.free=       0.49875831
                                                                                               ledger-0x0568F=       0.00325036
                                                                                             metamask-0x3e714=       0.00325036
                                                                                             coinbase-0x0B6c8=       0.00325036
                                                                                                  mew-0x5d628=       0.00325036
BNB            14.00577059     550.38712320 USD      400.53596662 GBP     5609.81486149 GBP      binance.free=      14.00577059
BTC             0.09983056   62706.29950640 USD    45633.56813273 GBP     4555.62451090 GBP            kraken=       0.09983047
                                                                                                 kucoin.trade=       0.00000009
XRP          1787.50000002       1.74608890 USD        1.27068999 GBP     2271.35835141 GBP            kraken=       0.00000002
                                                                                                 binance.free=    1787.50000000
KCS           163.99715611      15.84871637 USD       11.53366542 GBP     1891.48832855 GBP      kucoin.trade=     163.98583232
                                                                                                  kucoin.main=       0.01132379
USDT         2581.93374899       1.00313434 USD        0.73001596 GBP     1884.85284066 GBP            kraken=       0.90397000
                                                                                                 binance.free=       0.02977899
                                                                                                       inbots=    2281.00000000
                                                                                                      pancake=     300.00000000
FET          4029.65080000       0.63427655 USD        0.46158524 GBP     1860.02731744 GBP      binance.free=       0.65080000
                                                                                                      staking=    4029.00000000
TEL        313593.96060772       0.00735067 USD        0.00534934 GBP     1677.52105137 GBP      kucoin.trade=  313593.96060772
TRX         12728.05500000       0.15610916 USD        0.11360609 GBP     1445.98461814 GBP      binance.free=   12728.05500000
ZEC             3.57000000     248.84302035 USD      181.09177249 GBP      646.49762778 GBP      binance.free=       3.57000000
==================================================================================================================================================
TOTAL                                                                    39842.86090844 USD    28995.04391393 GBP

Portfolios
=========================================================
alice            10438.82955801 USD        7596.70150545 GBP
bob              29404.03135043 USD       21398.34240848 GBP
```

Developing
----------

`cryptostat` is written using ruby (version 3.0.1) so install like this:

```
bundle install
```

Set some useful env vars:

```
export CRYPTOSTAT_TEST=true       # Use dummy files, dont query real APIs
export CRYPTOSTAT_DEBUG=true      # show debug
```

Run:

```
bundle exec main.rb
```

Please note ruby 3.0.1 is required to make the kucoin gem work.


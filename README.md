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

Running
-------

To run:

```
bundle exec main.rb
```



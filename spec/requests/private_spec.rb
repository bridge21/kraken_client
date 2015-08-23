require_relative File.join '..', '..', 'lib', 'kraken_client'
require 'spectus'
require 'vcr'
require 'webmock'

include WebMock::API

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
end

# Testing Private Endpoints
KrakenClient.configure do |config|
  config.api_key    = 'COMPUTED'
  config.api_secret = 'COMPUTED'
end

kraken = KrakenClient.load
client = kraken.private

# User Balance
VCR.use_cassette("balance") do
  Spectus.this { client.balance.class }.MUST Equal: Hashie::Mash 
end

# Trade Balance
VCR.use_cassette("trade_balance") do
  Spectus.this { client.trade_balance.c }.MUST Eql: '0.0000' 
end

# Open Orders
VCR.use_cassette("open_orders") do
  Spectus.this { client.open_orders.open.class }.MUST Equal: Hashie::Mash
end

# Closed Orders
VCR.use_cassette("closed_orders") do
  Spectus.this { client.closed_orders.closed.class }.MUST Equal: Hashie::Mash
end

# Query Orders
VCR.use_cassette("query_orders") do
  Spectus.this do
    order = client.query_orders({txid: 'OKRRJ6-MH3UH-DV6IKT'})
    order['OKRRJ6-MH3UH-DV6IKT'].status
  end.MUST Eql: 'canceled'
end

# Trades History
VCR.use_cassette("trades_history") do
  Spectus.this { client.trades_history.trades.class }.MUST Equal: Hashie::Mash
end

# Query Trades
VCR.use_cassette("query_orders") do
  Spectus.this do
    order = client.query_orders({txid: 'O75MLD-64OIU-5O4JDM'})
    order['OKRRJ6-MH3UH-DV6IKT'].status
  end.MUST Eql: 'canceled'
end

# Open Positions

#CANT TEST, NO TEST TRANSACTION FOUND

# Ledgers Info
VCR.use_cassette("ledgers") do
  Spectus.this { client.ledgers.ledger.class }.MUST Equal: Hashie::Mash
end

# Query Ledgers
VCR.use_cassette("query_ledgers") do
  Spectus.this do
    ledger = client.query_ledgers(id: 'LRSNYS-DICDD-3QM34P')
    ledger['LRSNYS-DICDD-3QM34P'].class
   end.MUST Equal: Hashie::Mash
end

# Trade Volume
VCR.use_cassette("trade_volume") do
  Spectus.this { client.trade_volume(id: 'XETHZEUR').count }.MUST Equal: 2
end

# Add Order
VCR.use_cassette("add_order") do
  Spectus.this do

    opts = {
      pair: 'ETHEUR',
      type: 'buy',
      ordertype: 'market',
      volume: 0.01
    }

    client.add_order(opts).txid
  end.MUST Eql: ['OEDIZV-VDAW3-RHLJVB']
end

# Cancel Order
VCR.use_cassette("cancel_order") do
  Spectus.this do
    client.cancel_order(txid: 'ODEC3J-QAMVD-NSF7XD').count
  end.MUST Eql: 1
end

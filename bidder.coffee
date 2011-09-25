
EE = if EventEmitter? then EventEmitter else require('events').EventEmitter
Collection = require('./collection').Collection
Auction = require('./auction').Auction

class Bidder extends EE
  @last_used_id = 0
  @collection = new Collection()

  constructor: (name: @name, client: client, sid: @sid, image: @image) ->
    @constructor.collection.add @
    @new_client(client)
    @state = "logged_out"

    # unil we have workflow, join this bidder the live auction
    global.live_auction.trigger 'bidder_joined', @

  new_client: (new_client) ->
    # set up bindings required....
    new_client.on 'trigger', (data) =>
      console.log "got #{@name}:#{new_client.id} trigger: ", data

    new_client.on 'bid', (data) =>
      console.log "got bid #{@name}:#{new_client.id} bid: ", data
      if global.live_auction?
        global.live_auction.trigger 'bid', data, @
      else
        console.log "no global live_auction to tribber bid to"

    @emit 'state', state: @state

    if global.live_auction? and global.live_auction.current_bid?
      @emit 'newbid', global.live_auction.current_bid

  login: ->
    @state = "logged_in"

  logout: ->
    @state = "logged_out"

  # wrapper function to emit to the sid room
  emit: (name, args) ->
    global.io.sockets.in(@sid).emit(name, args)

(exports ? window).Bidder = Bidder


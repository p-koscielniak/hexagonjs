EventEmitter = require('modules/event-emitter/main')
utils = require('modules/util/main/utils')
HList = require('modules/list/main')
select = require('modules/selection/main')


class ClickDetector extends EventEmitter
  constructor: ->
    super
    @eventId = utils.randomId()
    @exceptions = new HList

    # the original element clicked
    container = undefined

    @downAction = (e) =>
      e = e.event
      container = e.target
      call = true
      for element in @exceptions.entries()
        if element.contains(e.target) then call = false
      if call then @emit('click')

    @upAction = (e) =>
      e = e.event
      call = true
      isInDom = document.documentElement.contains(e.target)
      releasedOutside = container and not container.contains(e.target)
      if releasedOutside or not isInDom
        call = false
      container = undefined
      for element in @exceptions.entries()
        if element.contains(e.target) then call = false
      if call then @emit('click')

    select(document).on('pointerdown', 'hx.click-detector.' + @eventId, @downAction)
    select(document).on('pointerup', 'hx.click-detector.' + @eventId, @upAction)

  addException: (element) ->
    @exceptions.add(element)
    this

  removeException: (element) ->
    @exceptions.remove(element)
    this

  removeAllExceptions: ->
    @exceptions.clear()
    this

  cleanUp: ->
    select(document).off('pointerdown', 'hx.click-detector.' + @eventId, @downAction)
    select(document).off('pointerup', 'hx.click-detector.' + @eventId, @upAction)
    this

module.exports = ClickDetector
module.exports.hx = {
  ClickDetector: ClickDetector
}
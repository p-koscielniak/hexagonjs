import { EventEmitter } from 'utils/event-emitter'
import { preferences } from 'utils/preferences'
import { zeroPad } from 'utils/format'
import { randomId } from 'utils/utils'
import logger from 'utils/logger'

class PreferencesHandler extends EventEmitter
  constructor: () ->
    super()

    @_ = {
      uniqueId: randomId()
    }

    preferences.on 'localechange', 'hx.date-time-localizer' + @_.uniqueId, =>
      if not @_.instanceLocale
        @emit 'localechange', {
          cause: 'api',
          value: preferences.locale()
        }

    preferences.on 'timezonechange', 'hx.date-time-localizer' + @_.uniqueId, =>
      if not @_.instanceTimezone
        @emit 'timezonechange', {
          cause: 'api',
          value: preferences.timezone()
        }

  locale: (locale) ->
    if arguments.length
      if not locale? or preferences.isLocaleSupported(locale)
        @_.instanceLocale = if locale then true else false
        @_.locale = locale
        @emit 'localechange', {
          cause: 'api',
          value: locale or preferences.locale()
        }
      else
        logger.warn(locale + ' is not a valid locale. If you think the locale should be added to the list contact the maintainers of hexagon')
      this
    else
      @_.locale or preferences.locale()

  timezone: (timezone) ->
    if arguments.length
      if not timezone? or preferences.isTimezoneSupported(timezone)
        @_.instanceTimezone = if timezone then true else false
        @_.timezone = timezone
        @emit 'timezonechange', {
          cause: 'api',
          value: timezone or preferences.timezone()
        }
      else
        logger.warn(timezone + ' is not a valid timezone')
      this
    else
      @_.timezone or preferences.timezone()

class DateTimeLocalizer extends PreferencesHandler
  constructor: () ->
    super()

  # get the display order for the date so dates can be displayed correctly when localised
  dateOrder: -> ['DD','MM','YYYY']

  # get the day the week starts on, 0 for sunday, 1 for monday etc.
  weekStart: -> 1

  # localise the days of the week and return as array of 2 char days ('Su', 'Mo' etc.)
  weekDays: -> ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']

  # localise 'today' text
  todayText: -> 'Today'

  # localise the day of the month and optionally zero pad (01, 02)
  day: (day, pad) -> if pad then zeroPad(day) else day

  # localise the month in the format of mmm (Jan, Feb etc.) or 01, 02 etc.
  month: (month, short) ->
    if short then zeroPad(month + 1)
    else ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][month]

  fullMonth: (month) ->
    ['January','February','March','April','May','June','July','August','September','October','November','December'][month]

  # localise the full year in the format of yyyy
  year: (year) -> year

  # localise a date object to return a date string of dd/mm/yyyy (or localised format)
  date: (date, useInbuilt) ->
    if useInbuilt
      date.getFullYear() + '-' +
      zeroPad(date.getMonth() + 1 )+ '-' +
      zeroPad(date.getDate())
    else
      zeroPad(date.getDate()) + '/' + zeroPad(date.getMonth() + 1) + '/' + date.getFullYear()

  # localise a date object to return a time string of hh:mm or hh:mm:ss (or localised format)
  time: (date, showSeconds) ->
    date = preferences.applyTimezoneOffset(date, @timezone())
    timeString = date.getHours() + ':' + zeroPad date.getMinutes()
    if showSeconds
      timeString += ':' + zeroPad date.getSeconds()
    timeString

  # check if a time is a valid time (time as array of [hh, mm, ss])
  checkTime: (time) ->
    not isNaN(time[0]) and not isNaN(time[1]) and not isNaN(time[2])

  # convert a localised date string back to a date object (unlocalise)
  stringToDate: (dateString, useInbuilt) ->
    if useInbuilt
      order = ['YYYY', 'MM', 'DD']
      split = dateString.split('-')
    else
      order = @dateOrder()
      split = dateString.split('/')
    allValid = split.length is 3 and not split.some (e) -> e is '' or e is '0'
    if allValid
      for w, i in order
        part = split[i]
        switch w
          when 'DD'
            daysValid = part.length < 3 and part isnt ''
            day = Number split[i]
          when 'MM'
            monthsValid = part.length < 3 and part isnt ''
            month = Number split[i]
          when 'YYYY'
            yearsValid = part.length < 5 and part isnt ''
            year = Number split[i]
            if year.toString().length is 2 then year += 2000
      if daysValid and monthsValid and yearsValid
        new Date(Date.UTC(year, month - 1, day))
      else
        new Date('Invalid Date')
    else
      new Date('Invalid Date')


class DateTimeLocalizerMoment extends PreferencesHandler
  constructor: () ->
    super()

  dateOrder: ->
    date = moment({year:2003, month:11, day:22}).locale(@locale())
    dateCheck = date.format('L')
    yearIndex = dateCheck.indexOf(date.format('YYYY'))
    monthIndex = dateCheck.indexOf(date.format('MM'))
    dayIndex = dateCheck.indexOf(date.format('DD'))

    result = []
    for i in [0..dateCheck.length]
      switch i
        when yearIndex then result.push 'YYYY'
        when monthIndex then result.push 'MM'
        when dayIndex then result.push 'DD'

    if result.length is 0 then result = ['DD','MM','YYYY']
    result

  weekStart: -> moment().locale(@locale()).weekday(0).toDate().getDay()

  weekDays: ->
    dayDate = moment().weekday(0)
    dayDate.locale(@locale())
    dayNames = [dayDate.format('dd')]
    for i in [0...6]
      dayNames.push(dayDate.add(1,'d').format('dd'))
    dayNames

  todayText: ->
    today = moment({hour: 12, minute: 0, second: 0}).locale(@locale())
    tomorrow = today.clone().add(1, 'day')
    todayArr = today.calendar().split('').reverse()
    tomorrowArr = tomorrow.calendar().split('').reverse()
    for i in [0..todayArr.length]
      if todayArr[i] isnt tomorrowArr[i]
        break
    todayArr.splice(0, i)
    todayArr.reverse().join('')

  day: (day, pad) ->
    moment({day: day, month: 0}).locale(@locale()).format(if pad then 'DD' else 'D')

  month: (month, short) ->
    moment({month: month}).locale(@locale()).format(if short then 'MM' else 'MMM')

  fullMonth: (month) ->
    moment({month: month}).locale(@locale()).format('MMMM')

  year: (year) ->
    moment({year: year}).locale(@locale()).format('YYYY')

  decade: (start, end) ->
    @year(start) + ' - ' + @year(end)

  date: (date) ->
    moment(date).locale(@locale()).format('L')

  time: (date, showSeconds) ->
    date = preferences.applyTimezoneOffset(date, @timezone())
    format = if showSeconds then 'H:mm:ss' else 'H:mm'
    moment(date).locale(@locale()).format(format)

  checkTime: (time) ->
    moment({hours: time[0], minutes: time[1], seconds: time[2]}).locale(@locale()).isValid()

  stringToDate: (dateString) ->
    order = @dateOrder()
    split = dateString.split('/')
    allValid = split.length is 3 and not split.some (e) -> e is '' or e is '0'
    if allValid
      fmt = ''
      for w, i in order
        part = split[i]
        switch w
          when 'DD'
            daysValid = part.length < 3 and part isnt ''
            fmt += 'DD'
          when 'MM'
            monthsValid = part.length < 3 and part isnt ''
            fmt += 'MM'
          when 'YYYY'
            yearsValid = part.length < 5 and part isnt ''
            fmt += 'YYYY'
      if daysValid and monthsValid and yearsValid
        moment(dateString, format, @locale()).toDate()
      else
        new Date('Invalid Date')
    else
      new Date('Invalid Date')

#XXX: [2.0.0] this doesn't need to be a function
export dateTimeLocalizer = -> if moment? then new DateTimeLocalizerMoment else new DateTimeLocalizer
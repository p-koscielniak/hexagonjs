chai = require('chai')
should = chai.should()
select = require('modules/selection/main')
elementSetTests = require('./element-set.spec')
util = require('modules/util/main/utils')

describe 'Selection Api', ->
  origConsoleWarning = util.consoleWarning
  fixture = undefined

  beforeEach ->
    body = select('body')
    fixture = body.append('div').attr('id', 'fixture')
    fixture.html """
      <div class="wrapper">
        <div id="outer-1">
          <span class="first one"></span>
          <span class="one two"></span>
          <span class="two"></span>
          <span></span>
        </div>
        <div id="outer-2">
          <span class="one"></span>
          <span class="one two"></span>
          <span class="two"></span>
        </div>
        <div id="before-empty"></div><div id="empty"></div><div id="after-empty">
        <div id="text-node">text1</div>
        <div id="html-node"><p>text1</p></div>
        <input value="initial-value"></input>
        <div id="multi">
          <div></div>
          <div></div>
        </div>
      </div>
    """

    fixture.selectAll('span').style('display', 'block').style('display')
    fixture.select('span').style('display', 'inline-block').style('display')
    util.consoleWarning = chai.spy()
    return


  afterEach ->
    fixture.remove()
    util.consoleWarning = origConsoleWarning
    return


  # selection

  it 'select an element by id', ->
    selection = select('#fixture').select('#outer-1')
    selection.size().should.equal(1)
    selection.node().tagName.toLowerCase().should.equal('div')

  it 'select element by class', ->
    selection = select('#fixture').select('.one')
    selection.size().should.equal(1)
    selection.node().tagName.toLowerCase().should.equal('span')

  it 'select element by tag', ->
    selection = select('#fixture').select('span')
    selection.size().should.equal(1)
    selection.class().should.equal('first one')
    selection.node().tagName.toLowerCase().should.equal('span')

  it 'select.selectAll elements by id', ->
    selection = select('#fixture').selectAll('#outer-1')
    selection.size().should.equal(1)
    selection.node().tagName.toLowerCase().should.equal('div')

  it 'select.selectAll elements by class', ->
    selection = select('#fixture').selectAll('.one')
    selection.size().should.equal(4)
    selection.node().tagName.toLowerCase().should.equal('span')

  it 'select.selectAll elements by tag', ->
    selection = select('#fixture').selectAll('span')
    selection.size().should.equal(7)
    selection.node().tagName.toLowerCase().should.equal('span')

  it 'select then selectAll should result in singleSelection being false', ->
    selection = select('#fixture').selectAll('span')
    selection.singleSelection.should.equal(false)

  it 'select then selectAll should result in singleSelection being false', ->
    selection = select('#fixture').selectAll('div').select('span')
    selection.singleSelection.should.equal(false)

  it 'select alone should result in singleSelection being true', ->
    selection = select('#fixture')
    selection.singleSelection.should.equal(true)

  it 'select alone should result in singleSelection being true', ->
    selection = select('#fixture')
    selection.singleSelection.should.equal(true)

  it 'select should log a warning if an invalid type is given', ->
    select(3.14156)
    util.consoleWarning.should.have.been.called()

  it 'select.selectAll should log a warning if an invalid type is given', ->
    select.selectAll(3.14156)
    util.consoleWarning.should.have.been.called()

  it 'selection.select should log a warning if an invalid type is given', ->
    select('#fixture').select(3.1415)
    util.consoleWarning.should.have.been.called()

  it 'selection.selectAll should log a warning if an invalid type is given', ->
    select('#fixture').selectAll(3.1415)
    util.consoleWarning.should.have.been.called()

  # creating detached elements

  it 'select.detached creates a detached div', ->
    selection = select.detached('div')
    selection.size().should.equal(1)
    selection.node().tagName.toLowerCase().should.equal('div')

  it 'select.detached creates a correctly namespaced svg', ->
    selection = select.detached('svg')
    selection.size().should.equal(1)
    selection.node().tagName.toLowerCase().should.equal('svg')
    selection.node().namespaceURI.should.equal('http://www.w3.org/2000/svg')

  it 'select.detached creates a correctly namespaced span', ->
    selection = select.detached('span')
    selection.size().should.equal(1)
    selection.node().tagName.toLowerCase().should.equal('span')
    selection.node().namespaceURI.should.equal('http://www.w3.org/1999/xhtml')

  # filtering
  it 'filter should work', ->
    selection = select('#fixture').selectAll('span')
    selection.filter((selection) -> selection.classed('one')).size().should.equal(4)
    selection.filter((selection) -> selection.classed('one')).class().should.eql([
      "first one",
      "one two",
      "one",
      "one two"
    ])

  # mapping
  it 'map should work', ->
    selection = select('#fixture').selectAll('span')
    selection.map((selection) -> selection.classed('one')).should.eql([true, true, false, false, true, true, false])

  # appending
  it 'append an element by tag name', ->
    selection = select('#empty')
    appended = selection.append('h1')
    appended.size().should.equal(1)
    appended.node().tagName.toLowerCase().should.equal('h1')
    appended.node().parentNode.should.equal(selection.node())

  if navigator.userAgent.indexOf("PhantomJS") is -1
    it 'appending svg should have a different namespace', ->
      selection = select('#empty')
      appended = selection.append('svg')
      appended.size().should.equal(1)
      appended.node().tagName.toLowerCase().should.equal('svg')
      appended.node().parentNode.should.equal(selection.node())
      appended.node().namespaceURI.should.equal('http://www.w3.org/2000/svg')

  it 'append an array of selections', ->
    items = for i in [0...5]
      select.detached('div')

    selection = select('#empty')
    appended = selection.append(items)
    appended.size().should.equal(5)
    appended.node().parentNode.should.equal(selection.node())



  it 'append an element by tag name to multiple elements', ->
    selection = select('#fixture').selectAll('span')
    appended = selection.append('h1')
    appended.size().should.equal(7)
    appended.node().tagName.toLowerCase().should.equal('h1')

  it 'append an existing element to multiple elements should log a warning', ->
    selection = select('#fixture').selectAll('span')
    appended = selection.append(document.createElement('h1'))
    appended.size().should.equal(0)
    util.consoleWarning.should.have.been.called()

  it 'appending an existing element to an empty selection should do nothing', ->
    selection = select('#empty').select('span')
    appended = selection.append(document.createElement('h1'))
    appended.size().should.equal(0)

  it 'append an existing element', ->
    selection = select('#empty')
    element = document.createElement('h1')
    appended = selection.append(element)
    appended.size().should.equal(1)
    appended.node().tagName.toLowerCase().should.equal('h1')
    appended.node().should.equal(element)
    appended.node().parentNode.should.equal(selection.node())

  it 'append an array of elements by tag name', ->
    selection = select('#empty')
    appended = selection.append(['h1', 'h2'])
    appended.size().should.equal(2)
    appended.node(0).tagName.toLowerCase().should.equal('h1')
    appended.node(0).parentNode.should.equal(selection.node())
    appended.node(1).tagName.toLowerCase().should.equal('h2')
    appended.node(1).parentNode.should.equal(selection.node())

  it 'append an array of existing elements', ->
    selection = select('#empty')
    elements  = [
      document.createElement('h1'),
      document.createElement('h2')
    ]
    appended = selection.append(elements)
    appended.size().should.equal(2)
    appended.node(0).tagName.toLowerCase().should.equal('h1')
    appended.node(0).parentNode.should.equal(selection.node())
    appended.node(0).should.equal(elements[0])
    appended.node(1).tagName.toLowerCase().should.equal('h2')
    appended.node(1).parentNode.should.equal(selection.node())
    appended.node(1).should.equal(elements[1])

  it 'append a selection', ->
    selection = select('#empty')
    newSelection = select.selectAll([
      document.createElement('h1'),
      document.createElement('h2')
    ])
    elements = newSelection.nodes
    appended = selection.append(newSelection)
    appended.size().should.equal(2)
    appended.node(0).tagName.toLowerCase().should.equal('h1')
    appended.node(0).parentNode.should.equal(selection.node())
    appended.node(0).should.equal(elements[0])
    appended.node(1).tagName.toLowerCase().should.equal('h2')
    appended.node(1).parentNode.should.equal(selection.node())
    appended.node(1).should.equal(elements[1])

  # prepending
  it 'prepend an element by tag name', ->
    selection = select('#empty')
    prepended = selection.prepend('h1')
    prepended.size().should.equal(1)
    prepended.node().tagName.toLowerCase().should.equal('h1')
    prepended.node().parentNode.should.equal(selection.node())

  it 'prepend an existing element', ->
    selection = select('#empty')
    element = document.createElement('h1')
    prepended = selection.prepend(element)
    prepended.size().should.equal(1)
    prepended.node().tagName.toLowerCase().should.equal('h1')
    prepended.node().should.equal(element)
    prepended.node().parentNode.should.equal(selection.node())

  it 'prepend an array of elements by tag name', ->
    selection = select('#empty')
    prepended = selection.prepend(['h1', 'h2'])
    prepended.size().should.equal(2)
    prepended.node(0).tagName.toLowerCase().should.equal('h1')
    prepended.node(0).parentNode.should.equal(selection.node())
    prepended.node(1).tagName.toLowerCase().should.equal('h2')
    prepended.node(1).parentNode.should.equal(selection.node())

  it 'prepend an array of existing elements', ->
    selection = select('#empty')
    elements  = [
      document.createElement('h1'),
      document.createElement('h2')
    ]
    prepended = selection.prepend(elements)
    prepended.size().should.equal(2)
    prepended.node(0).tagName.toLowerCase().should.equal('h1')
    prepended.node(0).parentNode.should.equal(selection.node())
    prepended.node(0).should.equal(elements[0])
    prepended.node(1).tagName.toLowerCase().should.equal('h2')
    prepended.node(1).parentNode.should.equal(selection.node())
    prepended.node(1).should.equal(elements[1])

  it 'prepend a selection', ->
    selection = select('#empty')
    newSelection = select.selectAll([
      document.createElement('h1'),
      document.createElement('h2')
    ])
    elements = newSelection.nodes
    appended = selection.prepend(newSelection)
    appended.size().should.equal(2)
    appended.node(0).tagName.toLowerCase().should.equal('h1')
    appended.node(0).parentNode.should.equal(selection.node())
    appended.node(0).should.equal(elements[0])
    appended.node(1).tagName.toLowerCase().should.equal('h2')
    appended.node(1).parentNode.should.equal(selection.node())
    appended.node(1).should.equal(elements[1])

  # insert before
  it 'insertBefore an element by tag name', ->
    selection = select('#empty')
    inserted = selection.insertBefore('h1')
    inserted.size().should.equal(1)
    inserted.node().tagName.toLowerCase().should.equal('h1')
    inserted.node().should.equal(select('#before-empty').node().nextSibling)

  it 'insertBefore an existing element', ->

    selection = select('#empty')
    element = document.createElement('h1')
    inserted = selection.insertBefore(element)
    inserted.size().should.equal(1)
    inserted.node().tagName.toLowerCase().should.equal('h1')
    inserted.node().should.equal(element)
    inserted.node().should.equal(select('#before-empty').node().nextSibling)

  it 'insertBefore an array of elements by tag name', ->
    selection = select('#empty')
    inserted = selection.insertBefore(['h1', 'h2'])
    inserted.size().should.equal(2)
    inserted.node(0).tagName.toLowerCase().should.equal('h1')
    inserted.node(0).should.equal(select('#before-empty').node().nextSibling)
    inserted.node(1).tagName.toLowerCase().should.equal('h2')
    inserted.node(1).parentNode.should.equal(select('#fixture').select('.wrapper').node())
    inserted.node(1).should.equal(select('#before-empty').node().nextSibling.nextSibling)

  it 'insertBefore an array of existing elements', ->
    selection = select('#empty')
    elements  = [
      document.createElement('h1'),
      document.createElement('h2')
    ]
    inserted = selection.insertBefore(elements)
    inserted.size().should.equal(2)
    inserted.node(0).tagName.toLowerCase().should.equal('h1')
    inserted.node(0).parentNode.should.equal(select('#fixture').select('.wrapper').node())
    inserted.node(0).should.equal(elements[0])
    inserted.node(1).tagName.toLowerCase().should.equal('h2')
    inserted.node(1).parentNode.should.equal(select('#fixture').select('.wrapper').node())
    inserted.node(1).should.equal(elements[1])

  it 'insertBefore a selection', ->
    selection = select('#empty')
    newSelection = select.selectAll([
      document.createElement('h1'),
      document.createElement('h2')
    ])
    elements = newSelection.nodes
    inserted = selection.insertBefore(newSelection)
    inserted.size().should.equal(2)
    inserted.node(0).tagName.toLowerCase().should.equal('h1')
    inserted.node(0).parentNode.should.equal(select('#fixture').select('.wrapper').node())
    inserted.node(0).should.equal(elements[0])
    inserted.node(1).tagName.toLowerCase().should.equal('h2')
    inserted.node(1).parentNode.should.equal(select('#fixture').select('.wrapper').node())
    inserted.node(1).should.equal(elements[1])

  # insert after
  it 'insertAfter an element by tag name', ->
    selection = select('#empty')
    inserted = selection.insertAfter('h1')
    inserted.size().should.equal(1)
    inserted.node().tagName.toLowerCase().should.equal('h1')
    inserted.node().should.equal(select('#empty').node().nextSibling)

  it 'insertAfter an existing element', ->

    selection = select('#empty')
    element = document.createElement('h1')
    inserted = selection.insertAfter(element)
    inserted.size().should.equal(1)
    inserted.node().tagName.toLowerCase().should.equal('h1')
    inserted.node().should.equal(element)
    inserted.node().should.equal(select('#empty').node().nextSibling)

  it 'insertAfter an array of elements by tag name', ->
    selection = select('#empty')
    inserted = selection.insertAfter(['h1', 'h2'])
    inserted.size().should.equal(2)
    inserted.node(0).tagName.toLowerCase().should.equal('h1')
    inserted.node(0).should.equal(select('#empty').node().nextSibling)
    inserted.node(1).tagName.toLowerCase().should.equal('h2')
    inserted.node(1).parentNode.should.equal(select('#fixture').select('.wrapper').node())
    inserted.node(1).should.equal(select('#empty').node().nextSibling.nextSibling)

  it 'insertAfter an array of existing elements', ->
    selection = select('#empty')
    elements  = [
      document.createElement('h1'),
      document.createElement('h2')
    ]
    inserted = selection.insertAfter(elements)
    inserted.size().should.equal(2)
    inserted.node(0).tagName.toLowerCase().should.equal('h1')
    inserted.node(0).parentNode.should.equal(select('#fixture').select('.wrapper').node())
    inserted.node(0).should.equal(elements[0])
    inserted.node(1).tagName.toLowerCase().should.equal('h2')
    inserted.node(1).parentNode.should.equal(select('#fixture').select('.wrapper').node())
    inserted.node(1).should.equal(elements[1])

  it 'insertAfter a selection', ->
    selection = select('#empty')
    newSelection = select.selectAll([
      document.createElement('h1'),
      document.createElement('h2')
    ])
    elements = newSelection.nodes
    inserted = selection.insertAfter(newSelection)
    inserted.size().should.equal(2)
    inserted.node(0).tagName.toLowerCase().should.equal('h1')
    inserted.node(0).parentNode.should.equal(select('#fixture').select('.wrapper').node())
    inserted.node(0).should.equal(elements[0])
    inserted.node(1).tagName.toLowerCase().should.equal('h2')
    inserted.node(1).parentNode.should.equal(select('#fixture').select('.wrapper').node())
    inserted.node(1).should.equal(elements[1])

  # cloning

  it 'should clone a single selection', ->
    selection = select('#fixture').select('span')
    clone = selection.clone()
    clone.size().should.equal(1)
    clone.node().tagName.toLowerCase().should.equal('span')
    clone.node().should.not.equal(selection.node())

  it 'should be able to do a shallow clone', ->
    selection = select('#fixture')
    clone = selection.clone(false)
    clone.size().should.equal(1)
    clone.node().tagName.toLowerCase().should.equal('div')
    clone.selectAll('span').size().should.equal(0)

  it 'should be able to do a deep clone by default', ->
    selection = select('#fixture')
    clone = selection.clone()
    clone.size().should.equal(1)
    clone.node().tagName.toLowerCase().should.equal('div')
    clone.selectAll('span').size().should.equal(7)

  it 'should clone a multi selection', ->
    selection = select('#fixture').selectAll('span')
    clone = selection.clone()
    clone.size().should.equal(7)
    clone.node().tagName.toLowerCase().should.equal('span')
    clone.node().should.not.equal(selection.node())

  # removing

  it 'remove works', ->
    select('#fixture').selectAll('span').size().should.equal(7)
    select('#fixture').selectAll('span').remove()
    select('#fixture').selectAll('span').size().should.equal(0)

  it 'remove do nothing when there is nothing to remove', ->
    select('#fixture').selectAll('span').size().should.equal(7)
    select('#fixture').selectAll('span').remove()
    select('#fixture').selectAll('span').size().should.equal(0)
    select('#fixture').selectAll('span').remove()
    select('#fixture').selectAll('span').size().should.equal(0)

  it 'trying to remove the document should fail', ->
    select(document).remove()
    select('#fixture').selectAll('span').size().should.equal(7)

  it 'clear works', ->
    select('#fixture').selectAll('span').size().should.equal(7)
    select('#fixture').clear()
    select('#fixture').selectAll('span').size().should.equal(0)

  it 'clear returns the correct thing', ->
    selection = select('#fixture')
    selection.clear().should.equal(selection)

  # getting / setting properties

  it 'get a property from a single selection', ->
    selection = select('#fixture').select('span')
    selection.prop('className').should.equal('first one')

  it 'set a property for a single selection', ->
    selection = select('#fixture').select('span')
    selection.prop('className', 'hello')
    selection.prop('className').should.equal('hello')

  it 'set a property to null should do nothing', ->
    selection = select('#fixture').select('span')
    selection.prop('className', 'hello')
    selection.prop('className', null)
    selection.prop('className').should.equal('hello')

  it 'get a property from a multi selection', ->
    selection = select('#fixture').selectAll('span')
    selection.prop('className').should.eql(['first one', 'one two', 'two', '', 'one', 'one two', 'two'])

  it 'set a property for a multi selection', ->
    selection = select('#fixture').selectAll('span')
    selection.prop('className', 'hello')
    selection.prop('className').should.eql(['hello', 'hello', 'hello', 'hello', 'hello', 'hello', 'hello'])


  # getting / setting attributes

  it 'get a attribute from a single selection', ->
    selection = select('#fixture').select('span')
    selection.attr('class').should.equal('first one')

  it 'set a attribute for a single selection', ->
    selection = select('#fixture').select('span')
    selection.attr('class', 'hello')
    selection.attr('class').should.equal('hello')

  it 'get a attribute from a multi selection', ->
    selection = select('#fixture').selectAll('span')
    selection.attr('class').should.eql(['first one', 'one two', 'two', undefined, 'one', 'one two', 'two'])

  it 'set a attribute for a multi selection', ->
    selection = select('#fixture').selectAll('span')
    selection.attr('class', 'hello')
    selection.attr('class').should.eql(['hello', 'hello', 'hello', 'hello', 'hello', 'hello', 'hello'])

   # getting / setting data

  it 'set then get data from a single selection', ->
    selection = select('#fixture')
    selection.data('key', 'value')
    selection.data('key').should.equal('value')

  it 'overwrite data from a single selection', ->
    selection = select('#fixture')
    selection.data('key', 'value')
    selection.data('key', 'value2')
    selection.data('key').should.equal('value2')

  it 'get undefined for a non existant data key for a single selection', ->
    selection = select('#fixture')
    selection.data('key', 'value')
    should.not.exist(selection.data('key2'))

  it 'get undefined when no data has ever been set for an element', ->
    selection = select('#fixture')
    should.not.exist(selection.data('key'))

  it 'get undefined for a non existant data key for a multi selection', ->
    selection = select('#fixture').selectAll('span')
    selection.data('key', 'value')
    selection.data('key2').should.eql([undefined, undefined, undefined, undefined, undefined, undefined, undefined])

  it 'set then get data from a multi selection', ->
    selection = select('#fixture').selectAll('span')
    selection.data('key', 'value')
    selection.data('key').should.eql(['value', 'value', 'value', 'value', 'value', 'value', 'value'])

  # getting / setting value for input elements

  it 'get value for an input element', ->
    selection = select('#fixture').select('input')
    selection.value().should.equal('initial-value')

  it 'set value for an input element', ->
    selection = select('#fixture').select('input')
    selection.value('test')
    selection.value().should.equal('test')

  #getting / setting styles

  it 'get a style from a single selection', ->
    selection = select('#fixture').select('span')
    selection.style('display').should.equal('inline-block')

  it 'set a style for a single selection', ->
    selection = select('#fixture').select('span')
    selection.style('display', 'inline')
    selection.style('display').should.equal('inline')

  it 'remove a style from a single selection', ->
    selection = select('#fixture').select('span')
    node = selection.node()
    initial = node.style.getPropertyValue('color')
    node.style.setProperty('color', 'red')
    node.style.getPropertyValue('color').should.equal('red')
    selection.style('color', undefined)
    node.style.getPropertyValue('color').should.equal('')

  it 'get a style from a multi selection', ->
    selection = select('#fixture').selectAll('span')
    selection.style('display').should.eql(['inline-block', 'block', 'block', 'block', 'block', 'block', 'block'])

  it 'set a style for a multi selection', ->
    selection = select('#fixture').selectAll('span')
    selection.style('display', 'inline')
    selection.style('display').should.eql(['inline', 'inline', 'inline', 'inline', 'inline', 'inline', 'inline'])

  it 'remove a style from a multi selection', ->
    selection = select('#fixture').selectAll('span')
    initial = selection.nodes.map (node) -> node.style.getPropertyValue('color')
    selection.nodes.forEach (node) ->
      node.style.setProperty('color', 'red')
      node.style.getPropertyValue('color').should.equal('red')

    selection.style('color', undefined)

    selection.nodes.map (node, index) ->
      initial[index].should.equal('')
      node.style.getPropertyValue('color').should.equal('')

  # other methods

  it 'get nth node', ->
    selection = select('#fixture').selectAll('span')
    selection.node(3).should.equal(selection.nodes[3])

  it 'size', ->
    select('#fixture').selectAll('span').size().should.equal(7)
    select('#fixture').selectAll('span').remove()
    select('#fixture').selectAll('span').size().should.equal(0)

  it 'empty', ->
    select('#fixture').selectAll('span').empty().should.equal(false)
    select('#fixture').selectAll('span').remove()
    select('#fixture').selectAll('span').empty().should.equal(true)

  # getting / setting text

  it 'get text', ->
    select('#text-node').text().should.equal('text1')

  it 'get when not set', ->
    select('#empty').text().should.equal('')

  it 'set text', ->
    select('#text-node').text('Hello')
    select('#text-node').node().textContent.should.equal('Hello')

  it 'set text to undefined should do the same as setting it to ""', ->
    select('#text-node').text(undefined)
    select('#text-node').node().textContent.should.equal('')

    # getting / setting html

  it 'get html', ->
    select('#html-node').html().should.equal('<p>text1</p>')

  it 'get when not set', ->
    select('#empty').html().should.equal('')

  it 'set html', ->
    select('#html-node').html('<p>text2</p>')
    select('#html-node').node().innerHTML.should.equal('<p>text2</p>')

  it 'set html to undefined should do the same as setting it to ""', ->
    select('#html-node').html(undefined)
    select('#html-node').node().textContent.should.equal('')


  # getting / setting the class

  it 'should return undefined when getting the class for an empty selection', ->
    selection = select('#not-a-thing')
    should.not.exist(selection.class())

  it 'get class that has not been set', ->
    selection = select('#fixture')
    selection.class().should.equal('')

  it 'get class that has been set', ->
    selection = select('.wrapper')
    selection.class().should.equal('wrapper')

  it 'set the class', ->
    selection = select('.wrapper')
    selection.class('some-class')
    selection.class().should.equal('some-class')

  it 'set the class to undefined works', ->
    selection = select('.wrapper')
    selection.class(undefined)
    selection.class().should.equal('')

  it 'classed (get) when the class doesnt exist', ->
    selection = select('#fixture')
    selection.classed('some-class').should.equal(false)

  it 'classed (get) when the class does exist', ->
    selection = select('#fixture').class('some-class another-class')
    selection.classed('some-class').should.equal(true)

  it 'classed (get) not detect classes that have the same prefix', ->
    selection = select('#fixture').class('some-class-but-not-the-one-you-expect')
    selection.classed('some-class').should.equal(false)

  it 'classed should let you detect multiple classes on single selections', ->
    selection = select('#fixture').class('some-class some-other-class')
    selection.classed('some-class some-other-class').should.equal(true)

  it 'classed should be false when some of the classes are not present', ->
    selection = select('#fixture').class('some-class')
    selection.classed('some-class some-other-class').should.equal(false)

  it 'classed should let you detect multiple classes on multi-selections', ->
    selection = select.detached('div')
    selection
      .append('div').class('some-class some-class-2')
      .append('div').class('some-class')
      .append('div').class('some-class some-class-2')
      .append('div').class('some-class')
    selection.selectAll('div').classed('some-class some-class-2').should.eql([true, false, true, false])

  it 'classed (add)', ->
    selection = select('#fixture')
    selection.classed('some-class', true)
    selection.class().should.equal('some-class')

  it 'classed add multiple classes', ->
    selection = select('#fixture')
    selection.classed('some-class-1', true)
    selection.classed('some-class-2', true)
    selection.classed('some-class-3', true)
    selection.class().should.equal('some-class-1 some-class-2 some-class-3')

  it 'classed should not add a class if it already exists', ->
    selection = select('#fixture')
    selection.classed('some-class-1', true)
    selection.classed('some-class-2', true)
    selection.classed('some-class-1', true)
    selection.class().should.equal('some-class-1 some-class-2')

  it 'classed (remove)', ->
    selection = select('#fixture')
    selection.class('some-class-1 some-class-2')
    selection.classed('some-class-1', false)
    selection.class().should.equal('some-class-2')

  it "classed shoudn't mind you removing a class that doesn't exist" , ->
    selection = select('#fixture')
    selection.class('some-class-1 some-class-2')
    selection.classed('some-class-3', false)
    selection.class().should.equal('some-class-1 some-class-2')

  it "classed shoudn't mind you removing a class from a node with no class set" , ->
    selection = select('#fixture')
    selection.class(undefined)
    selection.classed('some-class-3', false)
    selection.class().should.equal('')

  it "classed should be able to add a class to a node with no class set" , ->
    selection = select('#fixture')
    selection.class(undefined)
    selection.classed('some-class-3', true)
    selection.class().should.equal('some-class-3')

  it 'classed (add) (multi-selection)', ->
    selection = select('#fixture').select('#multi').selectAll('div')
    selection.classed('some-class', true)
    selection.class().should.eql(['some-class', 'some-class'])

  it 'classed add multiple classes (multi-selection)', ->
    selection = select('#fixture').select('#multi').selectAll('div')
    selection.classed('some-class-1', true)
    selection.classed('some-class-2', true)
    selection.classed('some-class-3', true)
    selection.class().should.eql([
      'some-class-1 some-class-2 some-class-3',
      'some-class-1 some-class-2 some-class-3'
    ])

  it 'classed should not add a class if it already exists (multi-selection)', ->
    selection = select('#fixture').select('#multi').selectAll('div')
    selection.classed('some-class-1', true)
    selection.classed('some-class-2', true)
    selection.classed('some-class-1', true)
    selection.class().should.eql([
      'some-class-1 some-class-2',
      'some-class-1 some-class-2'
    ])

  it 'classed (remove) (multi-selection)', ->
    selection = select('#fixture').select('#multi').selectAll('div')
    selection.class('some-class-1 some-class-2')
    selection.classed('some-class-1', false)
    selection.class().should.eql([
      'some-class-2',
      'some-class-2'
    ])

  it "classed shoudn't mind you removing a class that doesn't exist (multi-selection)" , ->
    selection = select('#fixture').select('#multi').selectAll('div')
    selection.class('some-class-1 some-class-2')
    selection.classed('some-class-3', false)
    selection.class().should.eql([
      'some-class-1 some-class-2',
      'some-class-1 some-class-2'
    ])

  it "classed shoudn't mind you removing a class from a node with no class set (multi-selection)" , ->
    selection = select('#fixture').select('#multi').selectAll('div')
    selection.class(undefined)
    selection.classed('some-class-3', false)
    selection.class().should.eql(['', ''])

  it "classed should be able to add a class to a node with no class set (multi-selection)" , ->
    selection = select('#fixture').select('#multi').selectAll('div')
    selection.class(undefined)
    selection.classed('some-class-3', true)
    selection.class().should.eql(['some-class-3', 'some-class-3'])

  it "classed should be fine adding multiple classes in one go" , ->
    selection = select('#fixture').select('#multi').selectAll('div')
    selection.class(undefined)
    selection.classed('one two three', true)
    selection.class().should.eql(['one two three', 'one two three'])

  it "classed should be fine removing multiple classes in one go" , ->
    selection = select('#fixture').select('#multi').selectAll('div')
    selection.class(undefined)
    selection.classed('one two three', true)
    selection.class().should.eql(['one two three', 'one two three'])
    selection.classed('one three', false)
    selection.class().should.eql(['two', 'two'])

  it "classed should do nothing when removing a class that doesn't exist" , ->
    selection = select('#fixture').select('#multi').selectAll('div')
    selection.class(undefined)
    selection.classed('one two three', true)
    selection.class().should.eql(['one two three', 'one two three'])
    selection.classed('two three four', false)
    selection.class().should.eql(['one', 'one'])

  it "classed should not add a class multiple times" , ->
    selection = select('#fixture').select('#multi').selectAll('div')
    selection.class(undefined)
    selection.classed('one two three', true)
    selection.class().should.eql(['one two three', 'one two three'])
    selection.classed('one two three', true)
    selection.class().should.eql(['one two three', 'one two three'])

  it "classed should ignore extra whitespace" , ->
    selection = select('#fixture').select('#multi').selectAll('div')
    selection.class(undefined)
    selection.classed('one      two three', true)
    selection.class().should.eql(['one two three', 'one two three'])
    selection.classed('one two       three', true)
    selection.class().should.eql(['one two three', 'one two three'])

  it 'closest should work', ->
    select('#fixture').html(
      """
        <div id="closest-root" class="cr">
          <span id="child" class="ch">
            <div id="grandchild"></div>
          </span>
        </div>
      """
    )
    select('#grandchild').closest('span').class().should.equal('ch')

  it 'closest should work for grandparents', ->
    select('#fixture').html(
      """
        <div id="closest-root" class="cr">
          <span id="child" class="ch">
            <div id="grandchild"></div>
          </span>
        </div>
      """
    )
    select('#grandchild').closest('div').class().should.equal('cr')

  it 'closest should return an empty selection when there is no match', ->
    select('#fixture').html(
      """
        <div id="closest-root" class="cr">
          <span id="child" class="ch">
            <div id="grandchild"></div>
          </span>
        </div>
      """
    )
    select('#grandchild').closest('#thing-that-doesnt-exist').empty().should.equal(true)

  it 'closest should warn when you give a non string argument', ->
    util.consoleWarning = chai.spy()

    obj = {}

    select('#fixture').closest(obj)
    util.consoleWarning.should.have.been.called.with('Selection.closest was passed the wrong argument type', 'Selection.closest only accepts a string argument, you supplied:', obj)

  it 'closest should warn when you give a non string argument', ->
    select('#fixture').closest('potato').empty().should.equal(true)

  it 'closest should find by class', ->
    select('#fixture').html(
      """
        <div id="closest-root" class="cr">
          <span id="child" class="ch">
            <div id="grandchild"></div>
          </span>
        </div>
      """
    )
    select('#grandchild').closest('.cr').attr('id').should.equal('closest-root')

  it 'closest should find by id', ->
    select('#fixture').html(
      """
        <div id="closest-root" class="cr">
          <span id="child" class="ch">
            <div id="grandchild"></div>
          </span>
        </div>
      """
    )
    select('#grandchild').closest('#closest-root').class().should.equal('cr')

  it 'closest should not find a child by mistake', ->
    select('#fixture').html(
      """
        <div id="closest-root" class="cr">
          <span id="child" class="ch">
            <div id="grandchild"></div>
          </span>
        </div>
      """
    )
    select('#child').closest('#grandchild').empty().should.equal(true)

  it 'contains should return true when a single selection contains an element', ->
    select('#fixture').contains(select('#fixture').select('div').node()).should.equal(true)

  it 'contains should return false when a single selection does not contain an element', ->
    select('#multi').contains(select('#fixture').node()).should.equal(false)

  it 'contains should return true when a multi selection contains an element', ->
    select('#fixture').selectAll('div').contains(select('#fixture').select('.first.one').node()).should.equal(true)

  it 'contains should return false when a multi selection does not contain an element', ->
    select('#multi').selectAll('div').contains(select('#fixture').node()).should.equal(false)

  it 'basic event emitter registration should work', ->
    div = select.detached('div')
    called = false
    div.on 'click', (e) -> called = true
    div.node().__hx__.eventEmitter.emit('click', {})
    called.should.equal(true)

  it 'basic event emitter replacement should work', ->
    div = select.detached('div')
    called = false
    div.on('click', (e) -> called = 1)
    div.on('click', (e) -> called = 2)
    div.node().__hx__.eventEmitter.emit('click', {})
    called.should.equal(2)

  it 'basic event emitter removal should work', ->
    div = select.detached('div')
    called = false
    f = (e) -> called = 1
    div.on('click', (e) -> called = 2)
    div.on('click', f)
    div.off('click', f)
    div.node().__hx__.eventEmitter.emit('click', {})
    called.should.equal(false)

  it 'namespaced event emitter addition should work', ->
    div = select.detached('div')
    result1 = false
    div.on('click', 'my-namespace', (e) -> result1 = true)
    div.node().__hx__.eventEmitter.emit('click', {})
    result1.should.equal(true)

  it 'namespaced event emitter addition should not affect other namespaces', ->
    div = select.detached('div')
    result1 = false
    result2 = false
    div.on('click', 'my-namespace-1', (e) -> result1 = true)
    div.on('click', 'my-namespace-2', (e) -> result2 = true)
    div.node().__hx__.eventEmitter.emit('click', {})
    result1.should.equal(true)
    result2.should.equal(true)

  it 'namespaced event emitter removal should not affect other namespaces', ->
    div = select.detached('div')
    result1 = false
    result2 = false
    div.on('click', 'my-namespace-1', (e) -> result1 = true)
    div.on('click', 'my-namespace-2', (e) -> result2 = true)
    div.off('click', 'my-namespace-1')
    div.node().__hx__.eventEmitter.emit('click', {})
    result1.should.equal(false)
    result2.should.equal(true)

  it 'explicit namespaced event emitter removal should not affect other namespaces', ->
    div = select.detached('div')
    result1 = false
    result2 = false
    f = (e) -> result1 = true
    div.on('click', 'my-namespace-1', f)
    div.on('click', 'my-namespace-2', (e) -> result2 = true)
    div.off('click', 'my-namespace-1', f)
    div.node().__hx__.eventEmitter.emit('click', {})
    result1.should.equal(false)
    result2.should.equal(true)

  it 'handler removal without specifying namespace should work', ->
    div = select.detached('div')
    result1 = false
    result2 = false
    f = (e) -> result1 = true
    div.on('click', 'my-namespace-1', f)
    div.on('click', 'my-namespace-2', (e) -> result2 = true)
    div.off('click', f)
    div.node().__hx__.eventEmitter.emit('click', {})
    result1.should.equal(false)
    result2.should.equal(true)

  it 'namespaced event emitter replacement should work', ->
    div = select.detached('div')
    result1 = false
    result2 = false
    result3 = false
    div.on('click', 'my-namespace-1', (e) -> result1 = true)
    div.on('click', 'my-namespace-2', (e) -> result2 = true)
    div.on('click', 'my-namespace-1', (e) -> result3 = true)
    div.node().__hx__.eventEmitter.emit('click', {})
    result1.should.equal(false)
    result2.should.equal(true)
    result3.should.equal(true)

  it 'off with no arguments should remove all handlers', ->
    div = select.detached('div')
    result1 = false
    result2 = false
    result3 = false
    div.on('click', 'my-namespace-1', (e) -> result1 = true)
    div.on('click', 'my-namespace-2', (e) -> result2 = true)
    div.on('clack', 'my-namespace-1', ((e) -> result3 = true))
    div.off()
    div.node().__hx__.eventEmitter.emit('click', {})
    div.node().__hx__.eventEmitter.emit('clack', {})
    result1.should.equal(false)
    result2.should.equal(false)
    result3.should.equal(false)

  it 'off with event name should work', ->
    div = select.detached('div')
    result1 = false
    result2 = false
    result3 = false
    div.on('click', 'my-namespace-1', (e) -> result1 = true)
    div.on('click', 'my-namespace-2', (e) -> result2 = true)
    div.on('clack', 'my-namespace-1', ((e) -> result3 = true))
    div.off('click')
    div.node().__hx__.eventEmitter.emit('click', {})
    div.node().__hx__.eventEmitter.emit('clack', {})
    result1.should.equal(false)
    result2.should.equal(false)
    result3.should.equal(true)

  it 'off by namespace alone should work', ->
    div = select.detached('div')
    result1 = false
    result2 = false
    result3 = false
    div.on('click', 'my-namespace-1', (e) -> result1 = true)
    div.on('click', 'my-namespace-2', (e) -> result2 = true)
    div.on('clack', 'my-namespace-1', ((e) -> result3 = true))
    div.off(undefined, 'my-namespace-1')
    div.node().__hx__.eventEmitter.emit('click', {})
    div.node().__hx__.eventEmitter.emit('clack', {})
    result1.should.equal(false)
    result2.should.equal(true)
    result3.should.equal(false)

  it 'off by event name and namespace should work', ->
    div = select.detached('div')
    result1 = false
    result2 = false
    result3 = false
    div.on('click', 'my-namespace-1', (e) -> result1 = true)
    div.on('click', 'my-namespace-2', (e) -> result2 = true)
    div.on('clack', 'my-namespace-1', ((e) -> result3 = true))
    div.off('click', 'my-namespace-1')
    div.node().__hx__.eventEmitter.emit('click', {})
    div.node().__hx__.eventEmitter.emit('clack', {})
    result1.should.equal(false)
    result2.should.equal(true)
    result3.should.equal(true)
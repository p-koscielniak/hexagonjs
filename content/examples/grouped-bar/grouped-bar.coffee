
colors = hx.theme.plot.colors

xLabels = 'ABCDEFGH'.split('')

createData = ->
  for label in xLabels
    x: label
    y: Math.random()*0.5+0.05

graph = new hx.Graph('#graph')
axis = graph.addAxis('discrete', 'linear')

axis.xDiscreteLabels = xLabels
axis.xFormatter = (d) -> d
axis.xTitle = "category"
axis.yTitle = "value"
axis.yMin = 0
axis.yScalePaddingMax = 0.1

series = for i in [0..4]
  series = axis.addSeries('bar', 'Bar Series ' + (i+1))
  series.setData(createData())
  series.color = hx.cycle(colors, i)

graph.render()

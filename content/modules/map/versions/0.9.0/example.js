// create an empty map
var map = new hx.Map;

map.set('a', 1);
map.set('b', 2);
map.set('c', 3);

// will log 3
console.log(map.size);

// remove an item from the map by key
map.delete('a');

// will log [2, 3]
console.log(map.values());

// will log [['b', 2], ['c', 3]]
console.log(map.entries());

// will log ['b', 'c']
console.log(map.keys());

// removes everything from the map
map.clear();

// create a map prefilled with some values
map = new hx.Map([['a', 1], ['b', 1], ['c', 2], ['d', 3], ['e', 3], ['f', 3]]);

// will log true
console.log(map.has('d'));

// will log false
console.log(map.has('g'));

// will log 3
console.log(map.get('f'));

// this will log each key and value in the map
map.forEach(function(k, v) {
  console.log(k + ': ' + v)
});
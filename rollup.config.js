// import commonjs from 'rollup-plugin-commonjs'
import coffee from 'rollup-plugin-coffee-script'
import includePaths from 'rollup-plugin-includepaths'
import buble from 'rollup-plugin-buble'
import progress from 'rollup-plugin-progress'

const includePathOptions = {
  include: {},
  paths: [__dirname],
  external: [],
  extensions: ['.js', '.coffee']
}

export default {
  entry: 'modules/hexagon.js',
  dest: 'target/hexagon.js',
  format: 'iife',
  moduleName: 'hx',
  plugins: [
    buble({
      exclude: ['**/*.coffee']
    }),
    coffee({
      exclude: ['**/*.js']
    }),
    includePaths(includePathOptions),
    progress()
  ]
}

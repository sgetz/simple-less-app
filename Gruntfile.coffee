less = require('less')
fs = require 'fs'
path = require 'path'
module.exports = (grunt) ->

  require('load-grunt-tasks')(grunt)

  srcDir = "src"
  tempDir = ".tmp"
  bowerDir = "bower_componets"

  #Less Config
  # less =
  #   dev:
  #     options:
  #       paths: ["#{srcDir}", "#{bowerDir}"]
  #     files: 
  #       ".tmp/styles.css": "#{srcDir}/styles.less" #convert to .tmp var
  #Copy Config
  copy =
    dev_main:
      files: [
        {
          expand: true
          cwd: "#{srcDir}"
          src: ['**/*', '!**/*.coffee', '!**/*.less']
          dest: "#{tempDir}"
        }
      ]
  ###Coffee Script Config###
  coffee =
    dev:
      expand: true
      cwd: "#{srcDir}"
      src: ['**/*.coffee']
      dest: "#{tempDir}"
      ext: '.js'
      options:
        bare: true

  ###Watch Config###
  watch =
    options:
      livereload: true
    dev_main:
      files: ["#{srcDir}/**/*", "!#{srcDir}/**/*.coffee", "!#{srcDir}/**/*.less"]
      tasks: 'copy:dev_main'
    dev_less:
      files: ["#{srcDir}/**/*.less"]
      tasks: ['lessTwo']
    dev_coffee:
      cwd: "#{srcDir}"
      files: ["#{srcDir}/**/*.coffee"]
      tasks: ['coffee:dev']

  ###Connect Server Config###
  connect =
    dev_server:
      options:
        port: 8000
        hostname: '0.0.0.0'
        base: ["#{tempDir}", '.']
        keepalive: false
        middleware: (connect, options) ->
          middlewares = []
          for basePath in options.base
            middlewares.push connect.static(basePath)
            middlewares.push connect.directory(basePath)
          middlewares

  lessRenderCb = (err, css) ->
    grunt.log.writeln "writing css content to file"
    if not err
      outCssFilePath = path.join(__dirname, tempDir, 'styles.css')
      fs.writeFileSync(outCssFilePath, css.css, {encoding:'utf8'})
    else 
      grunt.log.writeln "#{err}"
    return null

  less2TaskFn =  -> 
    grunt.log.writeln "running less2 compile task"
    stylesLessFIlePath = path.join(__dirname, srcDir, 'styles.less')
    stylesLessFileContent = fs.readFileSync( stylesLessFIlePath, {encoding:"utf8"})
    lessRenderConfig = 
      paths: path.join(__dirname, srcDir)
      filename: path.join(__dirname, srcDir, 'styles.less')
    
    less.render(stylesLessFileContent, lessRenderConfig, lessRenderCb)

    grunt.log.writeln "exiting less2TaskFn"

  gruntConfigObj = {
    #less
    copy
    coffee
    watch
    connect
  }
  grunt.initConfig gruntConfigObj
  grunt.registerTask('lessTwo', 'lessTwo custom compile task', less2TaskFn)
  grunt.registerTask( 'default', "coffee lessTwo copy connect watch".split(/,?\s+/))
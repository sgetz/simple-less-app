module.exports = (grunt) ->

  require('load-grunt-tasks')(grunt)

  srcDir = "src"
  tempDir = ".tmp"
  bowerDir = "bower_componets"

  #Less Config
  less =
    dev:
      options:
        paths: ["#{srcDir}", "#{bowerDir}"]
      files: 
        ".tmp/styles.css": "#{srcDir}/styles.less" #convert to .tmp var
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
      tasks: ['less:dev']
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

  gruntConfigObj = {
    less
    copy
    coffee
    watch
    connect
  }
  console.log gruntConfigObj
  grunt.initConfig gruntConfigObj
  grunt.registerTask( 'default', "coffee less copy connect watch".split(/,?\s+/))
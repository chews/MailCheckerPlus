module.exports =
  build:
    coffee:
      src: 'src/'
      dest: 'lib/'
    jade:
      args: '-D -c -P'
      src: 'src/templates/'
      dest: 'lib/templates/'

module.exports =

  config:
    fontFamily:
      description: 'Experimental: set to gtk-3 to load the font settings from ~/.config/gtk-3.0/settings.ini'
      type: 'string'
      default: 'Cantarell'
      enum: [
        'Cantarell',
        'Sans Serif',
        'DejaVu Sans',
        'Oxygen-Sans',
        'Droid Sans',
        'gtk-3'
      ]
    fontSize:
      description: 'Set to -1 for auto'
      type: 'number'
      default: '-1'
    iconTheme:
      type: 'string'
      default: 'No Icons'
      enum: [
        'No Icons',
        'Octicons',
        # 'Adwaita',
        # 'Breeze'
      ]

  activate: (state) ->
    # code in separate file so deferral keeps activation time down
    atom.themes.onDidChangeActiveThemes ->
      Config = require './config'
      Config.apply()

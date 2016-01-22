initCount = 0
themeConfig = null

module.exports =

  config:
    # theme:
    #   title: 'Theme'
    #   description: 'Use the dark or light color theme. Auto will guess based on your syntax theme.'
    #   type: 'string'
    #   default: 'auto'
    #   enum: [
    #     'auto',
    #     'light',
    #     'dark',
    #   ]
    fontFamily:
      title: 'Font Family'
      description: 'Experimental: set to gtk-3 to load the font settings from ~/.config/gtk-3.0/settings.ini'
      type: 'string'
      default: 'Ubuntu'
      enum: [
        'Ubuntu',
        'Cantarell',
        'Sans Serif',
        'DejaVu Sans',
        'Oxygen-Sans',
        'Droid Sans',
        'gtk-3'
      ]
    fontSize:
      title: 'Font Size'
      description: 'Set to -1 for auto'
      type: 'number'
      default: '-1'
    iconTheme:
      title: 'Icon Theme'
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
    initCount++
    _initCount = initCount
    setTimeout ->
      if _initCount isnt initCount then return
      ThemeConfig = require './config'
      console.log("Loading ambiance-pro-ui...")
      themeConfig = new ThemeConfig()
      themeConfig.init()
    , 10
  deactivate: (state) ->
    themeConfig?.destroy()
    themeConfig = null

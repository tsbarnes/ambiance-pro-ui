fs = require 'fs'
path = require 'path'
ini = require 'ini'

module.exports =

  apply: ->

    atomWorkspace = document.querySelector('atom-workspace')

    atomWorkspace.style.fontSize = ""

    isManualFontSize = (fontSize) -> fontSize? and fontSize isnt -1

    updateFont = () ->
      font = atom.config.get('adwaita-pro-ui.fontFamily')
      if font is 'gtk-3'
        loadGtkFont()
      else
        atomWorkspace.style.fontFamily = font

    updateFontSize = () ->
      size = atom.config.get('adwaita-pro-ui.fontSize')
      if isManualFontSize(size)
        atomWorkspace.style.fontSize = "#{size}px"
      else if atom.config.get('adwaita-pro-ui.fontFamily') is 'gtk-3'
        loadGtkFont()
      else
        atomWorkspace.style.fontSize = ""

    updateIcons = () ->
      iconTheme = atom.config.get('adwaita-pro-ui.iconTheme') or 'No Icons'
      atomWorkspace.setAttribute('data-adwaita-pro-ui-icon-theme', iconTheme.toLowerCase().replace(/\ /g, '-'))

    loadGtkFont = () ->
      fs.readFile path.join(process.env.HOME, '.config/gtk-3.0/settings.ini'), {encoding: 'utf-8'}, (err, raw) ->
        return console.error(err.stack or err) if err
        gtk_settings = ini.parse(raw)
        [fontFamily, fontSize] = (gtk_settings?.Settings?['gtk-font-name'] or '').split('  ')
        if fontFamily
          atomWorkspace.style.fontFamily = fontFamily
        if fontSize and not isManualFontSize(atom.config.get('adwaita-pro-ui.fontSize'))
          atomWorkspace.style.fontSize = "#{fontSize}px"


    reloadTheme = () ->
      # borrowed from atom core: src/theme-manager.coffee
      atom.themes.removeActiveThemeClasses()
      atom.themes.unwatchUserStylesheet()
      atom.themes.packageManager.deactivatePackage("adwaita-pro-ui")
      atom.themes.refreshLessCache()
      atom.themes.packageManager.activatePackage("adwaita-pro-ui").then ->
        atom.themes.addActiveThemeClasses()
        atom.themes.loadUserStylesheet()
        atom.themes.refreshLessCache()
        atom.themes.reloadBaseStylesheets()
        atom.themes.emitter.emit 'did-change-active-themes'

    setTheme = () ->
      themeFile = path.join(__dirname, "../styles/gtk_style.less")
      theme = atom.config.get('adwaita-pro-ui.theme') or 'auto'
      fs.readFile themeFile, {encoding: "utf8"}, (err, data) ->
        if err then return console.log(err)
        currentTheme = /^@gtk-style: (auto|dark|light);/.exec(data)[1];
        if theme isnt currentTheme
          fs.writeFile themeFile, "@gtk-style: #{theme};\n", (err) ->
            if err then return console.log(err)
            reloadTheme()



    # run when atom is ready
    updateFont()
    updateFontSize()
    updateIcons()
    setTheme()

    # run when configs change

    atom.config.onDidChange 'adwaita-pro-ui.theme', setTheme
    atom.config.onDidChange 'adwaita-pro-ui.fontFamily', updateFont
    atom.config.onDidChange 'adwaita-pro-ui.fontSize', updateFontSize
    atom.config.onDidChange 'adwaita-pro-ui.iconTheme', updateIcons

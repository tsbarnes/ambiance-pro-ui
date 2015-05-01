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
      console.log font
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


    # run when atom is ready
    updateFont()
    updateFontSize()
    updateIcons()

    # run when configs change

    atom.config.onDidChange 'adwaita-pro-ui.fontFamily', updateFont
    atom.config.onDidChange 'adwaita-pro-ui.fontSize', updateFontSize
    atom.config.onDidChange 'adwaita-pro-ui.iconTheme', updateIcons

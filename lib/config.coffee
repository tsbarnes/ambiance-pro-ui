fs = require 'fs'
path = require 'path'
ini = require 'ini'

module.exports =

  apply: () ->

    atomWorkspace = document.querySelector('atom-workspace')


    atomWorkspace.style.fontSize = ""
    # functions

    isManualFontSize = (fontSize) -> fontSize? and fontSize isnt -1

    applyFont = (font) ->
      if font is 'gtk-3'
        loadGtkFont()
      else
        atomWorkspace.style.fontFamily = font

    applyFontSize = (size) ->
      if isManualFontSize(size)
        atomWorkspace.style.fontSize = "#{size}px"
      else if atom.config.get('adwaita-pro-ui.fontFamily') is 'gtk-3'
        loadGtkFont()
      else
        atomWorkspace.style.fontSize = ""

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
    applyFont(atom.config.get('adwaita-pro-ui.fontFamily'))
    applyFontSize(atom.config.get('adwaita-pro-ui.fontSize'))

    # run when configs change

    atom.config.onDidChange 'adwaita-pro-ui.fontFamily', ->
      applyFont(atom.config.get('adwaita-pro-ui.fontFamily'))

    atom.config.onDidChange 'adwaita-pro-ui.fontSize', ->
      applyFontSize(atom.config.get('adwaita-pro-ui.fontSize'))

fs = require 'fs'
path = require 'path'
ini = require 'ini'

isStartup = true

module.exports =
class ThemeConfig
  constructor: () ->
    @startup = true

    @atomWorkspace = document.querySelector('atom-workspace')
    @atomWorkspace.style.fontSize = ""

  isManualFontSize = (fontSize) -> fontSize? and fontSize isnt -1

  updateFont: () =>
    font = atom.config.get('ambiance-pro-ui.fontFamily')
    if font is 'gtk-3'
      @loadGtkFont()
    else
      @atomWorkspace.style.fontFamily = font

  updateFontSize: () =>
    size = atom.config.get('ambiance-pro-ui.fontSize')
    if isManualFontSize(size)
      @atomWorkspace.style.fontSize = "#{size}px"
    else if atom.config.get('ambiance-pro-ui.fontFamily') is 'gtk-3'
      @loadGtkFont()
    else
      @atomWorkspace.style.fontSize = ""

  updateIcons: () =>
    iconTheme = atom.config.get('ambiance-pro-ui.iconTheme') or 'No Icons'
    @atomWorkspace.setAttribute('data-ambiance-pro-ui-icon-theme', iconTheme.toLowerCase().replace(/\ /g, '-'))

  loadGtkFont: () ->
    fs.readFile path.join(process.env.HOME, '.config/gtk-3.0/settings.ini'), {encoding: 'utf-8'}, (err, raw) =>
      return console.error(err.stack or err) if err
      gtk_settings = ini.parse(raw)
      [fontFamily, fontSize] = (gtk_settings?.Settings?['gtk-font-name'] or '').split('  ')
      if fontFamily
        @atomWorkspace.style.fontFamily = fontFamily
      if fontSize and not isManualFontSize(atom.config.get('ambiance-pro-ui.fontSize'))
        @atomWorkspace.style.fontSize = "#{fontSize}px"
        atom.themes.emitter.emit 'did-change-active-themes'

  @reloadTheme = reloadTheme = () -> new Promise (resolve, reject) ->
    # borrowed from atom core: src/theme-manager.coffee
    atom.themes.removeActiveThemeClasses()
    atom.themes.unwatchUserStylesheet()
    atom.themes.packageManager.deactivatePackage("ambiance-pro-ui")
    atom.themes.refreshLessCache()
    atom.themes.packageManager.activatePackage("ambiance-pro-ui").then ->
      atom.themes.addActiveThemeClasses()
      atom.themes.loadUserStylesheet()
      atom.themes.refreshLessCache()
      atom.themes.reloadBaseStylesheets()
      atom.themes.emitter.emit 'did-change-active-themes'
      resolve()
    , reject


  # setTheme: () => new Promise (resolve, reject) =>
  #   themeFile = path.join(__dirname, "../styles/gtk_style.less")
  #   theme = atom.config.get('ambiance-pro-ui.theme') or 'auto'
  #   fs.readFile themeFile, {encoding: "utf8"}, (err, data) =>
  #     if err then return reject(err)
  #     currentTheme = /^@gtk-style: (auto|dark|light);/.exec(data)[1]
  #     if theme isnt currentTheme
  #       fs.writeFile themeFile, "@gtk-style: #{theme};\n", (err) ->
  #         if err then return reject(err)
  #         reloadTheme().then (-> resolve(false)), reject
  #     else if isStartup and theme in ['dark', 'auto']
  #       isStartup = false
  #       return resolve(true)
  #     return resolve(false)

  init: () ->
    @updateFontDisposable = atom.config.observe 'ambiance-pro-ui.fontFamily', @updateFont
    @updateFontSizeDisposable = atom.config.observe 'ambiance-pro-ui.fontSize', @updateFontSize
    @updateIconsDisposable = atom.config.observe 'ambiance-pro-ui.iconTheme', @updateIcons
    # @setThemeDisposable = atom.config.onDidChange 'ambiance-pro-ui.theme', @setTheme

    @onDidChangeActiveThemesDisposable = atom.themes.onDidChangeActiveThemes @refresh
    # return @setTheme()

  destroy: () ->
    @updateFontDisposable.dispose()
    @updateFontSizeDisposable.dispose()
    @updateIconsDisposable.dispose()
    # @setThemeDisposable.dispose()
    @onDidChangeActiveThemesDisposable.dispose()

  refresh: () =>
    if @isRefreshing then return
    @isRefreshing = true
    @updateFont()
    @updateFontSize()
    @updateIcons()
    @isRefreshing = false

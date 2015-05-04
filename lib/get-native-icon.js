#!/usr/bin/env seed
// could be used with gjs, if no arguments are needed
/*global Seed */
// usage: ./get-native-icon.js [filename]
var Gtk = imports.gi.Gtk;
var Gio = imports.gi.Gio;
// Gtk.init(null, null);
Gtk.init(Seed.argv);
var contentType = Gio.content_type_guess(Seed.argv[2], null);
var iconTheme = Gtk.IconTheme.get_default();
if (contentType) {
  var themedIcon = Gio.content_type_get_symbolic_icon(contentType);
  var iconNames = themedIcon.names;
  for (var i = 0, iconName, icon, filename; iconName = iconNames[i], i < iconNames.length; i++) {
    if ((icon = iconTheme.lookup_icon(iconName, 16, 0)) && (filename = icon.get_filename())) {
      print(filename);
      break;
    }
  }
}

// For actual native linux icon support in atom
// In a separate package
// Using this basic idea of this file
// Running as a sidecar process
// This would register itself on d-bus
// atom would connect to it
// The sidecar would reveal a port on localhost
// atom would connect to the server
// the server would use libsoup
// atom would request mimetypes for files
// and this sidecar would reveal the icon that should be used for each one.
//
// maybe it could all use d-bus instead of running an http server with libsoup

// or just convert the -symbolic svg icons to an icon font, and use those

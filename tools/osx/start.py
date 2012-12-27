#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, re, subprocess

macos   = os.path.dirname(os.path.abspath(__file__))
lib     = macos + '/lib'
etc     = macos + '/etc'
exe     = macos + '/rawtherapee'

os.environ['DYLD_LIBRARY_PATH']         = lib
os.environ['GDK_PIXBUF_MODULE_FILE']    = etc + '/gtk-2.0/gdk-pixbuf.loaders'
os.environ['GTK_DATA_DIRS']             = macos
os.environ['GTK_DATA_PREFIX']           = macos
os.environ['GTK_EXE_PREFIX']            = macos
os.environ['GTK_IM_MODULE_FILE']        = etc + '/gtk-2.0/gtk.immodules'
os.environ['GTK_PATH']                  = macos
os.environ['PANGO_RC_FILE']             = etc + '/pango/pangorc'
os.environ['XDG_DATA_DIRS']             = macos + '/share'

open('/tmp/rawtherapee_pango.modules', 'w').write(re.sub('@executable_path', macos, open(etc + '/pango/pango.modules').read()))

subprocess.Popen(exe)

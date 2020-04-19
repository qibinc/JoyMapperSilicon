from __future__ import unicode_literals

import biplist
import os.path

app = defines.get('app', './dmg/JoyKeyMapper.app')
appname = os.path.basename(app)

# Basics

format = defines.get('format', 'UDZO')
size = defines.get('size', None)
files = [ app ]
symlinks = { 'Applications': '/Applications' }

icon_locations = {
    appname:        (150, 149),
    'Applications': (456, 148)
}

# Window configuration

background = './resources/background.png'

show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False
sidebar_width = 180

window_rect = ((322, 331), (602, 341))

defaullt_view = 'icon_view'

# Icon view configuration

arrange_by = None
grid_offset = (0, 0)
grid_spacing = 100
scrolll_position = (0, 0)
label_pos = 'bottom'
text_size = 12
icon_size = 164


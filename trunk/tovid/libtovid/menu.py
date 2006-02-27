#! /usr/bin/env python
# menu.py

__doc__ = \
"""Module for generating Menu elements for a tovid project.

Conceptual steps in generating a menu:

    - convert/generate background (image or video)
    - convert audio
    - generate link content (titles and/or thumbnails)
    - generate link navigation (spumux)
    - composite links/thumbnails over background
    - convert image sequence into video stream
    - mux video/audio streams
    - mux link highlight/select subtitles

Interfaces:

    - Convert video to image sequence
    - Convert image sequence to video
    - Composite two or more image sequences together
    - Alter an image sequence (decoration, labeling, etc.)

Data structures:

    - Image sequence
        - Name/title
        - Resolution
        - Filesystem location (directory name)
    - Thumbnail (a specialized image sequence)


Desired end result:

    - Generalized video stream combination interface
        - For streaming multiple videos into a single video
        - For applying effects and visual widgets to a video
        - For adding customized subtitle streams
"""

import string
import sys
import os
import glob

import libtovid
from libtovid.option import OptionDef
from libtovid.MenuPlugins import *
from libtovid.element import Element
from libtovid.log import Log

log = Log('menu.py')

class Menu(Element):
    """A Menu element with associated options"""
    optiondefs = {
        'format': OptionDef('format', 'vcd|svcd|dvd', 'dvd',
            """Generate a menu compliant with the specified disc format"""),
        'tvsys': OptionDef('tvsys', 'pal|ntsc', 'ntsc',
            """Make the menu for the specified TV system"""),
        'titles': OptionDef('titles', '"TITLE" [, "TITLE"]', [],
            """Comma-separated list of quoted titles; these are the titles that
            will be displayed (and linked) from the menu."""),
        'background': OptionDef('background', 'IMAGE', None,
            """Use IMAGE (in most any graphic format) as a background."""),
        'audio': OptionDef('audio', 'AUDIOFILE', None,
            """Use AUDIOFILE for background music while the menu plays."""),
        'font':
            OptionDef('font', 'FONTNAME', 'Helvetica',
            """Use FONTNAME for the menu text."""),
        'fontsize':
            OptionDef('fontsize', 'NUM', '24',
            """Use a font size of NUM pixels."""),
        'align':
            OptionDef('align', 'west|north|east|south|center', 'northwest'),
        'textcolor':
            OptionDef('textcolor', 'COLOR', 'white',
            """Color of menu text. COLOR may be a hexadecimal triplet (#RRGGBB or
            #RGB), or a color name from 'convert -list color."""),
        'highlightcolor':
            OptionDef('highlightcolor', 'COLOR', 'red',
            """Color of menu highlights."""),
        'selectcolor':
            OptionDef('selectcolor', 'COLOR', 'green',
            """Color of menu selections."""),
        'out':
            OptionDef('out', 'FILE', None),
        # Thumbnail menus and effects
        'choices':
            OptionDef('choices', '[list|thumbnails]', 'list',
                """Display links as a list of titles, or as a grid of labeled
                thumbnail videos."""),
        'border':
            OptionDef('border', 'NUM', '0',
                """Add a border of NUM pixels around thumbnails."""),
        'effects':
            OptionDef('effects', 'shadow|round|glass [, ...]', [],
                """Add the listed effects to the thumbnails.""")
    }

    def __init__(self, name='Untitled Menu'):
        Element.__init__(self, 'Menu', name, self.optiondefs)

    def generate(self):
        """Generate the element, and return the filename of the
        resulting menu."""
        # TODO: Raise exceptions

        # Generate a menu of the appropriate format
        if self.get('format') == 'dvd':
            log.info('Generating a DVD menu with text titles...')
            #foo = ThumbMenu(menu)
            foo = TextMenu(self)
            foo.run()
        elif self.get('format') in ['vcd', 'svcd']:
            log.error('VCD and SVCD menus are not supported yet.')
            pass

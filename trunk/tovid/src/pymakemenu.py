#! /usr/bin/env python

import sys, libtovid
from libtovid import Menu, Parser, Project

if __name__ == '__main__':
    """Parse the provided command-line arguments as a Menu element."""

    # If no arguments were provided, print usage notes
    if len(sys.argv) == 1:
        print "Please provide some arguments."
        sys.exit()
        
    # If a TDL file name was provided, parse and generate Menus in it
    elif len(sys.argv) == 3 and sys.argv[1] == '-tdl':
        print "Generating menus from TDL: '%s'" % sys.argv[2]
        proj = Project.Project()
        proj.load_file(sys.argv[2])

        for menu in proj.get_elements('Menu'):
            print "Generating menu: '%s'" % menu.name
            libtovid.Menu.generate(menu)

    else:
        print "pymakemenu"
        # Insert a dummy element/name declaration
        sys.argv.insert(0, 'Menu')
        sys.argv.insert(1, 'UNTITLED_MENU')
        print "Converted command-line options to a TDL element declaration:"
        print sys.argv

        # TODO: Fix this dumb redundancy in naming (same for Project.Project
        # above)
        menu = Parser.Parser.parse_args(sys.argv)

        print "Parsed menu element:"
        print menu.tdl_string()

        print "Generating menu..."
        libtovid.Menu.generate(menu)

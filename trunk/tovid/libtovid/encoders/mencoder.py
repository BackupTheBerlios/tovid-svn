#! /usr/bin/env python
# mencoder.py

__all__ = ['encode']

import logging

from libtovid.cli import Script

log = logging.getLogger('mencoder.py')

def encode(infile, options):
    """Return a Script to encode infile (a MultimediaFile) with mencoder,
    using the given options."""
    cmd = 'mencoder'
    cmd += ' "%s" -o "%s"' % (infile.filename, options['out'])
    cmd += ' -oac lavc -ovc lavc -of mpeg'
    # Format
    if options['format'] in ['vcd', 'svcd']:
        cmd += ' -mpegopts format=x%s' % options['format']
    else:
        cmd += ' -mpegopts format=dvd'
    
    # Audio settings
    # Adjust sampling rate
    # TODO: Don't resample unless needed
    cmd += ' -srate %s' % options['samprate']
    cmd += ' -af lavcresample=%s' % options['samprate']

    # Video codec
    if options['format'] == 'vcd':
        lavcopts = 'vcodec=mpeg1video'
    else:
        lavcopts = 'vcodec=mpeg2video'
    # Audio codec
    if options['format'] in ['vcd', 'svcd']:
        lavcopts += ':acodec=mp2'
    else:
        lavcopts += ':acodec=ac3'
    lavcopts += ':abitrate=%s:vbitrate=%s' % \
            (options['abitrate'], options['vbitrate'])
    # Maximum video bitrate
    lavcopts += ':vrc_maxrate=%s' % options['vbitrate']
    if options['format'] == 'vcd':
        lavcopts += ':vrc_buf_size=327'
    elif options['format'] == 'svcd':
        lavcopts += ':vrc_buf_size=917'
    else:
        lavcopts += ':vrc_buf_size=1835'
    # Set appropriate target aspect
    if options['widescreen']:
        lavcopts += ':aspect=16/9'
    else:
        lavcopts += ':aspect=4/3'
    # Put all lavcopts together
    cmd += ' -lavcopts %s' % lavcopts

    # FPS
    if options['tvsys'] == 'pal':
        cmd += ' -ofps 25/1'
    elif options['tvsys'] == 'ntsc':
        cmd += ' -ofps 30000/1001' # ~= 29.97

    # Scale/expand to fit target frame
    if options['scale']:
        vfilter = 'scale=%s:%s' % options['scale']
        # Expand is not done unless also scaling
        if options['expand']:
            vfilter += ',expand=%s:%s' % options['expand']
        cmd += ' -vf ' + vfilter

    # Create the Script, and add the single command to it
    script = Script('mencoder_encode')
    script.append(cmd)
    script.run()
    return script

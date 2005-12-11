# -* sh *-
ME="[tovid]:"
. tovid-init

# tovid
# ==============
# Convert any video/audio stream that mplayer can play
# into VCD, SVCD, or DVD-compatible Mpeg output file.
# Run this script without any options to see usage information.
#
# Project homepage: http://tovid.sourceforge.net/
#
# This software is licensed under the GNU General Public License.
# For the full text of the GNU GPL, see:
#
#   http://www.gnu.org/copyleft/gpl.html
#
# No guarantees of any kind are associated with use of this software.

# ******************************************************************************
# ******************************************************************************
#
#
# DEFAULTS AND GLOBALS
#
#
# ******************************************************************************
# ******************************************************************************

# Script name and usage notes

SCRIPT_NAME=`cat << EOF
--------------------------------
tovid video conversion script
Version $TOVID_VERSION
http://tovid.sourceforge.net/
--------------------------------
EOF`

USAGE=`cat << EOF
Usage: tovid [OPTIONS] -in {input file} -out {output prefix}

OPTIONS may be any of the following:

    -v, -version    Prints tovid version number only

Television standards:
    -ntsc           NTSC format video (USA, Americas) (default)
    -ntscfilm       NTSC-film format video
    -pal            PAL format video (Europe and others)

Formats:

  Standard formats, should be playable in most DVD players:
    -dvd            (720x480 NTSC, 720x576 PAL) DVD-compatible output (default)
    -half-dvd       (352x480 NTSC, 352x576 PAL) Half-D1-compatible output
    -svcd           (480x480 NTSC, 480x576 PAL) Super VideoCD-compatible output
    -dvd-vcd        (352x240 NTSC, 352x288 PAL) VCD-on-DVD output
    -vcd            (352x240 NTSC, 352x288 PAL) VideoCD-compatible output

  Non-standard formats, playable in some DVD players:
    -kvcdx3/-kvcd   (528x480 NTSC, 520x576 PAL) KVCDx3 long-playing VCD
    -kvcdx3a/-ksvcd (544x480 NTSC, 544x576 PAL) KVCDx3A long-playing VCD
    -kdvd           (720x480 NTSC, 720x576 PAL) KDVD long-playing DVD

Other options:
  -config FILE      Include command-line options contained in FILE
  -overwrite        Overwrite any existing output files with the specified name
  -force            Force encoding, even if the existing file is already compliant
  -version          Print out the tovid version number and exit
  -help             Print out all usage information, including advanced options

Example: Convert HomeMovie.avi to DVD widescreen format, output in HomeMovie.mpg:
  tovid -dvd -wide -in HomeMovie.avi -out HomeMovie

You may use a full URI as the input file (i.e., "http://foo.com/video.avi"),
although this feature is still experimental.

Use 'tovid -help' to see advanced options.
EOF`

ADVANCED_USAGE=`cat << EOF

Advanced options
----------------

Aspect ratios:

    tovid automatically determines aspect ratio of the input video by
    playing it in mplayer. If your video plays with correct aspect in
    mplayer, you should not need to override the default tovid behavior.

    If mplayer does not play your video with correct aspect, you may
    provide an explicit aspect ratio in one of several ways:

        -full           Same as -aspect 4:3
        -wide           Same as -aspect 16:9
        -panavision     Same as -aspect 235:100
        -aspect WIDTH:HEIGHT
            Custom aspect, where WIDTH and HEIGHT are integers.

    NOTE: This is the INPUT aspect ratio. tovid chooses an optimal
    output aspect ratio for the selected disc format (VCD, DVD, etc.)
    and does the appropriate letterboxing or anamorphic scaling.

Video adjustment:

  -quality NUM (EXPERIMENTAL. Default is 8)
        Desired output quality, on a scale of 1 to 10, with 10
        giving the best quality at the expense of a larger
        output file. Output size can vary by approximately a
        factor of 4 (that is, -quality 1 output can be 25%
        the size of -quality 10 output). Your results may vary.
        
        At present, this option affects both output
        bitrate and quantization (but may, in the future, affect
        other quality/size-related attributes). Use -vbitrate
        if you want to explicitly provide a maximium bitrate.

  -vbitrate NUM
        Maximum bitrate to use for video (in kbits/sec). Must be
        within allowable limits for the given format. Overrides
        default values.
  -interlaced (EXPERIMENTAL)
        Do interlaced encoding of the input video. Use this option if
        your video is interlaced, and you want to preserve as much
        picture quality as possible. Ignored for VCD.
  -deinterlace
        Remove interlacing from the source video. Use this if you want
        to produce progressive output video. Note: the currently-used
        deinterlacing method results in significant loss of vertical
        resolution, due to averaging or blending. Use the -interlaced
        option for better results.
  -subtitles FILE
        Get subtitles from FILE and encode them into the video.
        WARNING: This hard-codes the subtitles into the video, and you
        cannot turn them off while viewing the video. By default, no
        subtitles are loaded. If your video is already compliant with the
        chosen output format, it will be re-encoded to include the subtitles.
  -type {live|animation|bw}
        Optimize video encoding for different kinds of video. Use
        'live' (default) for live-action video, use 'animation' for
        cartoons or anime, and 'bw' for black-and-white video.
        This option currently only has an effect with KVCD/KSVCD
        output formats; other formats may support this in the future.
  -safe PERCENT
        Fit the video within a safe area defined by PERCENT. For example,
        "-safe 90%" will scale the video to 90% of the width/height of
        the output resolution, and pad the edges with a black border. Use
        this if some of the picture is cut off when played on your TV.
        The percent sign is optional.
  -filters {none,denoise,contrast,all} (default none)
        Apply post-processing filters to enhance the video. If your input
        video is very high quality, use 'none'. If your input video is grainy,
        use 'denoise'; if it looks washed out or faded, use 'contrast'. You
        can use multiple filters separated by commas. To apply all filters,
        use 'all'.
  -fps RATIO
        Force input video to be interpreted as [NUM] frames per second.
        May be necessary for some ASF, MOV, or other videos. NUM
        should be an integer ratio such as "24000:1001" (23.976fps),
        "30000:1001" (29.97fps), or "25:1" (25fps). This option is
        temporary, and may disappear in future releases.

Audio adjustment:

  -normalize
        Normalize the volume of the audio. Useful if the audio is too
        quiet or too loud, or you want to make volume consistent for
        a bunch of videos.
  -abitrate NUM
        Maximum bitrate to use for audio (in kbits/sec). Must be within
        allowable limits for the given format. Ignored for VCD.
        Default is 224. 

Other options:

  -debug             
        Print extra debugging information to the log file. Useful in
        diagnosing problems if they occur. This option also leaves
        the log file (with a .log extension) in the directory after
        encoding finishes.
  -priority {low|medium|high}
        Sets the main encoding process to the given priority. With
        high priority, it may take other programs longer to load
        and respond. With lower priority, other programs will be
        more responsive, but encoding may take 30-40% longer.
        The default is high priority.
  -discsize NUM
        This sets the desired target DVD/CD-R size in MB (10^6). Default
        is 700 for CD, 4500 for DVD. Use higher values at your own risk.
        Use 650 or lower if you plan to burn to smaller-capacity CDs.
  -parallel
        Will perform encode/rip processes in parallel using named
        pipes. Maximizes CPU utilization and minimizes disk usage.
  -update SECS
        Print status updates at intervals of SECS seconds. This affects
        how regularly the progress-meter is updated. The default is once
        per second
  -mplayeropts "OPTIONS"
        Append OPTIONS to the mplayer command run during video encoding.
        Use this if you want to add specific video filters (documented in
        the mplayer manual page). Overriding some options will cause
        encoding to fail, so use this with caution!
  -ffmpeg (EXPERIMENTAL)
        Use ffmpeg for video encoding, instead of mplayer/mpeg2enc.
        Encoding will be noticeably faster; (S)VCD and DVD are supported,
        but KVCD/KDVD is not fully supported yet.
  -nofifo (EXPERIMENTAL)
        Do not use a FIFO pipe for video encoding. If you are getting
        "Broken pipe" errors with normal encoding, try this option.
        WARNING: This uses lots of disk space (about 2 GB per minute of
        video).

EOF`

# All other defaults

SEPARATOR="========================================================="

# Config file
CONFIG_FILE=$HOME/.tovid/tovid.config
# Not currently reading in config file
READING_CONFIG=false

# Video defaults

# Don't use ffmpeg
USE_FFMPEG=false

# NTSC DVD full-screen by default
TGT_RES="DVD"
TVSYS="NTSC"
BASETVSYS="NTSC"
ASPECT_RATIO=""
V_ASPECT_WIDTH=""
# 100% safe area
SAFE_AREA=100
# Don't use yuvdenoise
YUVDENOISE=""
# No vidfilter yet
VID_FILTER=""
VF_PRE=""
VF_POST=""
# High priority encoding
PRIORITY="nice -n 0"
# No deinterlacing
DEINTERLACE=false
# Don't do interlaced encoding
INTERLACED=false
ILACE_FIELD_ORDER=""
YUV4MPEG_ILACE=""
# Don't do any filtering by default
DO_DENOISE=false
DO_CONTRAST=false
DO_DEBLOCK=false
# Use fifo for video encoding?
USE_FIFO=:

# Audio defaults
AUD_SUF="ac3"
VID_SUF="m2v"
# Audio .wav output filename
AUDIO_WAV="audiodump.wav"
# Audio bitrate (for ac3 or mp2)
AUD_BITRATE="224"
# Don't generate an empty audio stream
GENERATE_AUDIO=false


# Assume audio and video need to be re-encoded
AUDIO_OK=false
VIDEO_OK=false


# Do not overwrite existing files
OVERWRITE=false
# Print minimal debugging info
VERBOSE="-v 0"
DEBUG=false

# File to use for saving video statistics
STAT_DIR=$HOME/.tovid
STAT_FILE="$STAT_DIR/stats.tovid"
LOG_FILE=""
SCRATCH_FILE=""

# Do not force encoding of compliant video
FORCE_ENCODING=false
FORCE_FPS=false
FORCE_FPSRATIO=""
# No parallel by default
PARALLEL=false
ENCODING_MODE="serial"
MTHREAD=""
# List of PIDS to kill on exit
PIDS=""
# Live video
VIDEO_TYPE="live"
# Do not normalize audio
DO_NORM=false
# Compact disc size (unset by default)
DISC_SIZE=""
# Nonvideo bitrate
NONVIDEO_BITRATE=""
# Default progress-meter update interval
SLEEP_TIME="5s"
# Don't use subtitles unless user requests it
SUBTITLES="-noautosub"
# Input file and type
IN_FILE=""
IN_FILE_TYPE="file"
# Output prefix
OUT_PREFIX=""
OUT_FILENAME=""
# Resolution, FPS, and length are unknown
ID_VIDEO_WIDTH="0"
ID_VIDEO_HEIGHT="0"
ID_VIDEO_FPS="0.000"
V_DURATION="0"
# No custom mplayer opts
MPLAYER_OPTS=""
MUX_OPTS=""
# Don't do fast encoding
FAST_ENCODING=false

# Make note of when encoding starts, to determine total time later.
SCRIPT_START_TIME=`date +%s`
# Trap Ctrl-C and TERM to clean up child processes
trap 'killsubprocs; exit 13' TERM INT


# ******************************************************************************
# ******************************************************************************
#
#
# FUNCTION DEFINITIONS
#
#
# ******************************************************************************
# ******************************************************************************


# ******************************************************************************
# Y-echo: echo to two places at once (stdout and logfile)
# Output is preceded by the script name that produced it
# Args: $@ == any text string
# If no args are given, echo a separator bar
# Why echo when you can yecho?
# ******************************************************************************
yecho()
{
    if test $# -eq 0; then
        printf "\n%s\n\n" "$SEPARATOR"
        # If logfile exists, copy output to it (with pretty formatting)
        test -e "$LOG_FILE" && \
            printf "%s\n%s %s\n%s\n" "$ME" "$ME" "$SEPARATOR" "$ME" >> "$LOG_FILE"
    else
        echo "$@"
        test -e "$LOG_FILE" && \
            printf "%s %s\n" "$ME" "$@" >> "$LOG_FILE"
    fi
}

# ******************************************************************************
# Print usage notes and optional error message, then exit.
# Args: $@ == text string containing error message 
# ******************************************************************************
usage_error()
{
    printf "%s\n" "$USAGE"
    printf "%s\n" "$SEPARATOR"
    echo $@
    exit 1
}

# ******************************************************************************
# Print out a runtime error specified as an argument, and exit
# ******************************************************************************
runtime_error()
{
    killsubprocs
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    yecho "tovid encountered an error during encoding:"
    yecho "    $@"
    echo "Check the contents of $LOG_FILE to see what went wrong."
    if $DEBUG; then :; else
        echo "Run tovid again with the -debug option to produce more verbose"
        echo "output, if the log file doesn't give you enough information."
    fi
    echo " "
    echo "See the tovid website (http://tovid.org/) for what to do next."
    echo "Sorry for the inconvenience!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
}

# ******************************************************************************
# Kill child processes
# ******************************************************************************
killsubprocs()
{
    yecho "Encode stopped, killing all sub processes"
    eval "kill $PIDS"
}    


# ******************************************************************************
# Estimate whether there is enough disk space to encode
# ******************************************************************************
check_disk_space()
{
    # Determine space available in current directory (in MB)
    AVAIL_SPACE=`df -mP . | awk 'NR != 1 {print $4;}'`
    # Rough estimates of KB/sec for different formats
    K_PER_SEC=200
    test x"$TGT_RES" = x"VCD" && K_PER_SEC=172
    test x"$TGT_RES" = x"DVD-VCD" && K_PER_SEC=200
    test x"$TGT_RES" = x"Half-DVD" && K_PER_SEC=300
    test x"$TGT_RES" = x"DVD" && K_PER_SEC=350
    test x"$TGT_RES" = x"SVCD" && K_PER_SEC=300

    # If video length is unknown, guess needed space
    # based on original file size
    if test x"$V_DURATION" = x"0"; then
        CUR_SIZE=`du -c -k \"$IN_FILE\" | awk 'END{print $1}'`
        NEED_SPACE=`expr $CUR_SIZE \* 2`
        yecho  "The encoding process will require about"
    # Estimate space based as kbps * duration
    else
        NEED_SPACE=`expr $V_DURATION \* $K_PER_SEC / 500`
        yecho "The encoding process is estimated to require $NEED_SPACE MB of disk space."
    fi

    yecho "You currently have $AVAIL_SPACE MB available in this directory."
}



# ******************************************************************************
# Read all command-line arguments, and read any arguments included in the
# default configuration file (if it exists)
# ******************************************************************************
get_args()
{
    # Parse all arguments
    while test $# -gt 0; do
        case "$1" in
            "-v" | "-version" )
                echo "$TOVID_VERSION"
                exit 0
                ;;
        
            # Use config file?
            "-config" )
                # Read in name of config file
                # (will be read in later)
                shift
                CONFIG_FILE="$1"
                ;;

            # PAL or NTSC
            "-pal" )
                TVSYS="PAL"
                BASETVSYS="PAL"
                ;;
            "-ntsc" )
                TVSYS="NTSC"
                BASETVSYS="NTSC"
                ;;
            "-ntscfilm" )
                TVSYS="NTSCFILM"
                BASETVSYS="NTSC"
                ;;

            # Target video resolution
            "-vcd" )        TGT_RES="VCD" ;;
            "-dvd-vcd" )    TGT_RES="DVD-VCD" ;;
            "-svcd" )       TGT_RES="SVCD" ;;
            "-dvd" )        TGT_RES="DVD" ;;
            "-half-dvd" )   TGT_RES="Half-DVD" ;;
            "-kvcdx3" | "-kvcd" )   TGT_RES="KVCDx3" ;;
            "-kvcdx3a" | "-ksvcd" ) TGT_RES="KVCDx3a" ;;
            "-kdvd" )       TGT_RES="KDVD" ;;

            # Other options
            "-normalize" )  DO_NORM=: ;;
            "-overwrite" ) OVERWRITE=: ;;
            # Aspect ratio
            "-aspect" )
                shift
                ASPECT_RATIO="$1"
                ;;
            "-wide" ) ASPECT_RATIO="16:9" ;;
            "-full" ) ASPECT_RATIO="4:3" ;;
            "-panavision" ) ASPECT_RATIO="235:100" ;;
            "-debug" )
                VERBOSE="-v 1"
                DEBUG=:
                ;;
            "-force" ) FORCE_ENCODING=: ;;
            "-fps" )
                shift
                # If user provided X:Y ratio, use it
                if expr match "$1" '[0-9][0-9]*:[0-9][0-9]*$'; then
                    FORCE_FPSRATIO="$1"
                # Otherwise, tack on a :1 denominator
                elif expr match "$1" '[0-9][0-9]*$'; then
                    FORCE_FPSRATIO="$1:1"
                else
                    usage_error "Please provide an integer number or X:Y ratio to the -fps option"
                fi
                FORCE_FPS=:
                ;;
            "-vbitrate" )
                shift
                VID_BITRATE="$1"
                ;;
            "-quality" )
                shift
                VID_QUALITY="$1"
                ;;
            "-safe" )
                shift
                SAFE_AREA=`echo $1 | sed 's/%//g'`
                ;;
            "-filters" )
                shift
                # Parse comma-separated values
                for FILTER in `echo "$1" | sed 's/,/ /g'`; do
                    case "$FILTER" in
                        "none" )
                            DO_DENOISE=false
                            DO_CONTRAST=false
                            DO_DEBLOCK=false
                            ;;
                        "all" )
                            DO_DENOISE=:
                            DO_CONTRAST=:
                            DO_DEBLOCK=:
                            ;;
                        "contrast" )
                            DO_CONTRAST=:
                            ;;
                        "denoise" )
                            DO_DENOISE=:
                            ;;
                    esac
                done
                ;;
            "-abitrate" )
                shift
                AUD_BITRATE=$1
                ;;
            "-priority" )
                shift
                if test x"$1" = x"low"; then
                    PRIORITY="nice -n 19"
                elif test x"$1" = x"medium"; then
                    PRIORITY="nice -n 10"
                fi
                ;;
            "-deinterlace" )
                # Use median deinterlacer (reasonably good quality)
                DEINTERLACE=:
                ;;
            "-interlaced" )
                # Do interlaced encoding
                INTERLACED=:
                # Top field first
                ILACE_FIELD_ORDER="top"
                ;;
            "-interlaced_bf" )
                # Do interlaced encoding
                INTERLACED=:
                # Bottom field first
                ILACE_FIELD_ORDER="bottom"
                ;;
            "-type" )
                shift
                VIDEO_TYPE="$1"
                ;;
            "-discsize" )
                shift
                DISC_SIZE="$1"
                ;;
            "-parallel" )
                PARALLEL=:
                ENCODING_MODE="parallel"
                ;;
            "-subtitles" )
                shift
                # Force re-encoding of compliant video,
                # so subtitles can be added
                FORCE_ENCODING=:
                if test -e "$1"; then
                    SUBTITLES="-sub $1"
                else
                    yecho "Cannot find subtitle file $1."
                fi
                ;;
            "-update" )
                # Set status update interval
                shift
                SLEEP_TIME="$1"
                ;;
            "-mplayeropts" )
                shift
                MPLAYER_OPTS="$1"
                ;;
            "-ffmpeg" )
                USE_FFMPEG=:
                ;;
            "-nofifo" )
                USE_FIFO=false
                ;;
            "-help" )
                # Print normal and advanced usage options, and exit
                printf "%s\n" "$USAGE"
                printf "%s\n" "$ADVANCED_USAGE"
                exit 0
                ;;
            "-in" )
                shift
                # Get a full pathname for the infile
                D=`dirname "$1"`
                B=`basename "$1"`
                IN_FILE="`cd \"$D\" && pwd || echo \"$D\"`/$B"
                ;;
            "-out" )
                shift
                OUT_PREFIX="$1"
                # Get a full pathname for the final outfile
                D=`dirname "$OUT_PREFIX"`
                B=`basename "$OUT_PREFIX"`
                # Use full pathname with extension (mpg)
                OUT_FILENAME="`cd \"$D\" && pwd || echo \"$D\"`/$B.mpg"
                ;;

            # Null option; ignored.
            "-" )
                ;;

            # If the option wasn't recognized, exit with an error
            * )
                usage_error "Error: Unrecognized command-line option $1"
                ;;
            esac

        # Get next argument
        shift
    done

    # Read in the config file, but only if a config
    # file is not already being read (prevents recursion
    # if a config file calls itself).
    if $READING_CONFIG; then :
    else
        # check that a config file exists and is readable
        if test -r "$CONFIG_FILE"; then
            # Make sure file is a tovid config file
            CONFIG_TYPE=`head -n 1 "$CONFIG_FILE"`
            if test x"$CONFIG_TYPE" != x"tovid"; then
                yecho "$CONFIG_FILE is not a valid tovid configuration file."
                yecho "Skipping $CONFIG_FILE"
            else
                READING_CONFIG=:
                CONFIG_ARGS=`grep '^-' $CONFIG_FILE | tr '\n' ' '`
                yecho "Using config file $CONFIG_FILE, containing the following options:"
                if test -n "$CONFIG_ARGS"; then
                    yecho "$CONFIG_ARGS"
                    eval get_args "$CONFIG_ARGS"
                else
                    yecho "(none)"
                fi
            fi
        fi

    fi # If READING_CONFIG

} # End get_args()


# ******************************************************************************
# Clean up temporary files
# ******************************************************************************
cleanup()
{
    cd "$WORKING_DIR"
    yecho "Cleaning up..."
    pwd
    rm -fv "$OUT_PREFIX.$VID_SUF"
    rm -fv "$OUT_PREFIX.$AUD_SUF"
    rm -fv stream.yuv
    rm -fv $AUDIO_WAV

    # Remove log/temp files, unless debugging was enabled
    if $DEBUG; then
        yecho "Keeping temporary files in directory $TMP_DIR"
    else
        rm -rfv "$TMP_DIR" | tee -a "$LOG_FILE"
    fi
}


# ******************************************************************************
# ******************************************************************************
#
#
# EXECUTION BEGINS HERE
#
#
# ******************************************************************************
# ******************************************************************************

get_args "$@"

# ******************************************************************************
# Do all work in the working directory
# ******************************************************************************
echo "Changing to working directory: $WORKING_DIR"
cd $WORKING_DIR

# ******************************************************************************
# Make all necessary dependencies are available, to prevent errors later
# ******************************************************************************
if type mplayer >/dev/null; then :; else
    echo "$ME It looks like you don't have mplayer installed. I need mplayer"
    echo "for playing and encoding video. You can get mplayer from:"
    echo "    http://www.mplayerhq.hu/"
    exit 1
fi
if type mpeg2enc >/dev/null; then :; else
    echo "$ME It looks like you don't have mjpegtools installed. I need mjpegtools"
    echo "for encoding video and audio. You can get mjpegtools from:"
    echo "    http://mjpeg.sourceforge.net/"
    exit 1
fi

printf "%s\n" "$SCRIPT_NAME"

# ******************************************************************************
# Sanity checks. Make sure input file exists, and see if we're going
# to overwrite any existing output files.
# ******************************************************************************

# Make sure infile and outfile were provided somewhere
if test -z "$IN_FILE" || test -z "$OUT_PREFIX"; then
    usage_error "Please provide input and output filenames using -in and -out options."
fi

# Determine whether input is a normal file or a URI of some sort
# (if input name contains "://", it's assumed to be a URI)
if expr "$IN_FILE" : ".*:\/\/" >/dev/null; then
    IN_FILE_TYPE="uri"
else
    IN_FILE_TYPE="file"
fi

# Make sure infile exists
if test x"$IN_FILE_TYPE" = x"file"; then
    if test -e "$IN_FILE"; then
        :
    else
        exit_with_error "Could not find input file $IN_FILE. Exiting."
    fi
fi

# check that outfile is not a directory
if test -d "$OUT_PREFIX"; then
    exit_with_error "Error: The specified output file is a directory.  A filename must be specified."
fi

# If output file(s) exist, prompt for overwrite
if test -e "$OUT_PREFIX.$VID_SUF" || test -e "$OUT_FILENAME" || test -e "$OUT_PREFIX.$AUD_SUF"; then
    yecho "It looks like some files already exist with prefix: $OUT_PREFIX"
    if $OVERWRITE; then
        yecho "Removing existing files..."
        rm -fv "$OUT_PREFIX.$VID_SUF" "$OUT_FILENAME" "$OUT_PREFIX.$AUD_SUF"
    else
        exit_with_error "If you would like to overwrite the existing files, please re-run the script with the 'overwrite' option."
    fi
fi

# Create a unique temporary directory
TMP_DIR=`mktemp -d ${WORKING_DIR}/tovid-temp.XXXXXX`
# Files to use for temporarily storing video info and encoding progress
SCRATCH_FILE="${TMP_DIR}/tovid.scratch"
LOG_FILE="${TMP_DIR}/tovid.log"

# Remove temp and log files if they exist
rm -f "$SCRATCH_FILE" "$LOG_FILE"
# Print current command-line to log
echo "$ME $0 $@" >> "$LOG_FILE"
echo "$ME Version $TOVID_VERSION" >> "$LOG_FILE"

# ******************************************************************************
#
# Resolution setup
#
# Set encoding command-line options (later passed to mpeg2enc, mplayer,
# and mplex) according to the specified TV system and output format.
#
# ******************************************************************************
case "$TVSYS" in
    "PAL" )
        VID_NORM="-n p"
        VID_FPS="-F 3"
        TGT_FPS="25.000"
        TGT_FPSRATIO="25:1"
        ;;
    "NTSC" )
        VID_NORM="-n n"
        VID_FPS="-F 4"
        TGT_FPS="29.970"
        TGT_FPSRATIO="30000:1001"
        ;;
    "NTSCFILM" )
        VID_NORM="-n n"
        # VCD can't use 3:2 pulldown; all others can
        if test x"$TGT_RES" = x"VCD"; then
            VID_FPS="-F 2"
        else
            VID_FPS="-F 1 -p"
        fi
        TGT_FPS="23.976"
        TGT_FPSRATIO="24000:1001"
        ;;
esac

# Set GOP min/max sizes depending on video type and TV
# system. These most likely need to be tweaked. If you
# would be interested in doing comparative studies
# of videos encoded with different GOP sizes, please
# let the tovid development team know!
case "$VIDEO_TYPE" in
    "bw" )
        GOP_MINSIZE=6
        case "$TVSYS" in
            "PAL" ) GOP_MAXSIZE=12 ;;
            "NTSC" ) GOP_MAXSIZE=15 ;;
            "NTSCFILM" ) GOP_MAXSIZE=10 ;;
        esac
        ;;
    "animation" )
        GOP_MINSIZE=8
        # Animation uses highest GOP size allowed
        case "$TVSYS" in
            "PAL" ) GOP_MAXSIZE=15 ;;
            "NTSC" ) GOP_MAXSIZE=18 ;;
            "NTSCFILM" ) GOP_MAXSIZE=12 ;;
        esac
        ;;
    "live" )
        GOP_MINSIZE=4
        case "$TVSYS" in
            "PAL" ) GOP_MAXSIZE=9 ;;
            "NTSC" ) GOP_MAXSIZE=11 ;;
            "NTSCFILM" ) GOP_MAXSIZE=9 ;;
        esac
        ;;
esac

# Set disc size (if unset) and audio sampling rate
if test x"$TGT_RES" = x"DVD-VCD" || test x"$TGT_RES" = x"Half-DVD" || test x"$TGT_RES" = x"DVD"; then
    # Allow a little extra space for menus, etc. (4500 instead of 4700)
    test -z "$DISC_SIZE" && DISC_SIZE="4500"
    SAMPRATE=48000
else
    test -z "$DISC_SIZE" && DISC_SIZE="700"
    SAMPRATE=44100
fi

# Default quality 8, if not set by user
: ${VID_QUALITY:=8}

# Set resolution and frame rate according to format and TV system
case "$TGT_RES" in
    # VCD
    "VCD" )
        TGT_WIDTH="352"
        if test x"$TVSYS" = x"PAL"; then
            TGT_HEIGHT="288"
        else
            TGT_HEIGHT="240"
        fi
        AUD_SUF="mpa"
        # Explicitly set audio/video bitrates
        AUD_BITRATE="224"
        VID_BITRATE="1150"
        FORMAT="VCD"
        MPEG2_FMT="-f 1"
        SND_OPTS="-V"
        MUX_OPTS="-f 1"
        VID_SUF="m1v"
        ;;

    # VCD-on-DVD
    "DVD-VCD" )
        TGT_WIDTH="352"
        if test x"$TVSYS" = x"PAL"; then
            TGT_HEIGHT="288"
            FORMAT="SIZE_352x288"
        else
            TGT_HEIGHT="240"
            FORMAT="SIZE_352x240"
        fi
        AUD_SUF="ac3"
        # -quality gives bitrates from 400-4000 kbps
        DEFAULT_BR=`expr $VID_QUALITY \* 4000 \/ 10`
        # Use default bitrate if none specified
        : ${VID_BITRATE:=$DEFAULT_BR}
        MPEG2_FMT="-f 8 -b $VID_BITRATE -g $GOP_MINSIZE -G $GOP_MAXSIZE"
        SND_OPTS="-r $SAMPRATE -s"
        MUX_OPTS="-V -f 8"
        VID_SUF="m2v"
        ;;

    # SVCD
    "SVCD" )
        TGT_WIDTH="480"
        if test x"$TVSYS" = x"PAL"; then
            TGT_HEIGHT="576"
        else
            TGT_HEIGHT="480"
        fi
        AUD_SUF="mpa"
        FORMAT="SVCD"
        # -quality gives bitrates from 260-2600 kbps
        DEFAULT_BR=`expr $VID_QUALITY \* 2600 \/ 10`
        # Use default bitrate if none specified
        : ${VID_BITRATE:=$DEFAULT_BR}
        MPEG2_FMT="-f 4 -b $VID_BITRATE"
        SND_OPTS="-V"
        MUX_OPTS="-V -f 4 -b 230"
        VID_SUF="m2v"
        ;;

    # Half-D1 DVD
    "Half-DVD" )
        TGT_WIDTH="352"
        if test x"$TVSYS" = x"PAL"; then
            TGT_HEIGHT="576"
            FORMAT="SIZE_352x576"
        else
            TGT_HEIGHT="480"
            FORMAT="SIZE_352x480"
        fi
        AUD_SUF="ac3"
        # -quality gives bitrates from 600-6000 kbps
        DEFAULT_BR=`expr $VID_QUALITY \* 6000 \/ 10`
        # Use default bitrate if none specified
        : ${VID_BITRATE:=$DEFAULT_BR}
        MPEG2_FMT="-f 8 -b $VID_BITRATE -g $GOP_MINSIZE -G $GOP_MAXSIZE"
        SND_OPTS="-r $SAMPRATE -s"
        MUX_OPTS="-V -f 8 -b 300"
        VID_SUF="m2v"
        ;;

    # KVCDx3(a) long-playing, high-resolution MPEG for (S)VCD
    "KVCDx3" | "KVCDx3a" )
        # KVCD x3 or x3a?
        if test x"$TGT_RES" = x"kvcdx3"; then
            TGT_WIDTH="528"
        else
            TGT_WIDTH="544"
        fi

        # PAL or NTSC
        if test x"$TVSYS" = x"PAL"; then
            TGT_HEIGHT="576"
        else
            TGT_HEIGHT="480"
        fi
        FORMAT="SIZE_${TGT_WIDTH}x${TGT_HEIGHT}"
        AUD_SUF="mpa"

        # -quality gives bitrates from 400-4000 kbps
        DEFAULT_BR=`expr $VID_QUALITY \* 4000 \/ 10`
        # Use default bitrate if none specified
        : ${VID_BITRATE:=$DEFAULT_BR}

        # Use optimal (non-standard!) GOP size for live video
        if test x"$VIDEO_TYPE" = x"live"; then
            GOP_MAXSIZE="24"
        fi
        # KVCDx3(a) is treated as SVCD, since the standard doesn't specify
        # mpeg2enc 1.6.2 seems to want bitrate and buffer size (-b and -V)
        # to be explicit.
        MPEG2_FMT="-f 5 -b $VID_BITRATE -V 230 -K kvcd -g $GOP_MINSIZE -G $GOP_MAXSIZE -D 8 -d"
        SND_OPTS="-V" # (S)VCD-compliant sound
        MUX_OPTS="-V -f 5 -b 350 -r 10800"
        VID_SUF="m2v"
        ;;

    # DVD (and KDVD)
    "DVD" | "KDVD" )
        TGT_WIDTH="720"
        if test x"$TVSYS" = x"PAL"; then
            TGT_HEIGHT="576"
        else
            TGT_HEIGHT="480"
        fi
        AUD_SUF="ac3"
        FORMAT="DVD"
        # -quality gives bitrates from 980-9800 kbps
        DEFAULT_BR=`expr $VID_QUALITY \* 9800 \/ 10`
        # Use default bitrate if none specified
        : ${VID_BITRATE:=$DEFAULT_BR}
        MPEG2_FMT="-f 8 -b $VID_BITRATE -g $GOP_MINSIZE -G $GOP_MAXSIZE -D 10"
        # For KDVD, use KVCD "Notch" quantization
        test x"$TGT_RES" = x"KDVD" && MPEG2_FMT="$MPEG2_FMT -K kvcd"
        SND_OPTS="-r $SAMPRATE -s"
        MUX_OPTS="-V -f 8 -b 400"
        VID_SUF="m2v"
        ;;

esac # End resolution

# ******************************************************************************
#
# Set nonvideo bitrate, deinterlacing and quality options
#
# ******************************************************************************

yecho

# Set nonvideo bitrate
# Formula: Sum of all nonvideo bitrates + 1% of total bitrate
NONVIDEO_BITRATE=`expr \( 101 \* $AUD_BITRATE + $VID_BITRATE \) / 100`

# Put available mplayer -vf filters into temp file
mplayer -vf help > "$SCRATCH_FILE" 2>&1

# Find out if mplayer's 'pp' option is available.
if grep -q "^ *pp " "$SCRATCH_FILE"; then
    PP_AVAIL=:
elif grep -q "^ *spp " "$SCRATCH_FILE"; then
    SPP_AVAIL=:
else
    PP_AVAIL=false
    SPP_AVAIL=false
fi

# Set up deinterlacing, if requested.
# Use the best deinterlacer available, and
# fall back to others if not available in the user's
# version of mplayer.
if $DEINTERLACE; then
    # If PP is available, use median deinterlacing
    # NOT ENABLED: pp=md possibly unstable
    # if $PP_AVAIL; then
        #VID_FILTER="-vf pp=md"
    # See if adaptive kernel deinterlacer is available
    if grep -q "^ *kerndeint " "$SCRATCH_FILE"; then
        VID_FILTER="-vf kerndeint"
    # Finally, try lavcdeint
    elif grep -q "^ *lavcdeint " "$SCRATCH_FILE"; then
        VID_FILTER="-vf lavcdeint"
    # Nothing available - print a warning
    else
        yecho "I can't find any deinterlacing options to use. No deinterlacing"
        yecho "will be done on this video (but encoding will continue)."
        yecho "Encoding will resume in 5 seconds..."
        sleep 5s
    fi
fi

# Default quantization
QUANT=`expr 13 - $VID_QUALITY`

# mpeg2enc encoding quality options
# Don't use -q for VCD (since -q implies variable bitrate)
if test x"$TGT_RES" = x"VCD"; then
    MPEG2_QUALITY="-4 2 -2 1 -H"
else
    MPEG2_QUALITY="-4 2 -2 1 -q $QUANT -H"
fi

# Apply requested postprocessing filters, or
# fall back to the best alternative.
if $DO_DENOISE; then
    # If high-quality 3D denoising is available, use it
    if grep -q "^ *hqdn3d " "$SCRATCH_FILE"; then
        VID_FILTER="$VID_FILTER -vf-add hqdn3d"
    # Otherwise, use normal 3D denoising
    elif grep -q "^ *denoise3d " "$SCRATCH_FILE"; then
        VID_FILTER="$VID_FILTER -vf-add denoise3d"
    # If all else fails, use yuvdenoise (if available)
    elif type -p yuvdenoise; then
        YUVDENOISE="yuvdenoise |"
    else
        yecho "Unable to find a suitable denoising filter. Skipping."
    fi
fi
if $DO_CONTRAST; then
    if $PP_AVAIL; then
        VID_FILTER="$VID_FILTER -vf-add pp=al:f"
    else
        yecho "Unable to find a suitable contrast-enhancement filter. Skipping."
    fi
fi
if $DO_DEBLOCK; then
    if $PP_AVAIL; then
        VID_FILTER="$VID_FILTER -vf-add pp=hb/vb"
    elif $SPP_AVAIL; then
        VID_FILTER="$VID_FILTER -vf-add spp"
    else
        yecho "Unable to find a suitable deblocking filter. Skipping."
    fi
fi

# Do fast encoding if requested. Sacrifice quality for encoding speed.
# NOT IMPLEMENTED IN COMMAND-LINE YET!
if $FAST_ENCODING; then
    QUANT=`expr $QUANT + 4`
    MPEG2_QUALITY="-4 4 -2 4 -q $QUANT"
fi

# ******************************************************************************
#
# Probe input file; check for compliance with selected output format.
#
# ******************************************************************************

yecho "Converting $IN_FILE to compliant $TVSYS $TGT_RES format"
yecho "Storing log and temporary files in $TMP_DIR"
$DEBUG && yecho "Run 'tail -f $LOG_FILE' in another terminal to monitor the log"
yecho


# Probe for width, height, frame rate, and duration
# Do not probe inputs that are not files
if test x"$IN_FILE_TYPE" = x"file"; then

    # Probe $IN_FILE for resolution, fps, and length.
    yecho "Probing video for information. This may take several minutes..."

    # Get an MD5sum of the input file for statistics
    IN_FILE_MD5=`md5sum "$IN_FILE" | awk '{print $1}'`

    # Assume nothing is compliant unless idvid says so
    # (these will be overridden by idvid for compliant A/V)
    A_VCD1_OK=false
    A_VCD2_OK=false
    A_SVCD_OK=false
    A_DVD_OK=false
    A_NOAUDIO=false
    V_VCD_OK=false
    V_SVCD_OK=false
    V_DVD_OK=false
    V_RES=""
    
    # Sneaky but simple way to set some variables via 'idvid'.
    # Exit on failure.
    if eval `idvid -terse "$IN_FILE"`; then :; else
        runtime_error "Could not identify source video: $IN_FILE"
    fi

    # Check for available space and prompt if it's not enough
    check_disk_space
    if test "$AVAIL_SPACE" -lt "$NEED_SPACE"; then
        yecho "Available: $AVAIL_SPACE, needed: $NEED_SPACE"
        echo "It doesn't look like you have enough space to encode this video."
        echo "Of course, I could be wrong. Do you want to proceed anyway? (y/n)"
        read PROCEED
        if test x"$PROCEED" != x"y"; then
            cleanup
            exit 0
        fi
    fi

    # Check for compliance in existing video
    if test x"$TGT_RES" = x"VCD"; then
        $A_VCD1_OK || $A_VCD2_OK && AUDIO_OK=:
        $V_VCD_OK && test "$V_RES" = "${BASETVSYS}_VCD" && VIDEO_OK=:
        
    elif test x"$TGT_RES" = x"SVCD"; then
        $A_SVCD_OK && AUDIO_OK=:
        $V_SVCD_OK && test "$V_RES" = "${BASETVSYS}_SVCD" && VIDEO_OK=:

    else # Any DVD format
        $A_DVD_OK && AUDIO_OK=:
        if $V_DVD_OK; then
            if test x"$TGT_RES" = x"DVD-VCD"; then
                test "$V_RES" = "${BASETVSYS}_VCD" && VIDEO_OK=:
            elif test x"$TGT_RES" = x"Half-DVD"; then
                test "$V_RES" = "${BASETVSYS}_HALF" && VIDEO_OK=:
            elif test x"$TGT_RES" = x"DVD"; then
                test "$V_RES" = "${BASETVSYS}_DVD" && VIDEO_OK=:
            fi
        fi
    fi

    yecho "Analysis of file $IN_FILE:"
    yecho "  $ID_VIDEO_WIDTH x $ID_VIDEO_HEIGHT pixels, $ID_VIDEO_FPS fps"
    yecho "  Duration (best guess): `format_time $V_DURATION` (HH:MM:SS)"
    yecho "  $ID_VIDEO_FORMAT video with $ID_AUDIO_CODEC audio"

    # If no audio stream present, need to generate one later
    if $A_NOAUDIO; then
        AUDIO_OK=false
        GENERATE_AUDIO=:
    fi

    # If both audio and video are OK, stop now - there's no need to convert.
    if ! $FORCE_ENCODING && $AUDIO_OK && $VIDEO_OK; then
        # Create a symbolic link in place of the output file
        $OVERWRITE && rm -f "$OUT_FILENAME"
        ln -s "$IN_FILE" "$OUT_FILENAME"
        yecho
        yecho "Audio and video streams appear to already be compliant with the"
        yecho "selected output format. If you want to force encoding (for instance,"
        yecho "to change the bitrate or take advantage of denoising), run tovid"
        yecho "again with the '-force' option. A symbolic link has been created"
        yecho "in place of the output file:"
        yecho "    $OUT_FILENAME --> $IN_FILE"
        yecho
        yecho "Done!"
        cleanup
        exit 0
    fi
    if $VIDEO_OK; then
        yecho
        yecho "Video stream is already compliant with $TVSYS $TGT_RES."
        yecho "No re-encoding is necessary. To force encoding, use -force"
        yecho
    fi
    if $AUDIO_OK; then
        yecho
        yecho "Audio stream is already compliant with $TVSYS $TGT_RES."
        yecho "No re-encoding is necessary. To force encoding, use -force"
        yecho
    fi

else # If $IN_FILE_TYPE != "file"
    yecho "Input video is not a locally-accessible file. The input video"
    yecho "will NOT be probed for resolution, length, or compliance."
fi

yecho "Target format:"
yecho "  $TGT_WIDTH x $TGT_HEIGHT pixels, $TGT_FPS fps"
yecho "  $VID_SUF video with $AUD_SUF audio"
yecho "  $VID_BITRATE kbits/sec video, $AUD_BITRATE kbits/sec audio"

# ******************************************************************************
#
# Set aspect ratio
#
# ******************************************************************************

# If user supplied an aspect ratio, use that; normalize the value with
# respect to 100 (i.e., 4:3 becomes normalized to 133:100, or simply 133)
# OVERRIDES AUTO-DETECTED ASPECT RATIO!
if test -n "$ASPECT_RATIO"; then
    yecho "Using explicitly provided aspect ratio of $ASPECT_RATIO"
    PLAY_WIDTH=`echo $ASPECT_RATIO | awk -F ':' '{print $1}'`
    PLAY_HEIGHT=`echo $ASPECT_RATIO | awk -F ':' '{print $2}'`
    V_ASPECT_WIDTH=`expr $PLAY_WIDTH \* 100 / $PLAY_HEIGHT`
else
    # Set human-readable aspect ratio string
    # (i.e., format '133' as '1.33:1', etc.)
    #ASPECT_RATIO=`echo $V_ASPECT_WIDTH | sed -r -e 's/([0-9]*)([0-9][0-9])/\1.\2:1/g'`
    yecho "Using auto-detected aspect ratio of $V_ASPECT_WIDTH:100 (override with -aspect)"
fi


# For DVD only, if aspect exceeds 16:9 (177 / 100), use wide playback
# (anamorphic widescreen)
if test x"$FORMAT" = x"DVD" && test "$V_ASPECT_WIDTH" -ge 177; then
    TGT_ASPECT_WIDTH=177
    ASPECT_FMT="-a 3"
# For all others, overall aspect is 4:3 (133 / 100)
else
    TGT_ASPECT_WIDTH=133
    ASPECT_FMT="-a 2"
fi

# Determine width/height to scale to, maintaining aspect
# If aspect is OK, leave it alone
if test "$V_ASPECT_WIDTH" -eq "$TGT_ASPECT_WIDTH"; then
    yecho "No letterboxing necessary"
    INNER_WIDTH=$TGT_WIDTH
    INNER_HEIGHT=$TGT_HEIGHT
# If needed aspect is greater than target format's aspect,
# use full width, and letterbox vertically
elif test "$V_ASPECT_WIDTH" -gt "$TGT_ASPECT_WIDTH"; then
    yecho "Letterboxing vertically"
    INNER_WIDTH=$TGT_WIDTH
    INNER_HEIGHT=`expr $TGT_HEIGHT \* $TGT_ASPECT_WIDTH / $V_ASPECT_WIDTH`
# Otherwise, use full height, and letterbox horizontally
else
    yecho "Letterboxing horizontally"
    INNER_WIDTH=`expr $TGT_WIDTH \* $V_ASPECT_WIDTH / $TGT_ASPECT_WIDTH`
    INNER_HEIGHT=$TGT_HEIGHT
fi

if test $SAFE_AREA -lt 100; then
    yecho "Using a safe area of ${SAFE_AREA}%"
    # Reduce inner size to fit within safe area
    INNER_WIDTH=`expr $INNER_WIDTH \* $SAFE_AREA / 100`
    INNER_HEIGHT=`expr $INNER_HEIGHT \* $SAFE_AREA / 100`
fi

# Round down inner width and height to nearest multiple of 16
# for optimal encoding
INNER_WIDTH=`expr $INNER_WIDTH - \( $INNER_WIDTH \% 16 \)`
INNER_HEIGHT=`expr $INNER_HEIGHT - \( $INNER_HEIGHT \% 16 \)`

# ******************************************************************************
#
# Set FPS and rescaling options
#
# ******************************************************************************

# If forced FPS was used, apply it
if $FORCE_FPS; then
    yecho "Forcing input to be treated as $FORCE_FPSRATIO fps."
    ADJUST_FPS="yuvfps -s $FORCE_FPSRATIO -r $TGT_FPSRATIO $VERBOSE |"
# If FPS is already at the target rate, leave it alone
elif test x"$ID_VIDEO_FPS" = x"$TGT_FPS"; then
    yecho "Input is already $TGT_FPS fps. Framerate will not be altered."
    ADJUST_FPS=""
else
    yecho "Input is not $TGT_FPS fps. Framerate will be adjusted."
    ADJUST_FPS="yuvfps -r $TGT_FPSRATIO $VERBOSE |"
fi

VID_SCALE=""
# Scale to the target inner size
if test $ID_VIDEO_WIDTH != $INNER_WIDTH || test $ID_VIDEO_HEIGHT != $INNER_HEIGHT; then
    yecho "Scaling picture to $INNER_WIDTH x $INNER_HEIGHT"
    VID_SCALE="-vf-add scale=$INNER_WIDTH:$INNER_HEIGHT"
fi
# Expand to the target outer size
if test $INNER_WIDTH != $TGT_WIDTH || test $INNER_HEIGHT != $TGT_HEIGHT; then
    yecho "Centering picture against a $TGT_WIDTH x $TGT_HEIGHT black background"
    VID_SCALE="$VID_SCALE -vf-add expand=$TGT_WIDTH:$TGT_HEIGHT"
fi

# Tell mplayer and mpeg2enc to do interlaced encoding, if requested
# (except for VCD, which doesn't support it)
if $INTERLACED && test x"$TGT_RES" != x"VCD"; then

    # Unneeded, and possibly harmful?
    # MPEG2_FMT="$MPEG2_FMT -I 1"

    # If video filters are being applied, need to deinterleave/reinterlave
    if test -n $VID_FILTER || test -n $VID_SCALE; then
        VF_PRE="-vf-pre il=d:d"
        VF_POST="-vf-add il=i:i"
    fi

    # Do top or bottom-first interlacing
    if test x"$ILACE_FIELD_ORDER" = x"top"; then
        YUV4MPEG_ILACE=":interlaced"
    else
        YUV4MPEG_ILACE=":interlaced_bf"
    fi

    # Add the ilpack video filter
    #VF_POST="$VF_POST -vf-add ilpack"
fi

# ******************************************************************************
# If using ffmpeg, encode and exit
# ******************************************************************************
if $USE_FFMPEG; then
    yecho "Using ffmpeg to do all encoding"
    FF_TVSTD="-tvstd $BASETVSYS"
    FF_SIZE="-s ${INNER_WIDTH}x${INNER_HEIGHT}"
    FF_FPS="-r $TGT_FPS"
    FF_BITRATE="-b $VID_BITRATE -ab $AUD_BITRATE"
    FF_SAMPRATE="-ar $SAMPRATE"
    FF_ASPECT="-aspect $ASPECT_RATIO"

    # Padding, for any letterboxing to be done
    FF_VPAD=""
    FF_HPAD=""
    FF_VPIX=`expr \( $TGT_HEIGHT - $INNER_HEIGHT \) / 2`
    FF_HPIX=`expr \( $TGT_WIDTH - $INNER_WIDTH \) / 2`
    test "$FF_VPIX" -ne 0 && FF_VPAD="-padtop $FF_VPIX -padbottom $FF_VPIX"
    test "$FF_HPIX" -ne 0 && FF_HPAD="-padleft $FF_HPIX -padright $FF_HPIX"

    # Target format, for those targets ffmpeg understands
    case "$TGT_RES" in
        "VCD" | "SVCD" | "DVD" )
            test "$BASETVSYS" = "PAL" && \
                FF_TARGET="-target pal-`echo $TGT_RES | tr A-Z a-z`"
            test "$BASETVSYS" = "NTSC" && \
                FF_TARGET="-target ntsc-`echo $TGT_RES | tr A-Z a-z`"
            FF_CODECS=""
            ;;
        * )
            FF_CODECS="-vcodec mpeg2video -acodec ac3"
            ;;
    esac
    
    FF_ENC_CMD="$PRIORITY ffmpeg -i \"$IN_FILE\" $FF_ASPECT $FF_CODECS $FF_BITRATE $FF_TVSTD \
        $FF_TARGET $FF_FPS $FF_SIZE $FF_VPAD $FF_HPAD \"$OUT_FILENAME\""
    yecho "Encoding video and audio with the following command:"
    yecho "$FF_ENC_CMD"
    eval "$FF_ENC_CMD"
    cleanup
    exit 0
fi


# ******************************************************************************
# Encode and normalize audio
# ******************************************************************************

yecho

if $PARALLEL; then
    rm -f "$OUT_PREFIX.$AUD_SUF"
    mkfifo "$OUT_PREFIX.$AUD_SUF"
fi

# If audio is already in the chosen output format, do not re-encode.
if ! $FORCE_ENCODING && $AUDIO_OK; then
    yecho "Copying the existing audio stream using the following command:"
    AUDIO_CMD="$PRIORITY mplayer \"$IN_FILE\" -dumpaudio -dumpfile \"$OUT_PREFIX.$AUD_SUF\""
    yecho "$AUDIO_CMD"

    if $DEBUG; then
        eval "$AUDIO_CMD" 2>&1 | tee -a "$LOG_FILE" &
    else
        eval "$AUDIO_CMD" >> "$LOG_FILE" 2>&1 &
    fi

    PIDS="$PIDS $!"
    if $PARALLEL; then
        :
    else
        file_output_progress "$OUT_PREFIX.$AUD_SUF" "Copying compliant audio stream"
        wait
    fi
# Re-encode audio
else

    # Do we need to generate an empty audio file?
    if $GENERATE_AUDIO; then
        # Generate an empty .wav file of the needed length
        yecho "Input file appears to have no audio stream. Silence will be used."
        AUDIO_CMD="cat /dev/zero | $PRIORITY sox -t raw -c 2 -r $SAMPRATE -w -s - $AUDIO_WAV trim 0 $V_DURATION"
    # Extract audio normally
    else
        AUDIO_CMD="$PRIORITY mplayer -quiet -vc null -vo null -ao pcm:waveheader:file=$AUDIO_WAV \"$IN_FILE\""
        # Normalize, if requested
        if $DO_NORM; then
            AUDIO_CMD="$AUDIO_CMD -af volnorm"
        fi
    fi
        
    rm -f "$AUDIO_WAV"
    # Use a FIFO in parallel mode
    if $PARALLEL; then 
         mkfifo "$AUDIO_WAV"
    fi

    # Generate or dump audio
    yecho "Creating WAV of audio stream with the following command:"
    yecho "$AUDIO_CMD"

    if $DEBUG; then
        eval "$AUDIO_CMD" 2>&1 | tee -a "$LOG_FILE" &
    else
        eval "$AUDIO_CMD" >> "$LOG_FILE" 2>&1 &
    fi

    PIDS="$PIDS $!"

    # For parallel encoding, nothing more to do right now
    if $PARALLEL; then
        :
    # If not in parallel mode, show .wav-ripping progress,
    # and wait for successful completion.
    else
        file_output_progress "$AUDIO_WAV" "Creating wav of audio stream"
        wait

        # Make sure the audio stream exists before proceeding
        if test ! -f $AUDIO_WAV; then
            if $GENERATE_AUDIO; then
                runtime_error "Could not generate a silent audio track"
            else
                runtime_error "Could not extract audio from original video"
            fi
        fi

    fi

    yecho "Encoding WAV to $AUD_SUF format with the following command:"

    # VCD and SVCD need to be MP2 (mpa) audio, as does PAL
    if test x"$AUD_SUF" = x"mpa"; then
        AUDIO_ENC="cat $AUDIO_WAV | $PRIORITY mp2enc -b $AUD_BITRATE $SND_OPTS -o \"$OUT_PREFIX.$AUD_SUF\""
        yecho "$AUDIO_ENC"
    # Use AC3 audio for all NTSC DVD formats
    else
        AUDIO_ENC="$PRIORITY ffmpeg -i $AUDIO_WAV -ab $AUD_BITRATE -ar 48000 -ac 2 -acodec ac3 -y \"$OUT_PREFIX.$AUD_SUF\""
        yecho "$AUDIO_ENC"
    fi

    if $DEBUG; then
        eval "$AUDIO_ENC" 2>&1 | tee -a "$LOG_FILE" &
    else
        eval "$AUDIO_ENC" >> "$LOG_FILE" 2>&1 &
    fi

    PIDS="$PIDS $!"

    # For parallel, nothing else to do right now
    if $PARALLEL; then
        :
    # If not in parallel mode, show output progress
    # and wait for successful completion
    else
        file_output_progress "$OUT_PREFIX.$AUD_SUF" "Encoding audio to $AUD_SUF"
        wait

        if test -f "$OUT_PREFIX.$AUD_SUF"; then
            yecho "Audio encoding finished successfully."
        else
            runtime_error "There was a problem with encoding the WAV audio to $AUD_SUF format."
        fi
        rm -f "$AUDIO_WAV"
    fi # If ! $PARALLEL

fi # encode audio

# ******************************************************************************
# Encode video
# ******************************************************************************

yecho

# Remove stream.yuv
rm -f stream.yuv
if $PARALLEL; then
    rm -f "$OUT_PREFIX.$VID_SUF"
    mkfifo "$OUT_PREFIX.$VID_SUF"
fi

# If existing video is OK, skip video encoding and just copy the stream
if ! $FORCE_ENCODING && $VIDEO_OK; then
    yecho "Copying existing video stream with the following command:"
    VID_COPY_CMD="mencoder -of rawvideo -nosound -ovc copy \"$IN_FILE\" -o \"$OUT_PREFIX.$VID_SUF\""
    yecho "$VID_COPY_CMD"

    # Copy the video stream
    if $DEBUG; then
        eval "$VID_COPY_CMD" 2>&1 | tee -a "$LOG_FILE" &
    else
        eval "$VID_COPY_CMD" >> "$LOG_FILE" 2>&1 &
    fi

    PIDS="$PIDS $!"

    if $PARALLEL; then
        :
    else
        file_output_progress "$OUT_PREFIX.$VID_SUF" "Copying existing video stream"
        wait
    fi
else
    yecho "Encoding video stream using the following commands:"

    # Normal one-pass encoding, with mplayer piped into the mjpegtools
    if $USE_FIFO; then
        mkfifo stream.yuv
    fi
    VID_PLAY_CMD="$PRIORITY mplayer -benchmark -nosound -noframedrop $SUBTITLES -vo yuv4mpeg${YUV4MPEG_ILACE} ${VF_PRE} ${VID_FILTER} ${VID_SCALE} ${VF_POST} \"$IN_FILE\" $MPLAYER_OPTS"
    VID_ENC_CMD="cat stream.yuv | $YUVDENOISE $ADJUST_FPS $PRIORITY mpeg2enc -S $DISC_SIZE -B $NONVIDEO_BITRATE $MTHREAD $ASPECT_FMT $MPEG2_FMT $VID_FPS $VERBOSE $VID_NORM $MPEG2_QUALITY -o \"$OUT_PREFIX.$VID_SUF\""
    yecho $VID_PLAY_CMD
    yecho $VID_ENC_CMD
    # Start encoding

    if $DEBUG; then
        eval "$VID_PLAY_CMD" 2>&1 | tee -a "$LOG_FILE" &
    else
        eval "$VID_PLAY_CMD" >> "$LOG_FILE" 2>&1 &
    fi

    PIDS="$PIDS $!"
    if $USE_FIFO; then
        file_output_progress stream.yuv "Ripping raw uncompressed video stream"
    fi
    
    if $DEBUG; then
        eval "$VID_ENC_CMD" 2>&1 | tee -a "$LOG_FILE" &
    else
        eval "$VID_ENC_CMD" >> "$LOG_FILE" 2>&1 &
    fi

    PIDS="$PIDS $!"

    # For parallel encoding, nothing further yet
    if $PARALLEL; then
        :
    # Show progress report while video is encoded
    else
        file_output_progress "$OUT_PREFIX.$VID_SUF" "Encoding video stream"
        wait
        :
    fi
fi

yecho

# For non-parallel encoding/multiplexing,
# make sure the video and audio streams exist before proceeding
if $PARALLEL; then
    :
else
    test ! -f "$OUT_PREFIX.$AUD_SUF" && \
        runtime_error "The audio stream did not encode properly, and no output file exists."
    test ! -f "$OUT_PREFIX.$VID_SUF" && \
        runtime_error "The video stream did not encode properly, and no output file exists."
fi


# ******************************************************************************
# ******************************************************************************
#
#
# MULTIPLEX AND FINISH UP
#
#
# ******************************************************************************
# ******************************************************************************

AUDIO_SIZE=`du -c -b "$OUT_PREFIX.$AUD_SUF" | awk 'END{print $1}'`
VIDEO_SIZE=`du -c -b "$OUT_PREFIX.$VID_SUF" | awk 'END{print $1}'`
# Total size of streams so far (in MBytes)
TOTAL_SIZE=`expr \($AUDIO_SIZE \+ $VIDEO_SIZE \) \/ 1000000`
# If it will exceed disc size, add '%d' field to allow mplex to split the output
if test $TOTAL_SIZE -gt $DISC_SIZE; then
    OUT_FILENAME=`echo "$OUT_FILENAME" | sed -e 's/\.mpg$/.%d.mpg/'`
fi


MPLEX_CMD="mplex $MUX_OPTS -o \"$OUT_FILENAME\" \"$OUT_PREFIX.$VID_SUF\" \"$OUT_PREFIX.$AUD_SUF\""
yecho "Multiplexing audio and video together using the following command:"
yecho $MPLEX_CMD
if $DEBUG; then
    eval "$MPLEX_CMD" 2>&1 | tee -a "$LOG_FILE" &
else
    eval "$MPLEX_CMD" >> "$LOG_FILE" 2>&1 &
fi
PIDS="$PIDS $!"

# Parallel encoding doesn't enter the progress
# loop until multiplexing begins.
if $PARALLEL; then
    # If video is being re-encoded
    if ! $VIDEO_OK || $FORCE_ENCODING; then
        file_output_progress "$OUT_FILENAME" "Encoding and multiplexing in parallel"
        wait
    fi
fi

wait
if test -n $?; then
    yecho "Multiplexing finished successfully"
else
    runtime_error "There was a problem multiplexing the audio and video together."
fi


# ******************************************************************************
#
# Gather and save statistics on all output files
#
# ******************************************************************************

# Get total size of all output files
cd `dirname $OUT_FILENAME`
FINAL_SIZE=`du -c -k "$OUT_PREFIX"*.mpg | awk 'END{print $1}'`
test -z $FINAL_SIZE && FINAL_SIZE=0

pwd
yecho "Output files:"
for OUTFILE in `ls -1 "$OUT_PREFIX.mpg $OUT_PREFIX.[0-9].mpg" 2>/dev/null`; do
    yecho "    $OUTFILE (`du -h "$OUTFILE" | awk 'END{print $1}'`)"
done

# Save video statistics. Create stats directory if it doesn't
# already exist.
if test ! -d $STAT_DIR; then
    mkdir $STAT_DIR
fi
# If no stat file exists, create one with a header describing the stats
if test ! -f "$STAT_FILE"; then
    STAT_FILE_HEADER=`cat << EOF
$SCRIPT_NAME

    This file contains statistics on videos encoded with 'tovid.'
    Each line shows the results of one encoded video. From left
    to right, the values are:
    
    ===================================================
    tovid version number (TOVID_VERSION)
    name of output file  (OUT_FILENAME)
    length of video, in seconds (V_DURATION)
    resolution of output (TGT_RES)
    TV system: PAL or NTSC (TVSYS)
    final output size in kilobytes (FINAL_SIZE)
    target video bitrate (VID_BITRATE)
    resulting average bitrate (AVG_BITRATE)
    resulting peak bitrate (PEAK_BITRATE)
    minimum GOP size (GOP_MINSIZE)
    maximum GOP size (GOP_MAXSIZE)
    time spent encoding, in seconds (SCRIPT_TOT_TIME)
    CPU model of host machine (CPU_MODEL)
    CPU speed in MHz (CPU_SPEED)
    serial or parallel encoding (ENCODING_MODE)
    MD5sum of the input file (IN_FILE_MD5)
    Width in pixels of input file (ID_VIDEO_WIDTH)
    Height in pixels of input file (ID_VIDEO_HEIGHT)
    ===================================================

    Values are stored as comma-separated quoted strings, for ease of
    portability. To import these stats into a spreadsheet or database,
    simply remove these comments from the file.

"TOVID_VERSION", "OUT_FILENAME", "V_DURATION", "TGT_RES", "TVSYS", "FINAL_SIZE", "VID_BITRATE", "AVG_BITRATE", "PEAK_BITRATE", "GOP_MINSIZE", "GOP_MAXSIZE", "SCRIPT_TOT_TIME", "CPU_MODEL", "CPU_SPEED", "ID_VIDEO_FORMAT", "ID_AUDIO_CODEC", "ENCODING_MODE", "IN_FILE_MD5", "ID_VIDEO_WIDTH", "ID_VIDEO_HEIGHT"
EOF`

    printf "%s\n" "$STAT_FILE_HEADER" > "$STAT_FILE"
fi

# Gather some statistics...
SCRIPT_END_TIME=`date +%s`
SCRIPT_TOT_TIME=`expr $SCRIPT_END_TIME - $SCRIPT_START_TIME`
HHMMSS=`format_time $SCRIPT_TOT_TIME`
# Avoid dividing by zero (+1 in denominator, since accuracy isn't that important)
FINAL_BITRATE=`expr $FINAL_SIZE / \( $V_DURATION + 1 \)`
# Get average/peak bitrates from mplex
AVG_BITRATE=`grep 'Average bit-rate' "$LOG_FILE" | awk '{print $6}'`
PEAK_BITRATE=`grep 'Peak bit-rate' "$LOG_FILE" | awk '{print $6}'`
# Convert to kbits/sec
AVG_BITRATE=`expr $AVG_BITRATE / 1000`
PEAK_BITRATE=`expr $PEAK_BITRATE / 1000`

# Final statistics string (pretty-printed)
FINAL_STATS_PRETTY=`cat << EOF
----------------------------------------
Final statistics
----------------
tovid $TOVID_VERSION
File: $OUT_FILENAME, $V_DURATION secs $TGT_RES $TVSYS
Final size:      $FINAL_SIZE kilobytes
Target bitrate:  $VID_BITRATE kbits/sec
Average bitrate: $AVG_BITRATE kbits/sec
Peak bitrate:    $PEAK_BITRATE kbits/sec
Took $HHMMSS to encode on $CPU_MODEL $CPU_SPEED mhz
-----------------------------------------
EOF`

# Final statistics (comma-delimited quoted strings)
FINAL_STATS_FORMATTED=`cat << EOF
"$TOVID_VERSION", "$OUT_FILENAME", "$V_DURATION", "$TGT_RES", "$TVSYS", "$FINAL_SIZE", "$VID_BITRATE", "$AVG_BITRATE", "$PEAK_BITRATE", "$GOP_MINSIZE", "$GOP_MAXSIZE", "$SCRIPT_TOT_TIME", "$CPU_MODEL", "$CPU_SPEED", "$ID_VIDEO_FORMAT", "$ID_AUDIO_CODEC", "$ENCODING_MODE", "$IN_FILE_MD5", "$ID_VIDEO_WIDTH", "$ID_VIDEO_HEIGHT"
EOF`


printf "%s\n" "$FINAL_STATS_FORMATTED" >> "$STAT_FILE"

yecho
printf "%s\n" "$FINAL_STATS_PRETTY"
yecho "Statistics written to $STAT_FILE"

cleanup

yecho
yecho "Done!"
yecho
yecho "Your encoded video should be in the file(s) $OUT_FILENAME."
yecho "Thanks for using tovid!"
yecho

exit 0
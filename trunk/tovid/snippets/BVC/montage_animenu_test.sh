#!/bin/bash


##############################################################################
# an example script to test montage method of animation                       #
#                                                                             #
#                                                                             #
# by Robert Sohn <grepper@gmail.com> (grepper on irc.freenode.net)            #
#
# usage: monage_animenu.sh <mpeg-2 file1> "title1" <mpeg-2 file2> "title2"... #
#                                                                             #
###############################################################################


ARGS=("$@")
WORK_DIR=$HOME/tmp/BVC
BVC_LOG=$WORK_DIR/BVC.log
TOTAL_PICS=230
INTRO_VIDEO="$WORK_DIR/intro.avi"
MAX_ANI_LENGTH=600
TARGET=DVD
LINE=$(for ((i=1; i<=79; i++));do echo -n =;done)
TITLE_PAGE=animated
VID_SIZE_OPT=720x480
FRAME_STYLE=fancy
FRAME_CMD=fancy
TITLE_PG_TITLE="My Video Collection"
DATA_DIR=$HOME/.BVC/data/
SPUMUX_XML=$WORK_DIR/spumux.xml
DVDAUTHOR_XML=$WORK_DIR/dvdauthor.xml
GRADIENT="aqua_gradient.png"
SUB_MENU="false" # unused

##############################################################################
#                                 Functions                                  #
##############################################################################

function cleanlog()
# process $BVC_LOG.tmp variously - eg. ffmpeg's output is ugly without this
{
FOLD="fold -bs"
NO_CR="tr -d '\r'"
RELINE="{s/$SED_VAR/\n$SED_VAR/g}"
TMP_LOG="$BVC_LOG.tmp"
NOSPACE="tr -s ' '"


case "$1" in
    1 )
        $FOLD $TMP_LOG >> $BVC_LOG
        echo >> $BVC_LOG
        ;;
    2 )
        $NO_CR < $TMP_LOG | $FOLD >> $BVC_LOG
        echo >> $BVC_LOG
        ;;
    3 )
        $NO_CR < $TMP_LOG | sed $RELINE | $FOLD >> $BVC_LOG
        echo >> $BVC_LOG
        ;;
    4 )
        $NOSPACE < $TMP_LOG | $FOLD >> $BVC_LOG
        ;;
esac

rm -f $BVC_LOG.tmp
}

function sorry_msg()
{
echo -e "Oops . . .Something went wrong.\nThere was a problem \
creating the $OUTPUT. \
\nPlease check the log at $BVC_LOG"
}

function vid_length()
{
mencoder "$1" -quiet \
-ovc copy -oac pcm -o /dev/null |awk '/Video stream/ {print $10}'
}

function static_fade()
# this is suitable for fades for static images, not animated sequences
{

# use -dissolve to create fade effect
S=100
for ((X=0; X<50; X++)) ; do
    composite -dissolve $S $WORK_DIR/black.jpg \
    "${FADIN_JPGS[X]}" "${FADIN_JPGS[X]}"
    S=$((S-2))
done

# do fade-outs
S=0
for ((Y=0; Y<50; Y++)) ; do
    composite -dissolve $S $WORK_DIR/black.jpg \
    "${FADEOUT_JPGS[Y]}" "${FADEOUT_JPGS[Y]}"
    S=$((S+2))
done
}

function cleanup()
{
# does nothing atm
exit 1
}

##############################################################################
#                          	End of functions                                 #
##############################################################################

###############################################################################
#       Process arguments to the script, set up VARS and WORK_DIR             #
###############################################################################

trap cleanup 0 2 15
# create a user's tmp dir if it doesn't exist
# if it exists, move it to a new name
if [ -d $WORK_DIR ]; then
    mv $WORK_DIR $WORK_DIR-`date "+%s"`
    mkdir -p $WORK_DIR
    else
    mkdir -p  $WORK_DIR
fi
# video array starts at 0, title array starts at 1
for ((i=0; i<${#ARGS[@]}; i=$(($i + 2)))); do
    VIDS=( "${VIDS[@]}" "${ARGS[i]}" )
done
for ((i=1; i<=${#ARGS[@]}; i=$(($i + 2)))); do
TITLES=( "${TITLES[@]}" "${ARGS[i]}" )
done

for i in ${VIDS[@]}; do
    VID_ARRAY=( ${VID_ARRAY[@]} $(realpath "$i") )
done

echo -e "VID_ARRAY is ${VID_ARRAY[@]}"

# do everything in $WORK_DIR
cd $WORK_DIR

# make sure titles have no more than 12 characters
for ((i=0; i<${#TITLES[@]}; i++)); do
    val=${#TITLES[i]}
    [ -z "$MAX_VAL" ] || ((val > MAX_VAL)) && MAX_VAL=$val
done


echo -e "the longest value is " "$MAX_VAL"

if [ $MAX_VAL -gt 14 ]; then
    echo -e "Sorry, the maximum number of characters you can use for a title is 14"
    exit 1
fi

SVCD_VID_SIZE_OPT="480x480"
DVD_VID_SIZE_OPT="720x480"
DVD_AUDIO_EXT=ac3
SVCD_AUDIO_EXT=mp2
DVD_SAMPLERATE="48000"
SVCD_SAMPLERATE="44100"
DVD_AUDIO_OPTS="-ab 224 -ar 48000 -ac 2 -acodec $DVD_AUDIO_EXT"
SVCD_AUDIO_OPTS="-ab 224 -ar 44100 -ac 2 -acodec $SVCD_AUDIO_EXT"
SVCD_FFMPEG_TARGET="ntsc-svcd"
DVD_FFMPEG_TARGET="ntsc-dvd"
SVCD_FFMPEG_OPTS="-b 2200 -minrate 2200 -maxrate 2200 -bufsize 230 -aspect 4:3"
DVD_FFMPEG_OPTS="-b 8000  -maxrate 9000 -bufsize 230  -aspect 4:3"
SVCD_INTRO_SIZE="240x240"
DVD_INTRO_SIZE="360x240"
SVCD_MPLEX_FORMAT=4
DVD_MPLEX_FORMAT=8
SVCD_TITLE_FONT_SIZE=32
DVD_TITLE_FONT_SIZE=36
PTSIZE=(30 36 42 42 42 42 48 48 48 48 48 48 54 54 54 54 54 54 54 54 \
54 54 54 54 54 54 54 54 54 54) # unused
CHOP=(42 48 54 54 54 54 60 60 60 60 60 60 60 60 60 60 60 60 60 60
60 60 60 60 60 60 60 60 60 60) 
DVD_GEO_ARRAY=(360x240 270x180 192x128 192x128 180x120 180x120 120x80 120x80 \
144x96 120x80 120x80 120x80 96x64 96x64 96x64 96x64 96x64 96x64 96x64 96x64 \
72x48 72x48 72x48 72x48 72x48 72x48 72x48 72x48 72x48 72x48)
SVCD_GEO_ARRAY=(240x240 180x180 120x120 120x120 120x120 120x120 96x96 96x96 \
96x96 80x80 80x80 80x80 64x64 64x64 64x64 64x64 64x64 64x64 64x64 64x64 \
48x48 48x48 48x48 48x48 48x48 48x48 48x48 48x48 48x48 48x48)
TILE_ARRAY=(1x1 2x1 2x2 2x2 3x2 3x2 3x3 3x3 3x3 4x3 4x3 4x3 4x4 4x4 4x4
4x4 5x4 5x4 5x4 5x4 5x5 5x5 5x5 5x5 5x5 6x5 6x5 6x5 6x5 6x5)
WITH_CHAPT_TILE=(1x1 2x1 2x2 2x2 3x2 3x2 4x2 4x2 3x3 4x3 4x3 4x3 4x4 4x4 4x4 \
4x4 5x4 5x4 5x4 5x4 5x5 5x5 5x5 5x5 5x5 6x5 6x5 6x5 6x5 6x5)

V_ARRAY_TOTAL=${#VID_ARRAY[@]}
A_ARRAY_TOTAL=${#TITLES[@]}
FILES=$(($V_ARRAY_TOTAL - 1))

# test if BVC is installed or running from current dir
if [ -d $DATA_DIR ]; then
    DATA_DIR=$DATA_DIR
else
    DATA_DIR=`pwd`/data
fi


# set up our log file
PATTERN=$(for ((i=1; i<=79; i++));do echo -n \*;done)
printf "%s\n%s\n%s\n\n\n" "$PATTERN" \
"Ben's video Converter (BVC) - log for `date`" \
"$PATTERN" >> $BVC_LOG


# create_dirs
for ((i=0; i<=FILES; i++)) ; do
    mkdir -p  $WORK_DIR/pics/$i/video_fadeout
done

if [ $TITLE_PAGE = "animated" ]; then
    mkdir $WORK_DIR/{animenu,fade}
elif [ $TITLE_PAGE = "plain" ]; then
    mkdir $WORK_DIR/fade
fi

# create black jpg for dissolve
convert  -size $VID_SIZE_OPT xc:black $WORK_DIR/black.jpg



if  [ $TARGET = "DVD" ]; then
        VID_SIZE_OPT=$DVD_VID_SIZE_OPT
        AUDIO_OPTS=$DVD_AUDIO_OPTS
        SAMPLERATE=$DVD_SAMPLERATE
        AUDIO_EXT=$DVD_AUDIO_EXT
        FFMPEG_TARGET=$DVD_FFMPEG_TARGET
        INTRO_SIZE=$DVD_INTRO_SIZE
        FFMPEG_OPTS=$DVD_FFMPEG_OPTS
        MPLEX_FORMAT=$DVD_MPLEX_FORMAT
        TITLE_FONT_SIZE=$DVD_TITLE_FONT_SIZE
        GEO_ARRAY=("${DVD_GEO_ARRAY[@]}")
fi

###############################################################################
#             get information about videos and store in an array              #
###############################################################################

for i in ${!VID_ARRAY[@]}; do
    mencoder_stats=( "${mencoder_stats[@]}" "$(mencoder "${VID_ARRAY[i]}" \
    -oac pcm -ovc copy \
    -o /dev/null)" )
done

# put in the log file in case anyone is interested
for i in ${!VID_ARRAY[@]}; do
    VCODEC="$(awk '/VIDEO:/ {gsub(/\[|\]/, ""); print $2}' \
    <<< "${mencoder_stats[i]}")"
    V_BR="$(awk '/Video stream:/{print $3}'<<<"${mencoder_stats[i]}")"
    ACODEC="$(awk  '/Selected audio codec/ {gsub(/\[|\]/, ""); print $4}' \
    <<< "${mencoder_stats[0]}")"
    A_BR="$(awk  '/AUDIO:/ {print $7}' <<< "${mencoder_stats[i]}")"
    if [ -z "$A_BR" ]; then
        A_BR="No audio found"
    fi
    ID_LENGTH="$(awk '/Video stream:/{print $10}'<<<"${mencoder_stats[i]}")"
    printf "%s\n\n" "$LINE" "$LINE" >> $BVC_LOG
    echo -e "Stats for" "${VID_ARRAY[i]}" "\n" \
    "video codec:   " \
    "$VCODEC" "\n" \
    "video bitrate: " "$V_BR" "kbps" "\n" \
    "audio codec:   " \
    "$ACODEC" "\n" \
    "audio bitrate: " \
    "$A_BR" " kbps" "\n" \
    "clip length:   " \
    "$ID_LENGTH" " seconds" "\n" >> $BVC_LOG
done


for i in ${!mencoder_stats[@]}; do
    VID_LEN=( ${VID_LEN[@]}  "$(awk '/Video stream:/{print $10}' \
    <<<"${mencoder_stats[i]}")" )
done

for i in ${!VID_LEN[@]}; do
    NEW_LENGTH=( ${NEW_LENGTH[@]}   ${VID_LEN[i]%.*} )
done

for val in ${NEW_LENGTH[@]}; do
    [ -z "$MAX_VAL" ] || ((val > MAX_VAL)) && MAX_VAL=$val
done

MAX_VAL_FRAMES="$(($MAX_VAL * 30))"
if [ $MAX_VAL_FRAMES -lt $MAX_ANI_LENGTH ]; then
    MAX_ANI_LENGTH=$MAX_VAL_FRAMES
fi

ANI_FRAMES=$MAX_ANI_LENGTH

###############################################################################
#                           End of info block                                 #
###############################################################################

###############################################################################
#                       work on the clip title images                         #
###############################################################################


# create the pics for background image and move to proper pics/ dir
for ((i=0; i<=FILES; i++)) ; do
    CREATE_JPG_CMD=(ffmpeg -i "${VID_ARRAY[$i]}" -vframes $ANI_FRAMES \
    -s "$INTRO_SIZE" "$WORK_DIR/pics/$i/%d.jpg")
#    CREATE_PNG_CMD=(mplayer -vo png:z=$PNG_COMPRESS -ao null \
#    -vf expand=-288:-192,rectangle=432:288,rectangle=430:286,rectangle=428:284,rectangle=426:282  \
#    -zoom -x 360 -y 240  -ss 0:0:01 -frames $FRAMES $ANI_FRAMES >/dev/null 2>&1
    printf "%s\n\n" "$LINE" "$LINE" >> $BVC_LOG
    echo -e "\nRunning: ${CREATE_JPG_CMD[@]}\n" | fold -bs >> $BVC_LOG

    SED_VAR="frame="
    if "${CREATE_JPG_CMD[@]}" >> $BVC_LOG.tmp 2>&1;then
        cleanlog 3
    else
        cleanlog 3
        OUTPUT="There was a problem creating jpegs from the video.\n \
        Please see the output of $BVC_LOG"
        SORRY_MSG=$OUTPUT
        sorry_msg
        exit 1
    fi

done

#  create black background
BG_PIC="$WORK_DIR/pics/template.jpg"
convert  -size $VID_SIZE_OPT xc:"#1E1E1E" $BG_PIC

FRAME_FONT="$DATA_DIR/Candice.ttf"
# font to use for our plain title text - fall back on Candice if no helvetica

if [[ $FRAME_STYLE != "fancy" ]]; then
    if convert -font Helvetica -draw "text 0,0 'test'" $BG_PIC /dev/null; then
        FRAME_FONT="Helvetica"
    elif
        convert -font helvetica -draw "text 0,0 'test'" $BG_PIC /dev/null; then
            FRAME_FONT="helvetica"
    else
        FRAME_FONT=$FRAME_FONT
    fi
fi


##############################################################################
#                     spumux and dvdauthor stuff                             #
##############################################################################

# create the Highlight png
GEO="${GEO_ARRAY[FILES]/x/,}"
SELECT_CMD="-size "${GEO_ARRAY[FILES]}+5+5" xc:none -fill none +antialias \
-stroke '#DE7F7C' -strokewidth 4 -draw 'rectangle 0,0 $GEO'"
HIGHLIGHT_CMD="-size "${GEO_ARRAY[FILES]}+5+5" xc:none -fill none +antialias \
-stroke '#188DF6' -strokewidth 4 -draw 'rectangle 0,0 $GEO'"
eval convert "$SELECT_CMD" -colors 3 "$WORK_DIR/Selectx1.png"
eval convert "$HIGHLIGHT_CMD" -colors 3 "$WORK_DIR/Highlightx1.png"

for ((i=0; i<=FILES; i++)); do 
    cp $WORK_DIR/Selectx1.png $WORK_DIR/$i-Select.png
    cp $WORK_DIR/Highlightx1.png $WORK_DIR/$i-Highlight.png
done

montage -background none "$WORK_DIR/*-Select.png" -tile ${TILE_ARRAY[FILES]} \
-geometry ${GEO_ARRAY[FILES]}+5+5 -bordercolor none -mattecolor transparent miff:- |
convert  -colors 3 -size 720x480 xc:none  - -gravity north -geometry +0+55  \
-composite  "$WORK_DIR/Select.png"

montage -background none "$WORK_DIR/*-Highlight.png" -tile ${TILE_ARRAY[FILES]} \
-geometry ${GEO_ARRAY[FILES]}+5+5 -bordercolor none -mattecolor transparent  miff:- |
convert  -size 720x480 xc:none  - -gravity north -geometry +0+55  \
-composite  "$WORK_DIR/Highlight.png"


# make xml files, and run dvdauthor and spumux
(
    cat <<EOF
<subpictures>
   <stream>
     <spu start="00:00:00.0" end="00:00:00.0"
          highlight="$WORK_DIR/Highlight.png"
          select="$WORK_DIR/Select.png"
          autooutline="infer"
          autoorder="rows"/>
   </stream>
 </subpictures>
EOF
)  > "$SPUMUX_XML"


(
    cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
<dvdauthor dest="$WORK_DIR/DVD" jumppad="1">
  <vmgm>
    <menus>
      <pgc>
        <post>jump titleset 1 menu;</post>
      </pgc>
    </menus>
  </vmgm>
  <titleset>
    <menus>
      <pgc>
$(for ((i=1; i<=$V_ARRAY_TOTAL; i++)); do
    echo -e "        <button name=\"$i\">jump title $i;</button>"
done) 
        <vob file="$WORK_DIR/menu.mpg" pause="inf"/>
      </pgc>
    </menus>
    <titles>
$(for i in ${VID_ARRAY[@]}; do
     echo -e "      <pgc>
        <vob file=\"$i\" chapters=\"0,00:15:00,00:30:00,00:45:00,01:00:00,01:15:00,01:30:00,01:45:00,02:00:00\"/>
        <post>call vmgm menu 1;</post>
      </pgc>"
done)
    </titles>
  </titleset>
</dvdauthor> 
EOF
) >> "$DVDAUTHOR_XML"

##############################################################################
#                            Animenu stuff                                   #
##############################################################################

#  create a transparant png with the title on it
convert -font $FRAME_FONT -pointsize $TITLE_FONT_SIZE -size 420x \
-gravity Center caption:"\"$TITLE_PG_TITLE\""  -negate  \( +clone -blur 0x8 \
-shade 110x45 -normalize \
$DATA_DIR/$GRADIENT  -fx 'v.p{g*v.w,0}' \)  +matte +swap \
-compose CopyOpacity -composite  $WORK_DIR/intro_txt.png

# check if we are using submenu or not
if [ $SUB_MENU = "true" ]; then 
    DVD_TILE_ARRAY=${WITH_CHAPT_TILE[@]}
fi

if [ $TITLE_PAGE = "animated" ]; then
    for ((i=0; i<=FILES; i++)); do
        JPGS=( "${JPGS[@]}" $(find $WORK_DIR/pics/$i -maxdepth 1 -name '*[1-9]*.jpg') )
        for jpg in "${JPGS[@]}"; do
            montage -geometry +4+4 -background '#1E1E1E' \
            -fill '#C6C6C6' -pointsize 22 -title "${TITLES[i]}"  $jpg miff:- |
            convert -gravity South  -chop   0x${CHOP[FILES]} +repage - miff:- |
            convert -background '#1E1E1E' -frame 5x5 \
            -bordercolor none -mattecolor "#444744" - miff:- |
            convert -resize $INTRO_SIZE! - $jpg
        done

        last_jpg="$((${#JPGS[@]} - 1))"
        next_jpg=$(($last_jpg + 1))
        if [ $last_jpg -ge $MAX_ANI_LENGTH ]; then
            :
        else
            for ((l=$next_jpg; l<=$MAX_ANI_LENGTH; l++)); do
                cp $WORK_DIR/pics/$i/$last_jpg.jpg $WORK_DIR/pics/$i/$l.jpg
            done
        fi
        unset JPGS last_jpg next_jpg
    done

    for (( count=1; count <= $MAX_ANI_LENGTH; count++)); do
        ANI_PICS=$(find $WORK_DIR/pics/*[0-9]* -maxdepth 1 -name $count.jpg)

        # make montages and composite onto grey background with title
        IM_CMD=(montage ${ANI_PICS[@]} -tile ${TILE_ARRAY[FILES]} \
        -geometry ${GEO_ARRAY[FILES]}+5+5 -background '#1E1E1E' miff:-)
        IM_CMD2=(convert $WORK_DIR/pics/template.jpg \
        $WORK_DIR/intro_txt.png  -gravity south -geometry +0+55 -composite \
        -  -gravity north -geometry +0+55 -composite \
        $WORK_DIR/animenu/$count.jpg)

        "${IM_CMD[@]}" | "${IM_CMD2[@]}" 
        rm -f ${ANI_PICS[@]}
    done
    # convert jpegs to video stream

    jpeg2yuv -v 0 -f 29.970 -I p -n $MAX_ANI_LENGTH -L 1 -b1 \
    -j $WORK_DIR/animenu/%0d.jpg |
    ffmpeg -f yuv4mpegpipe -i -  -an -vcodec mpeg4 -r 29.970 -b 2000 \
    -s $VID_SIZE_OPT -aspect 4:3 -y $INTRO_VIDEO
    # convert to proper video format
    ENC_CMD=(ffmpeg -i $INTRO_VIDEO -f mpeg2video \
    -tvstd ntsc $FFMPEG_OPTS -s $VID_SIZE_OPT -y $WORK_DIR/intro.m2v)
    if "${ENC_CMD[@]}" >> $BVC_LOG.tmp 2>&1; then
        cleanlog 3
    else
        cleanlog 3
        sorry_msg
        exit 1
    fi
fi

TIME=`vid_length "$INTRO_VIDEO"`
cat /dev/zero | nice -n 0 sox -t raw -c 2 -r 48000 -w \
-s - $WORK_DIR/intro.wav  trim 0 $TIME

# convert to proper audio format
ffmpeg -i $WORK_DIR/intro.wav \
$AUDIO_OPTS -y $WORK_DIR/intro.$AUDIO_EXT
        
# mplex intro audio and video together
INTRO_MPLEX_CMD="mplex -V -f $MPLEX_FORMAT -b 230 -o $WORK_DIR/intro.mpg \
$WORK_DIR/intro.$AUDIO_EXT $WORK_DIR/intro.m2v"
echo -e "\nRunning: $INTRO_MPLEX_CMD\n" >> $BVC_LOG.tmp 
cleanlog 1
if ${INTRO_MPLEX_CMD[@]} >> $BVC_LOG.tmp 2>&1; then
    cleanlog 1
else
    cleanlog 1
    sorry_msg
    exit 1
fi

##############################################################################
#                       Run spumux and dvdauthor and pray                    #
##############################################################################


spumux "$SPUMUX_XML" < $WORK_DIR/intro.mpg > $WORK_DIR/menu.mpg
mkdir $WORK_DIR/DVD
dvdauthor -x "$DVDAUTHOR_XML"

echo -e "Your new DVD is ready to burn at $WORK_DIR/DVD"

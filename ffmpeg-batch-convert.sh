#!/bin/bash
#sourceExtension=$1; targExt=$2; targExt=$3; targExt=$4; targExt=$5; targExt=$6; targExt=$7; targExt=$8; targExt=$9 
#extensionInputs=$@
# sh ffmpeg-batch-convert.sh mp4 mov mkv avi flv # example call; # e.g. "flv", "mpg", "ts", "wmv", "flv", "avi", "mkv", "mov", "mp4"
#IFS=$'\n'; set -f
for sourceExtension in "$@" # Use "$@" to represent all the arguments
do
for sourceFile in $(find . -iname "*.$sourceExtension") # *: zero or more occurrences of preceding character; -iname is case-insensitive
do
  read -t 0.25 -N 1 input # 
  if [[ $input = "q" ]] || [[ $input = "Q" ]]; then # make flag check into a func pass arg
    echo BREAKING; break
  fi
  targExt="mkv" #"targetExtension"
  #targetFile="${sourceFile%.*}.$targetExtension" #ffmpeg -y -i "$sourceFile" "$targetFile" # -y = force overwrite
  #targetFile="${sourceFile%.*}.$targetExtension" #ffmpeg -y -i "$sourceFile" "$targetFile" # -y = force overwrite
  # a.*b matches any string that contains an "a", and then the character "b" at some later point.
  targetFile=${sourceFile%.*}'-x265' #echo $targetFile
  # here {} does parameter expansion it takes the variable or expression within the braces and expands it to whatever it represents
  # e.g. echo ${month[3]} -> month=("Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec")
  #nice -19 ffmpeg -hide_banner -loglevel error -y -i "$sourceFile" -c:v libx265 -x265-params -lossless -tag:v hvc1 -c:a aac "$targetFile.$targExt" 2>/dev/null & # converting to h265 codec
  file=$targetFile.$targExt
  if [ $sourceExtension = "mpg" ] 
  then
  # if extension is mpg
  # fix "Starting new cluster due to timestamp" warning - has to re-encode whole things 2x - indicates it's probably due to a MKV remuxing bug.
  # max_interleave_delta: Set maximum buffering duration for interleaving. The duration is expressed in microseconds, and defaults to 10000000 (10s)
  # If set to 0, libavformat will continue buffering packets until it has a packet for each stream, regardless of the maximum timestamp difference between the buffered packets
  # warning msg still appears, but doesn't seem to re-encode everything from the beggining
    nice -19 ffmpeg -y -i "$sourceFile" -c:v libx265 -x265-params -lossless -max_interleave_delta 0 -avoid_negative_ts make_zero -tag:v hvc1  -c:a aac "$targetFile"."$targExt"
    # avoid_negative_ts expl - https://superuser.com/questions/1167958/video-cut-with-missing-frames-in-ffmpeg
    # corrupt frames might be due to frames without timestamps - then extract to raw bitstream and then transcode
  else
    nice -19 ffmpeg -v quiet -stats -y -i "$sourceFile" -c:v libx265 -x265-params -lossless -tag:v hvc1 -c:a aac "$targetFile"."$targExt"
  fi
  # wc: reads standard input or a list of computer files and generates one or more of the following statistics: newline count, word count, and byte count (-c)
  # Divide a file into several parts (columns); Writes to standard output selected parts of each line of each input file, or standard input if no files are given or for a file name of '-'.
  # cut - remove sections from each line of files; Print selected parts of lines from each FILE to standard output
  # | (vertical bar/pipe) - pipe 1 cmd's output into another
  # i="$sourceFile"; j="$targetFile" # $(du -b "") # --si -h
  #I=`wc -c $sourceFile | cut -d' ' -f1`; J=`wc -c $file | cut -d' ' -f1` #echo $I; echo; echo $J
  I=`wc -c $sourceFile | cut -d' ' -f1`; J=`wc -c $targetFile.$targExt | cut -d' ' -f1` #echo $I; echo; echo $J
  # # get size in bytes only; cut empty string, select nth field only # echo $K; #echo $L #: ' # comment block start
 if [ "$I" -ge "$J" ] #; then # =, == are for string comparisons, -eq for numeric; comparison operator https://tldp.org/LDP/abs/html/comparison-ops.html
#   # # du -H short for disk usage, is used to estimate file space usage
then
#   #       #echo $i $j >> $1.pares
#   #       #./Recycle.exe $i
#   #       #%USERPROFILE%/Desktop/Recycle.exe $i #  %userprofile% usually is c:\Users\username = "cd ~/" - needs powerhsell
#   #       # ^ "fg: no Job Control"
#   #       # chng dir w/ cd /d C:\...\... to exe Recycle, but then would need to come back there; so use full path
      echo 'deleting original'
      C:/Users/el15kd/Desktop/Recycle.exe "$sourceFile" # delete w/o moving to recycle bin 
        #"${$targetFile.$targExt//-x265/}" # echo $file
        #"${file}" "${file/000/}"
        #"${file//-x265/}"
      mv "$targetFile"."$targExt" "`echo "$targetFile"."$targExt" | sed 's/-x265//'`" # Both arguments are wrapped in quotes to support spaces in the filenames
      # if only two files are given, it renames the first as the second.
#   # # Moving files manually into the Recycle Bin folder is a BAD idea. The Recycle Bin is not just a simple folder, it is a system shell folder that 
#   # # maintains a list of deleted files in an INFO file. If you manually put files in it, the bin will not see them and you will not be able to restore them
#   # # rm, move, del delete files like SHIFt+Delete does
#   # # Consider GUI automation, i.e. simulating clicks, key presses - here selecting file, pressing the delete key
#   # # Found Recycle.exe to work - Recycle /? to see switches
#   # # if you can't delete a file that has a reserved name in Windows' space, specify the full file path w/ special syntax;
#   # # e.g. delete lpt1 in WinXP: "del \\?\c:\path_to_file\lpt1"
    elif [ "$J" -ge "$I" ]
    then
      echo 'deleting converted'
      C:/Users/el15kd/Desktop/Recycle.exe "$targetFile"."$targExt" #./Recycle.exe $j 
    else
      :
    fi 
    read -t 0.25 -N 1 input # scan for q to quit; else CTRL-Z to finish current conversion, pause, then fg to resume
    if [[ $input = "q" ]] || [[ $input = "Q" ]]; then
      echo; echo BREAKING; break
   fi
  # kill an unresponsive process  ps ax | grep foo; first number is PID, then kill -s QUIT $PID
done
done
#unset IFS; set +f;
: <<'END'
var=/path/to/some/file.ext; 
      echo "${var#*/}" # outputs path/to/some/file.ext; 
      echo "${var%/*}" # outputs /path/to/some 
# Cleanup; reference - https://github.com/joeyhoer/gifv/blob/master/gifv.sh
if [$cleanup]; then
    if filename.*.size>filename.new*.size rm "$filename.*"
    fi
fi
# Automatically set output filename, if not defined
if [ -z "$output" ]; then
  # Strip off extension and add new extension
  ext="${filename##*.}"
  path=$(dirname "$filename")
  output="$path/$(basename "$filename" ".$ext").mp4"
fi
-x           Remove the original file
PROGNAME=$(basename "$0")
VERSION='1.1.2'

print_help() {
cat <<EOF
Usage:    $PROGNAME [options] input-file
Version:  $VERSION
Convert GIFs and videos into GIF-like videos
Options: (all optional)
  -c CROP      The x and y crops, from the top left of the image (e.g. 640:480)
  -d DIRECTION Directon (normal, reverse, alternate) [default: normal]
  -l LOOP      Play the video N times [default: 1]
  -o OUTPUT    The basename of the file to be output. The default is the
               basename of the input file.
  -r FPS       Output at this (frame)rate.
  -s SPEED     Output using this speed modifier. The default is 1 (equal speed).
  -t DURATION  Speed or slow video to a target duration
  -O OPTIMIZE  Change the compression level used (1-9), with 1 being the
               fastest, with less compression, and 9 being the slowest, with
               optimal compression. The default compression level is 6.
  -p SCALE     Rescale the output (e.g. 320:240)
  -x           Remove the original file/CLEANUP
Example:
  gifv -c 240:80 -o gifv.mp4 -x video.mov
EOF
exit $1
}
while getopts "c:d:l:o:p:r:s:t:O:xh" opt; do # parse cmd line args; obtains options and their arguments from a list of parameters
  case $opt in
    c) crop=$OPTARG;;
    d) direction_opt=$OPTARG;;
    h) print_help 0;;
    l) loop=$OPTARG;;
    o) output=$OPTARG;;
    p) scale=$OPTARG;;
    r) fps=$OPTARG;;
    s) speed=$OPTARG;;
    t) target_duration=$OPTARG;;
    O) level=$OPTARG;;
    x) cleanup=1;;
    *) print_help 1;;
  esac
done
# Print help, if no input file
[ -z "$filename" ] && print_help 1
END
#'
# For forensic examiners the way in which the Recycle Bin works has changed over the years.  Gone is the INFO2 file (that tracked the files contained in the Recycle Bin).
# the ‘$’ means that the Recycle Bin belongs to the system, but from testing we can tell that $Recycle.Bin is on the Windows Drive (usually ‘C’) and $RECYCLE.BIN is normally written to a drive attached to a Windows system (such as a secondary drive on a computer, or an external drive attached to a computer).
# Inside the $Recycle.Bin in this case, experienced examiners will notice that the long alpha numeric folders are the SID (Security Identifier) that identifies each user on the computer.  This is significant because it means that each user has their own Recycle Bin.
# Files starting with $I are essentially the metadata for the particular file that was deleted
# starting with $R are the content of the actual files.  In other words the files deleted from this account
# a deleted file never even moves… It doesn’t even “go to” recycle bin.
# To understand this, you need to know what is the Recycle Bin. Window desktop Recycle Bin is not a actual folder that could store files. It is a virtual folder that collects information about deleted file — their location, deletion date and file size…then it displays these information to you in a user-friendly way so you can view and perform further actions like permanent delete or restore.
# Under each drive or partition, there is a hidden folder related to recycle bin. In Windows Vista and above versions it is called $Recycle.Bin. $Recycle.Bin is the actual recycle bin. When you click into these folders, you will see deleted files. This doesn’t mean the actual data of deleted are moved to $Recycle.Bin, it’s just the index (or pointer) has changed. The raw data never moved during the whole process.
# When you delete a file, the raw data (the ones and zeros on the physical media) are still where they are. Their address changed to respective $Recycle.Bin folder. The desktop Recycle Bin collects info from all $Recycle.Bin folder and presents the info to you.
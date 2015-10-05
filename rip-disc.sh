#!/bin/dash

TMPDIR=`mktemp -d '/tmp/rip-disc.XXX'`
DESTDIR=`pwd`
TAGGER=`which picard`
RELEASE_ID=''

while getopts 't:d:r:c:' OPT; do
  case $OPT in
    t)
      echo "Setting TMPDIR to $OPTARG."
      TMPDIR=$OPTARG
      ;;
    d)
      echo "Setting DESTDIR to $OPTARG."
      DESTDIR=$OPTARG
      ;;
    r)
      echo "Setting RELEASE_ID to $OPTARG."
      echo "... See release on MusicBrainz: https://musicbrainz.org/release/$OPTARG"
      RELEASE_ID=$OPTARG
      ;;
    c)
      echo "Using disk drive $OPTARG."
      DRIVE=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

TRACK_TEMPLATE='%A - %d (%y) [%X]/%t. %a - %n'
DISC_TEMPLATE='%A - %d (%y) [%X]/%A - %d'

_ripcmd="rip cd --device='$DRIVE' rip \
--logger whatcd --working-directory='$TMPDIR' --output-directory='' \
--track-template='$TRACK_TEMPLATE' --disc-template='$DISC_TEMPLATE' \
--release-id='$RELEASE_ID'"

echo "Ripping to: $TMPDIR"
echo '... Ripping the CD.'
echo "    Using: $_ripcmd"

rip cd --device="$DRIVE" rip \
--logger whatcd --working-directory="$TMPDIR" --output-directory='' \
--track-template="$TRACK_TEMPLATE" --disc-template="$DISC_TEMPLATE" \
--release-id="$RELEASE_ID" || exit 1

discdir=`ls $TMPDIR/`
echo "... Working with $discdir."

echo '... Calculating ReplayGain.'
metaflac --preserve-modtime --add-replay-gain $TMPDIR/*/*.flac

echo '... Additionally tag files.'
$TAGGER "$TMPDIR/$discdir"

echo '... Submitting to AcousticBrainz.'
find "$TMPDIR/$discdir" -name '*.flac' -print0 | parallel --null --eta abzsubmit

# echo '... Generating torrent file.'
# mktor ...

echo '... Compress into archive.'
7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -mmt=on "$TMPDIR/$discdir.7z" "$TMPDIR/$discdir"

echo '... Moving archive.'
rsync -avz --remove-sent-files --progress "$TMPDIR/$discdir.7z" "$DESTDIR" && rm -rf "$TMPDIR/$discdir"

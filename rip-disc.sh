#!/bin/dash

TMPDIR=`mktemp -d '/tmp/rip-disc.XXX'`
DESTDIR=`pwd`
TAGGER=`which picard`
RELEASE_ID=''

TRACK_TEMPLATE='%A - %d (%y) [%X]/%t. %a - %n'
DISC_TEMPLATE='%A - %d (%y) [%X]/%A - %d'

echo "Ripping to $TMPDIR."

echo '... Ripping the CD.'
rip cd rip \
--logger whatcd --working-directory="$TMPDIR" --output-directory='' \
--track-template="$TRACK_TEMPLATE" --disc-template="$DISC_TEMPLATE" \
--release-id="$RELEASE_ID"

discdir=`ls $TMPDIR/`
echo "... Working with $discdir."

echo '... Calculating AcoustIDs.'
acoustid-fingerprinter

echo '... Calculating ReplayGain.'
metaflac --preserve-modtime --add-replay-gain $TMPDIR/*/*.flac

# echo '... Additionally tag files.'
$TAGGER $TMPDIR/*

# echo '... Generating torrent file.'
# mktor ...

echo '... Compress into archive.'
7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$TMPDIR/$discdir.7z" "$TMPDIR/$discdir"

echo '... Moving archive.'
rsync -avz --remove-sent-files --progress "$TMPDIR/$discdir.7z" "$DESTDIR" && rm -rf "$TMPDIR/$discdir"

echo '... Cleaning up.'
cd $HOME
rmdir $TMPDIR

#!/bin/dash

# Copyright © 2013–2017 Frederik “Freso” S. Olesen <https://freso.dk/>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

TMPDIR=`mktemp -d '/tmp/rip-disc.XXX'`
DESTDIR=`pwd`
TAGGER=`which picard`
RELEASE_ID=''
DRIVE='/dev/cdrom'

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

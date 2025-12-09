#!/usr/bin/env bash
set -euo pipefail

TEMPLATE="evolving_drone_template.csd"
OUTDIR="drones_out"
TMPDIR="$(mktemp -d /tmp/csound_drones.XXXXXX)"
N=2
DURATION=900         # seconds for each generated sample
BITS=16             # bits per sample (csound default will produce 16-bit-ish WAV unless you change flags)
VERBOSE=1

mkdir -p "$OUTDIR"

echo "Using template: $TEMPLATE"
echo "Output dir: $OUTDIR"
echo "Temp dir: $TMPDIR"
echo "Generating $N files, ${DURATION}s each..."

for i in $(seq 1 $N); do
    # random abstract macro in [0,1] with 3 decimal places
    MORPH=$(awk -v min=0 -v max=1 'BEGIN{srand(); printf "%.3f", min + rand()*(max-min)}')

    # integer seed for RNG in csound instrument
    SEED=$(( (RANDOM << 15) + RANDOM ))

    # create a filename containing index, morph, and seed for traceability
    FNAME=$(printf "drone_%03d_m%0.3f_s%d.wav" "$i" "$MORPH" "$SEED")
    OUTPATH="$OUTDIR/$FNAME"

    # prepare a temporary csd by replacing placeholders
    TMP_CSD="$TMPDIR/temp_$i.csd"
    sed -e "s/__DURATION__/${DURATION}/g" \
        -e "s/__MORPH__/${MORPH}/g" \
        -e "s/__SEED__/${SEED}/g" \
        "$TEMPLATE" > "$TMP_CSD"

    if [ "$VERBOSE" -gt 0 ]; then
        echo "[$i/$N] morph=${MORPH} seed=${SEED} -> $OUTPATH"
    fi

    # render using csound: write to WAV
    # Note: csound typically accepts: csound -o output.wav infile.csd
    # This will block until rendering finishes.
    csound -o "$OUTPATH" "$TMP_CSD"

    # small sleep to avoid completely hammering disk/CPU on some systems (optional)
    sleep 0.05
done

echo "All done. Files are in $OUTDIR"
echo "Temporary csds left in $TMPDIR (remove when done)."

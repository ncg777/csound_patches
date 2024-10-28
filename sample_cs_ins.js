var notes = ['C','C#','D','D#', 'E','F','F#','G','G#','A','A#', 'B']
var csd = arguments[0];
csd = csd.replace("/","\\");

var ins = arguments[1];
var targetdir = arguments[2];

var start_oct = Number(arguments[3]);
var end_oct = Number(arguments[4]);
var samples_per_oct = Number(arguments[5]);
var vel_pow_of_2 = Number(arguments[6]); // 0, 1 or 2
var short_or_long = arguments[7]; // short or long

var k = 12/samples_per_oct;

for(i=(start_oct*12);i<(end_oct*12);i+=k)
{
	l = (i % 12);
	n = notes[l];
	o = (i-l) / 12;
	vi = 128/Math.pow(2,vel_pow_of_2);
	
	for(v=128; v>=0; v-=vi)
	{
		sname = ins + " " + n + o + " v" + (v-1) + ".wav";

		runCommand("csound", "--midifile=d:\\Music making\\mid_notes_" + short_or_long + "\\" + n + String(o) + " v" + String(v-1) + ".mid", "--output=" + targetdir + "\\" + sname + "", "--nodisplays", csd);
	}
}
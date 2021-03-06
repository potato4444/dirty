module main
import types, stacks, runtime, parser
import StdEnv, StdLib, System.CommandLine, System.IO, System.File, Data.Error
Start world

	# ([_:args], world)
		= getCommandLine world
	//# args = ["-utf8", "--numeric-output", "--dump-stacks", "tests/stack_test_main.txt"]
	| isEmpty args
		= abort usage
	# (flags, [file:args])
		= span (\e -> e%(0,0) == "-") args
	# (flags, format)
		= partition (\e -> e%(0,1) == "--") flags
	# parser
		= case format of
			[] = parseNative
			["-utf8"] = parseUTF8
			_ = abort "Cannot parse the given format!"
	# (file, world)
		= case (readFile file world) of
			(Ok file, world) = (file, world)
			_ = abort "Cannot open the file specified!"

	//# lhs = {stack=[!1, 2, 3], bounded=True}
	//# rhs = {stack=[!7, 6, 5], bounded=True}
	//# val = forEach inc (lhs + rhs + zero)
	//= reduce (+) zero val
	= let program = parser file
	in (construct program (toFlags flags)) (initialize program args world)
	
toFlags flags
	= {debug = False, dump = isMember "--dump-stacks" flags, nums = isMember "--numeric-output" flags, strict = isMember "--strict-args" flags}
	
usage :== foldr ((+++)) ""
	["Usage: dirty [<config>] [-format] [--flags] <file> [<stack>]\n"
	,"\t-utf8: use the UTF-8 parser\n"
	,"\t--numeric-output: numeric output for write commands\n"
	,"\t--dump-stacks: show the stacks on termination\n"
	,"\t--strict-args: never take two arguments from the middle stack\n"
	//,"\t--g: take args greedily"
	]
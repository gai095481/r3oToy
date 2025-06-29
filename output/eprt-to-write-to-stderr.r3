Rebol []

eprt: function [
    {Output / write any datatype to stderr.}
   the-value-to-write [any-type!]
   /no-nln "Suppress newline output."
][
	secure [file allow]
	stderr: open %/dev/stderr
	write stderr the-value-to-write

	if not no-nln [write stderr newline]
	close stderr
]

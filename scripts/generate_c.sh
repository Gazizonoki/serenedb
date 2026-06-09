#!/bin/sh

TOOL="$1"
OUTPUT="$2"
INPUT="$3"

if test "x$TOOL" = x -o "x$OUTPUT" = x -o "x$INPUT" = x; then
	echo "usage: $0 <tool> <output> <input>"
	exit 1
fi

PREFIX=$(echo ${OUTPUT} | sed -e 's:\.cpp$::')

# clean up after ourselves
trap "rm -f ${PREFIX}.tmp" EXIT TERM HUP INT

TOOL_NAME=$(basename "${TOOL}")

case "${TOOL_NAME}" in
bison*)
	MAJOR_VER=$(${TOOL} --version 2>/dev/null | grep -i bison | head -1 | sed -e "s;.* ;;" -e "s;\..*;;")
	if test -n "${MAJOR_VER}" && test "${MAJOR_VER}" -ge "3" 2>/dev/null; then
		${TOOL} -d --warnings=deprecated,other,error=conflicts-sr,error=conflicts-rr \
			-o "${OUTPUT}" "${INPUT}"
	else
		${TOOL} -d -o "${OUTPUT}" "${INPUT}"
	fi
	test -f "${PREFIX}.hpp" || exit 1
	test -f "${PREFIX}.cpp" || exit 1
	echo "/* clang-format off */" | cat - "${PREFIX}.hpp" >"${PREFIX}.tmp"
	cp "${PREFIX}.tmp" "${PREFIX}.hpp"
	;;
flex*)
	${TOOL} -L -o "${OUTPUT}" "${INPUT}"
	test -f "${PREFIX}.cpp" || exit 1
	;;
*)
	echo "Unknown tool: ${TOOL_NAME}"
	exit 1
	;;
esac

echo "/* clang-format off */" | cat - "${PREFIX}.cpp" | sed 's/[[:space:]]*$//' >"${PREFIX}.tmp"
# ensure file ends with exactly one newline
printf '%s\n' "$(cat "${PREFIX}.tmp")" >"${PREFIX}.cpp"

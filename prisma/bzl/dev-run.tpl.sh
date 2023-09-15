#! /bin/sh

set -e

export RUNFILES_DIR=${RUNFILES_DIR:-"$0.runfiles"}

export {{DB_ENV_VAR}}="$(${RUNFILES_DIR}/{{DB_URL_BIN}})"

export BAZEL_BINDIR=.

# Migrations get written relative to the schema.
# So we must use the schema in the workspace to get the migrations into the source tree.
SCHEMA_ARG="--schema $BUILD_WORKSPACE_DIRECTORY/{{SCHEMA_PATH}}"

# Automatically add --schema and --skip-generate where appropriate.
# Also prevent use of unsupported commands.
case "$1 $2" in
    version\ *)
	ARGS=""
	;;
    -v\ *)
	ARGS=""
	;;
    init\ *)
	echo "Instead of using prisma init, set up the relevant prisma bazel rules." >&2
	exit 2
	;;
    generate\ *)
	echo "Instead of using prisma generate, use the prisma_generate bazel rule." >&2
	exit 2
	;;
    introspect\ *)
	echo "Instead of using prisma instrospect, use db pull." >&2
	exit 2
	;;
    validate\ *)
	echo "The prima_schema rule automatically validates the prisma schema." >&2
	exit 2
	;;
    format\ *)
	ARGS="$SCHEMA_ARG"
	;;
    "db pull")
	ARGS="$SCHEMA_ARG"
	;;
    "db push")
	ARGS="$SCHEMA_ARG --skip-generate"
	;;
    "db seed")
	ARGS=""
	;;
    "db execute")
	ARGS="$SCHEMA_ARG"
	;;
    "migrate dev")
	ARGS="$SCHEMA_ARG --skip-generate"
	;;
    "migrate reset")
	ARGS="$SCHEMA_ARG --skip-generate"
	;;
    "migrate deploy")
	ARGS="$SCHEMA_ARG"
	;;
    "migrate resolve")
	ARGS="$SCHEMA_ARG"
	;;
    "migrate status")
	ARGS="$SCHEMA_ARG"
	;;
    "migrate diff")
	# Schema might be from or to target.
	# Let the user decide.
	ARGS=""
	;;
    *)
	echo "Unknown prisma command '$1 $2'" >&2
	echo "Please file a bug if you feel this is a mistake" >&2
	exit 2
esac

exec "${RUNFILES_DIR}/{{PRISMA_TOOL}}" "$@" $ARGS

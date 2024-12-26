# Build everything so I can easily preview it.
SERVER_OPTS = --buildExpired --buildDrafts --buildFuture
# Copy all files when static files change, otherwise they won't be served.
SERVER_OPTS += --forceSyncStatic

all: server
server:
	hugo server $(SERVER_OPTS)
debug_server: SERVER_OPTS += --debug --verbose --ignoreCache --path-warnings
debug_server: SERVER_OPTS += --log --logFile debug_server.log --verboseLog
debug_server: server

tags_list:
	# Lines look like: tags = ['advice', 'general computer stuff']
	# Turn tags with spaces into tags_with_spaces.  Put each tag on a single
	# line with the number of times it is used.
	grep -h '^tags =' content/blog/* \
		| sed -e "s/tags = \\['//" \
			-e "s/']//" \
			-e "s/', '/,/g" \
			-e "s/ /_/g" \
			-e "s/,/ /g" \
		| fmt -1 \
		| sort -f \
		| uniq -c

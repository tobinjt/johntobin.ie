# Build everything so I can easily preview it.
SERVER_OPTS = --buildExpired --buildDrafts --buildFuture
# Copy all files when static files change, otherwise they won't be served.
SERVER_OPTS += --forceSyncStatic
# Hugo regenerates every file, so compare checksums rather than
# timestamps and don't synchronise timestamps.
RSYNC_OPTS = -av --delete --checksum --no-times
DESTINATION = www.johntobin.ie:/var/www/sites/johntobin.ie/
OUTPUT_DIR = public/

all: server
server:
	hugo server $(SERVER_OPTS)
debug_server: SERVER_OPTS += --debug --verbose
debug_server: server

generate: clean
	hugo
push: generate
	git push
	git check-local-copy-is-clean
	rsync $(RSYNC_OPTS) $(OUTPUT_DIR) $(DESTINATION)
diff: RSYNC_OPTS += --dry-run
diff: generate
	rsync $(RSYNC_OPTS) $(OUTPUT_DIR) $(DESTINATION)

diff_content: generate
	rsync $(RSYNC_OPTS) $(DESTINATION) hosting/
	# The generator line changes every time Hugo is upgraded, so ignore
	# changes there.
	diff -Naur -I '.*<meta name="generator" content="Hugo .*" />' \
		hosting/ $(OUTPUT_DIR)

clean:
	rm -rf $(OUTPUT_DIR)

list_fontawesome_classes: generate
	grep -h -r fa- $(OUTPUT_DIR) | sort | uniq -c | sort -n
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

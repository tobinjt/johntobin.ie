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
debug_server: SERVER_OPTS += --debug --verbose --ignoreCache --path-warnings
debug_server: SERVER_OPTS += --log --logFile debug_server.log --verboseLog
debug_server: server

generate: clean
	hugo
push: generate
	git push
	rsync $(RSYNC_OPTS) $(OUTPUT_DIR) $(DESTINATION)
	ssh -t hosting 'sudo touch /var/cache/mod_pagespeed/cache.flush'
	check_website_resources check_website_resources.json
	git check-local-copy-is-clean
diff: RSYNC_OPTS += --dry-run
diff: generate
	rsync $(RSYNC_OPTS) $(OUTPUT_DIR) $(DESTINATION)

diff_content: generate
	rsync $(RSYNC_OPTS) $(DESTINATION) hosting/
	# Ignore meaningless changes.
	diff -Naur \
		--ignore-tab-expansion \
		--ignore-space-change \
		--ignore-blank-lines \
		-I '.*<meta name="generator" content="Hugo .*" />' \
		-I '.*<meta property="article:modified_time" content=.*/>' \
		-I '.*<meta property="article:published_time" content=.*/>' \
		-I '.*<meta property="og:updated_time" content=.*/>' \
		hosting/ $(OUTPUT_DIR)

check-links:
	check-links https://www.johntobin.ie/

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

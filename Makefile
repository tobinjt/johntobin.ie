all: server
SERVER_OPTS =
server:
	hugo server --buildExpired --buildDrafts --buildFuture \
		--forceSyncStatic $(SERVER_OPTS)
debug_server: SERVER_OPTS = --debug --verbose
debug_server: server

RSYNC_OPTS =
HUGO_OPTS =
generate: HUGO_OPTS =
generate: generate_base
generate_base: clean
	hugo $(HUGO_OPTS)
push: copy
copy: generate
	git check-local-copy-is-clean
	# Hugo regenerates every file, so compare checksums rather than
	# timestamps and don't synchronise timestamps.
	rsync -av --delete --checksum --no-times $(RSYNC_OPTS) \
		public/ hosting:/var/www/sites/johntobin.ie/
diff: RSYNC_OPTS = --dry-run
diff: copy

diff_content: generate
	rsync -av --delete hosting:/var/www/sites/johntobin.ie/ hosting/
	diff -aur hosting/ public/

clean:
	rm -rf public/

generate_no_minify: HUGO_OPTS =
generate_no_minify: generate_base
list_fontawesome_classes: generate_no_minify
	grep -h -r fa- public | sort | uniq -c | sort -n

tags_list: generate
	ls public/tags/

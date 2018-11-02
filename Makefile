all: server
SERVER_OPTS =
server:
	hugo server --buildExpired --buildDrafts --buildFuture $(SERVER_OPTS)
debug_server: SERVER_OPTS = --debug --verbose
debug_server: server

RSYNC_OPTS =
generate: clean
	hugo
copy: generate
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

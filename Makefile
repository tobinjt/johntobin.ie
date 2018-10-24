all: server
server:
	hugo server --buildExpired --buildDrafts --buildFuture

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

clean:
	rm -rf public/

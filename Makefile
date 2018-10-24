RSYNC_OPTS =
all: clean
	hugo

diff: RSYNC_OPTS = --dry-run
diff: copy

copy: all
	# Hugo regenerates every file, so compare checksums rather than
	# timestamps and don't synchronise timestamps.
	rsync -av --delete --checksum --no-times $(RSYNC_OPTS) \
		public/ hosting:/var/www/sites/johntobin.ie/
clean:
	rm -rf public/
server:
	hugo server --buildExpired --buildDrafts --buildFuture

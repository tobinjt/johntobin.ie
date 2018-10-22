all: clean
	hugo
copy: all
	# Hugo regenerates every file, so compare checksums rather than
	# timestamps and don't synchronise timestamps.
	rsync -av --delete --checksum --no-times public/ \
		hosting:/var/www/sites/johntobin.ie/
clean:
	rm -rf public/
server:
	hugo server --buildExpired --buildDrafts --buildFuture

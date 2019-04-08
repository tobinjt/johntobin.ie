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
push: copy
copy: generate
	git check-local-copy-is-clean
	rsync $(RSYNC_OPTS) $(OUTPUT_DIR) $(DESTINATION)
diff: RSYNC_OPTS += --dry-run
diff: copy

diff_content: generate
	rsync $(RSYNC_OPTS) $(DESTINATION) hosting/
	diff -aur hosting/ $(OUTPUT_DIR)

clean:
	rm -rf $(OUTPUT_DIR)

list_fontawesome_classes: generate
	grep -h -r fa- $(OUTPUT_DIR) | sort | uniq -c | sort -n
tags_list: generate
	ls $(OUTPUT_DIR)tags/

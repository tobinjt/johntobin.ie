all: clean
	hugo
copy: all
	rsync -av public/ hosting:/var/www/sites/johntobin.ie/
clean:
	rm -rf public/

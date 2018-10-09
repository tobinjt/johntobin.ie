all:
	hugo
copy: all
	rsync -av public/ hosting:/var/www/sites/johntobin.ie/

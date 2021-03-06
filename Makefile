#!/usr/bin/make

default:	README.html

.SUFFIXES:
.SUFFIXES:	.md .html .pdf

.md.html:
	@pandoc --css article.css --to html4 --output $@ --self-contained --standalone --section-divs $<

.md.pdf:
	@pandoc --css article.css --to latex --output $@ --self-contained --standalone --section-divs $<

.PHONY: clean
clean:
	@$(RM) -rf README.html README.pdf

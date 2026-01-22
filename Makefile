#!/usr/bin/make

default:	README.html

.SUFFIXES:
.SUFFIXES:	.md .html .pdf

.md.html:
	@pandoc --from markdown --css article.css --to html4 --output $@ --embed-resources --standalone --section-divs $<

.md.pdf:
	@pandoc --from markdown  --css article.css --to latex --output $@ --embed-resources --standalone --section-divs $<

.PHONY: clean
clean:
	@$(RM) -rf README.html README.pdf

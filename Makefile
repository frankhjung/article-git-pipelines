#!/usr/bin/make

default:	README.html

.SUFFIXES:
.SUFFIXES:	.md .html .pdf

.md.html:
	@pandoc --from markdown --css article.css --to html4 --output $@ --self-contained --standalone --section-divs $<

.md.pdf:
	@pandoc --from markdown  --css article.css --to latex --output $@ --self-contained --standalone --section-divs $<

.PHONY: clean
clean:
	@$(RM) -rf README.html README.pdf

#!/usr/bin/make

default:	README.html

.SUFFIXES:
.SUFFIXES:	.md .html .pdf

.md.html:
	@mkdir -p public
	@pandoc --css article.css --to html4 --output public/$@ --self-contained --standalone --section-divs $<
	@cp -p public/$@ public/index.html

.md.pdf:
	@mkdir -p public
	@pandoc --css article.css --to latex --output public/$@ --self-contained --standalone --section-divs $<

.PHONY: clean
clean:
	@$(RM) -rf public

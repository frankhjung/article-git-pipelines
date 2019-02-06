#!/usr/bin/make

.PHONY: clean cleanall
.SUFFIXES: .md .html
.DEFAULT: render
TARGET := README.html

.md.html:
	@pandoc --css article.css --to html4 --output $@ --self-contained --standalone --section-divs $<

render: ${TARGET}

clean:
	@$(RM) -rf README.html

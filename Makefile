.PHONY: all docs pydeps jsdeps

ENV = venv

all: bundle.js docs

pydeps:
	test -d $(ENV) || virtualenv $(ENV)

jsdeps:
	npm install

docs: bundle.js pydeps
	# put the javascript, stylesheets, favicon, and html in docs/
	mkdir -p docs-output
	. $(ENV)/bin/activate && pip install -r requirements.txt && ./make_template.py
	cp -r docs/* bundle.js index.html docs-output
	# now switch to the other branch, move everything out of docs, commit, and push
	git checkout gh-pages
	rm -rf stylesheets image favicon.ico bundle.js index.html
	cp -r docs-output/* .
	git add .
	git commit -anm "Automatic commit by $(shell git config --get user.name) ($(shell git config --get user.email))"
	git push
	git checkout master

bundle.js: jsdeps
	./node_modules/.bin/browserify -t [ reactify --es6 ] js/*.jsx -o bundle.js

test: jsdeps
	mocha --reporter spec --compilers jsx:test/compiler.js test/test-helper.js test/*test.jsx

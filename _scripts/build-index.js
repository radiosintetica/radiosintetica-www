#!/usr/bin/env node

'use strict';

const assets = __dirname + '/../_site/assets/js';
const fs = require('fs');
const elasticlunr = require(assets + '/elasticlunr.min.js');
const data = JSON.parse(fs.readFileSync(assets + '/content.json'));

const fname = 'index.json';
console.log('Build: ' + fname);

var index = elasticlunr();

index.pipeline.remove(elasticlunr.stemmer);
index.pipeline.remove(elasticlunr.stopWordFilter);
index.pipeline.remove(elasticlunr.trimmer);

index.setRef('id');
index.addField('title');
index.addField('body');
index.addField('url');

data.forEach(function(doc, key) {
	doc.id = key + 1;
	index.addDoc(doc);
});

var out = index.toJSON();
for(var id in out.documentStore.docs) {
	delete out.documentStore.docs[id].body;
}
fs.writeFileSync(assets + '/' + fname, JSON.stringify(out));

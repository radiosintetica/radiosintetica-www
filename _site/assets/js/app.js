onLoaded(function() {
	var postToc = window['post-toc'];
	if(postToc) {
		var ul, li;
		document.querySelectorAll('h2,h3').forEach(function(item) {
			if(item.tagName == 'H2') {
				ul = postToc;
			} else if(ul == postToc) {
				ul = document.createElement('ul');
				li.appendChild(ul);
			}

			li = document.createElement('li');
			ul.appendChild(li);
			var a = document.createElement('a');
			a.setAttribute('href', '#' + item.id);
			a.innerText = item.innerText;
			li.appendChild(a);
		});
	}
});

(function() {
'use strict';

var searchIndex = null,
	searchOpts = {
		bool: "AND",
		expand: true,
		fields: {
			title: { boost: 2 },
			body: { boost: 1 },
		},
	},
	searchBar = window['search-bar'],
	searchClear = window['search-clear'],
	tagSelect = window['tag-select'];

function clear() {
	document.querySelectorAll('.blog-item.d-none').forEach(function(item) {
		item.classList.remove('d-none');
	});
}

function doFilter(val) {
	document.querySelectorAll('.blog-item:not(.d-none)').forEach(function(item) {
		if(item.dataset.tags.split(',').indexOf(val) == -1) item.classList.add('d-none');
	});
}

function doSearch(val) {
	var urls = [];
	searchIndex.search(val, searchOpts).forEach(function(item) {
		urls.push(item.doc.url);
	});
	document.querySelectorAll('.blog-item:not(.d-none)').forEach(function(item) {
		if(urls.indexOf(item.dataset.url) == -1) item.classList.add('d-none');
	});
}

function tagSelectHandler() {
	clear();
	if(!!this.value) doFilter(this.value);
	if(!!searchBar.value) doSearch(searchBar.value);
	this.blur();
}

function searchBarInput() {
	clear();
	var val = this.value.trim();
	if(val.length > 2) doSearch(val);
	if(!!tagSelect.value) doFilter(tagSelect.value);
}

function searchClearClick() {
	clear();
	searchBar.value = '';
	this.blur();
}

function globalKeyHandler(e) {
	if(e.altKey || e.ctrlKey || e.metaKey || e.shiftKey || e.target.type == 'textarea') return;

	if(document.activeElement == document.body) {
		if(e.keyCode == 83) {
			e.preventDefault();
			window.scrollTo(0, 0);
			searchBar.focus();
		}
		return;
	}

	if(document.activeElement == searchBar) {
		if(e.keyCode == 27) {
			searchClearClick.call(e.target);
		}
		return;
	}
}

function init(index) {
	searchIndex = elasticlunr.Index.load(index);

	searchBar.removeAttribute('disabled');
	searchBar.addEventListener('input', searchBarInput);
	searchClear.addEventListener('click', searchClearClick);
	document.addEventListener('keydown', globalKeyHandler);
}

onLoaded(function() {
	tagSelect.addEventListener('change', tagSelectHandler);

	var xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange = function() {
		if(xmlhttp.readyState == 4 && xmlhttp.status == 200) {
			try {
				var index = JSON.parse(xmlhttp.responseText);
				init(index);
			} catch(err) {
				console.error(err.message);
			}
		}
	};
	xmlhttp.open('GET', '/assets/js/index.json', true);
	xmlhttp.send();
});

})();

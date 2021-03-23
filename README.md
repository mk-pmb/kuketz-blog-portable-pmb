
<!--#echo json="package.json" key="name" underline="=" -->
kuketz-blog-portable-pmb
========================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
Download/cache/reformat blog posts from kuketz-blog.de for offline reading
with custom CSS overrides.
<!--/#echo -->


Usage
-----

```bash
$ ./src/dl.sh --sym           # download symlinked posts
$ ./src/dl.sh 45372           # download by post ID / page ID
$ ./src/dl.sh artikelserien   # download by slug
$ ./src/dl.sh https://www.kuketz-blog.de/artikelserien/   # by full URL
```


<!--#toc stop="scan" -->



Known issues
------------

* Needs more/better tests and docs.




&nbsp;


License
-------
<!--#echo json="package.json" key=".license" -->
ISC
<!--/#echo -->

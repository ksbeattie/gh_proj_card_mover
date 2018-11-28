# GitHub Project Card Mover
A script for automatically moving project cards from one project to another project (within the same repo, user or organization).

```
$ ./gh_proj_card_mover --help
usage: gh_proj_card_mover [-h] [-v] [-q] [-n] [-C COLUMN] [-c] --token TOKEN
                          --src SRC --dest DEST

Move a set of cards from one github project board to another project board

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         increase output verbosity
  -q, --quiet           decrease output verbosity
  -n, --dry-run         Dry run: do everything but do not modify either source
                        ordestination boards
  -C COLUMN, --column COLUMN
                        Move cards only between the named column (default:
                        move between all identically named columns)
  -c, --copy            Do not remove cards from source project, just copy
                        them to the destination project.

GitHub project arguments:
  --token TOKEN         The personal token for authenticating to GitHub
  --src SRC             (required) The url of the project to move cards FROM
  --dest DEST           (required) The url of the project to move cards TO

Version: 0.1
```

Ideally, this script would use [PyGitHub](https://github.com/PyGithub/PyGithub), but it [doesn't currently support](https://github.com/PyGithub/PyGithub/issues/606) the new [project API](https://developer.github.com/v3/projects/).

This is also an exercise on my part, as an exercies in learning and using both the [requests](http://docs.python-requests.org/en/master/) module and the [GitHub API](https://developer.github.com/v3/).

Please feel free to open issues or PRs for feature requests or bug fixes.

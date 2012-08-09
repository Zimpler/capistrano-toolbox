capistrano-toolbox
==================

Some useful tools for our capistrano deployments.


How to release a new version
----------------------------

- Update the gemspec file with a new version number and eventual changes in files/dependencies.
- Run `gem build capistrano-toolbox.gemspec`
- Run `gem push capistrano-toolbox-0.0.5.gem`
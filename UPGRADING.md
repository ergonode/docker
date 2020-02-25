# Upgrading Notes

This document captures breaking changes between versions.

# Upgrading Notes (0.6.x to 7)

* Move frontend, backend, docs directories to the docker directory (main directory of this project).
* Manually remove `frontend/node_modules` and `docs/node_modules` directories.
* Since version 7.0, the `.env` file for development is optional, you do not need to create it. 

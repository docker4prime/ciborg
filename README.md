# ciborg
**ciborg** is a docker image based on the latest `alpine` image that contains a collection of **useful apps &  tools** for common CI build scenarios.

# content
the following programs & tools are included and enabled by default:

### OS packages
- bash
- curl
- git
- monit
- python3

### PYTHON modules
- ansible
- docker

### EXTERNAL tools
- goss testing framework (https://github.com/aelsabbahy/goss)


# usage
you cann call the installed programs directly from the image

### use ansible
```bash
docker run --rm -it docker4prime/ciborg ansible --version
docker run --rm -it docker4prime/ciborg ansible-playbook --version
```

### use goss
```bash
docker run --rm -it docker4prime/ciborg goss --version
```

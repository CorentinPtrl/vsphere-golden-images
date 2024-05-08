.PHONY: all plan apply destroy

all: help

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'

help:						## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

deploy:
	packer build -force -var "vcenter_folder=/templates/os/debian" debian/debian.json.pkr.hcl
	packer build -force -var "vcenter_folder=/templates/os/windows" windows-server/windows_server.pkr.hcl
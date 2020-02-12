###############################################
#
# Makefile
#
###############################################

.DEFAULT_GOAL := build

DEVNAME := Marc Lavergne
DEVID   ?= A1B2C3D4E5

EXEFILE := demo

KEYCHAIN := /Library/Keychains/System.keychain

PKFILE := macDevIdPriv.key

# DEVTYPE := Developer ID Application
# CSRFILE := macDevIdApp.csr
# CERFILE := developerID_application.cer

DEVTYPE := Developer ID Installer
CSRFILE := macDevIdInst.csr
CERFILE := developerID_installer.cer

SIGNID := "${DEVTYPE}: ${DEVNAME} (${DEVID})"

#
# Certs
#

CN      := ${DEVNAME}
SUBJ    := '/CN=$(CN)'

RSAKEY  := 2048

key:
	openssl genrsa -out $(PKFILE) $(RSAKEY)

addkey:
	sudo security import $(PKFILE) -k ${KEYCHAIN}

csr:
	openssl req -new -subj $(SUBJ) -key $(PKFILE) -out $(CSRFILE)

download:
	open https://developer.apple.com/account/resources/certificates/list

addcert:
	sudo security add-trusted-cert -d -r trustAsRoot -p codeSign -k ${KEYCHAIN} ~/Downloads/${CERFILE}

#
# Signing
#

show:
	security find-identity -p codesigning

certs:
	certtool y | grep -B 5 -A 5 Developer\ ID

sign:
	codesign --verbose -f -s ${SIGNID} --deep ${EXEFILE}

signalt:
	productsign --sign ${SIGNID} ${EXEFILE}

verify:
	codesign -dv ${EXEFILE}

#
# iOS:
# Apple Development - (new) app for all platforms
# Apple Distribution - AppStore (iOS)
#

#
# Mac:
# Mac App Distribution - app
# Mac Installer Distribution - pkg
# Developer ID Application - app (outside store)
# Developer ID Installer - pkg (outside store) *also for non-bundle executables*
#
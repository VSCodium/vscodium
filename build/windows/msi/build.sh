#!/bin/bash

set -ex

CALLER_DIR=$( pwd )

cd "$( dirname "${BASH_SOURCE[0]}" )"

WIN_SDK_MAJOR_VERSION="10"
WIN_SDK_FULL_VERSION="10.0.17763.0"

PRODUCT_NAME="VSCodium"
PRODUCT_SKU="vscodium"
PRODUCT_ID=$( powershell.exe -command "[guid]::NewGuid().ToString().ToUpper()" )
PRODUCT_ID="${PRODUCT_ID%%[[:cntrl:]]}"

CULTURE="en-us"
LANGIDS="1033"

SETUP_RELEASE_DIR=".\\releasedir"
SETUP_RESOURCES_DIR=".\\resources"
BINARY_DIR="..\\..\\..\\VSCode-win32-${VSCODE_ARCH}"
ICON_DIR="..\\..\\..\\src\\resources\\win32"
LICENSE_DIR="..\\..\\..\\vscode"
PROGRAM_FILES_86=$( env | sed -n 's/^ProgramFiles(x86)=//p' )

if [[ -z "$1" ]]; then
	OUTPUT_BASE_FILENAME="${PRODUCT_NAME}-${VSCODE_ARCH}-${MS_TAG}"
else
	OUTPUT_BASE_FILENAME="${PRODUCT_NAME}-${VSCODE_ARCH}-$1-${MS_TAG}"
fi

if [[ "${VSCODE_ARCH}" == "ia32" ]]; then
   export PLATFORM="x86"
else
   export PLATFORM="${VSCODE_ARCH}"
fi


BuildSetupTranslationTransform() {
	local CULTURE=$1
	local LANGID=$2

	LANGIDS="${LANGIDS},${LANGID}"

	echo "Building setup translation for culture \"${CULTURE}\" with LangID \"${LANGID}\"..."
	
	"${WIX}bin\\light.exe" vscodium.wixobj "Files-${OUTPUT_BASE_FILENAME}.wixobj" -ext WixUIExtension -ext WixUtilExtension -ext WixNetFxExtension -spdb -cc "${TEMP}\\vscodium-cab-cache\\${PLATFORM}" -reusecab -out "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.msi" -loc "i18n\\${PRODUCT_SKU}.${CULTURE}.wxl" -cultures:"${CULTURE}" -sice:ICE60 -sice:ICE69
	
	cscript "${PROGRAM_FILES_86}\\Windows Kits\\${WIN_SDK_MAJOR_VERSION}\\bin\\${WIN_SDK_FULL_VERSION}\\${PLATFORM}\\WiLangId.vbs" ${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.msi Product "${LANGID}"
	
	"${PROGRAM_FILES_86}\\Windows Kits\\${WIN_SDK_MAJOR_VERSION}\\bin\\${WIN_SDK_FULL_VERSION}\\x86\\msitran" -g "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.msi" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.msi" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.mst"
	
	cscript "${PROGRAM_FILES_86}\\Windows Kits\\${WIN_SDK_MAJOR_VERSION}\\bin\\${WIN_SDK_FULL_VERSION}\\${PLATFORM}\\wisubstg.vbs" ${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.msi ${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.mst "${LANGID}"
	
	cscript "${PROGRAM_FILES_86}\\Windows Kits\\${WIN_SDK_MAJOR_VERSION}\\bin\\${WIN_SDK_FULL_VERSION}\\${PLATFORM}\\wisubstg.vbs" ${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.msi

	rm -f "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.msi"
	rm -f "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.mst"
}

"${WIX}bin\\heat.exe" dir "${BINARY_DIR}" -out "Files-${OUTPUT_BASE_FILENAME}.wxs" -t vscodium.xsl -gg -sfrag -scom -sreg -srd -ke -cg "AppFiles" -var var.AppName -var var.ProductVersion -var var.IconDir -var var.LicenseDir -var var.BinaryDir -dr APPLICATIONFOLDER -platform "${PLATFORM}"
"${WIX}bin\\candle.exe" -arch "${PLATFORM}" vscodium.wxs "Files-${OUTPUT_BASE_FILENAME}.wxs" -ext WixUIExtension -ext WixUtilExtension -ext WixNetFxExtension -dAppName=${PRODUCT_NAME} -dProductVersion="${MS_TAG%-insider}" -dProductId="${PRODUCT_ID}" -dBinaryDir="${BINARY_DIR}" -dIconDir="${ICON_DIR}" -dLicenseDir="${LICENSE_DIR}" -dSetupResourcesDir="${SETUP_RESOURCES_DIR}" -dCulture="${CULTURE}"
"${WIX}bin\\light.exe" vscodium.wixobj "Files-${OUTPUT_BASE_FILENAME}.wixobj" -ext WixUIExtension -ext WixUtilExtension -ext WixNetFxExtension -spdb -cc "${TEMP}\\vscodium-cab-cache\\${PLATFORM}" -out "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.msi" -loc "i18n\\${PRODUCT_SKU}.${CULTURE}.wxl" -cultures:"${CULTURE}" -sice:ICE60 -sice:ICE69

BuildSetupTranslationTransform de-de 1031
BuildSetupTranslationTransform es-es 3082
BuildSetupTranslationTransform fr-fr 1036
BuildSetupTranslationTransform it-it 1040
# WixUI_Advanced bug: https://github.com/wixtoolset/issues/issues/5909
# BuildSetupTranslationTransform ja-jp 1041
BuildSetupTranslationTransform ko-kr 1042
BuildSetupTranslationTransform ru-ru 1049
BuildSetupTranslationTransform zh-cn 2052
BuildSetupTranslationTransform zh-tw 1028

# Add all supported languages to MSI Package attribute
cscript "${PROGRAM_FILES_86}\\Windows Kits\\${WIN_SDK_MAJOR_VERSION}\\bin\\${WIN_SDK_FULL_VERSION}\\${PLATFORM}\\WiLangId.vbs" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.msi" Package "${LANGIDS}"

# Remove files we do not need any longer.
rm -rf "${TEMP}\\vscodium-cab-cache"
rm -f "Files-${OUTPUT_BASE_FILENAME}.wxs"
rm -f "Files-${OUTPUT_BASE_FILENAME}.wixobj"
rm -f "vscodium.wixobj"

cd "${CALLER_DIR}"

#!/usr/bin/env bash
# shellcheck disable=SC2034

set -ex

CALLER_DIR=$( pwd )

cd "$( dirname "${BASH_SOURCE[0]}" )"

WIN_SDK_MAJOR_VERSION="10"
WIN_SDK_FULL_VERSION="10.0.17763.0"

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  PRODUCT_NAME="VSCodium - Insiders"
  PRODUCT_SKU="vscodium-insiders"
  PRODUCT_CODE="VSCodiumInsiders"
  PRODUCT_UPGRADE_CODE="1C9B7195-5A9A-43B3-B4BD-583E20498467"
  ICON_DIR="..\\..\\..\\src\\insider\\resources\\win32"
  SETUP_RESOURCES_DIR=".\\resources\\insider"
else
  PRODUCT_NAME="VSCodium"
  PRODUCT_SKU="vscodium"
  PRODUCT_CODE="VSCodium"
  PRODUCT_UPGRADE_CODE="965370CD-253C-4720-82FC-2E6B02A53808"
  ICON_DIR="..\\..\\..\\src\\stable\\resources\\win32"
  SETUP_RESOURCES_DIR=".\\resources\\stable"
fi

PRODUCT_ID=$( powershell.exe -command "[guid]::NewGuid().ToString().ToUpper()" )
PRODUCT_ID="${PRODUCT_ID%%[[:cntrl:]]}"

CULTURE="en-us"
LANGIDS="1033"

SETUP_RELEASE_DIR=".\\releasedir"
BINARY_DIR="..\\..\\..\\VSCode-win32-${VSCODE_ARCH}"
LICENSE_DIR="..\\..\\..\\vscode"
PROGRAM_FILES_86=$( env | sed -n 's/^ProgramFiles(x86)=//p' )

if [[ -z "${1}" ]]; then
	OUTPUT_BASE_FILENAME="VSCodium-${VSCODE_ARCH}-${RELEASE_VERSION}"
else
	OUTPUT_BASE_FILENAME="VSCodium-${VSCODE_ARCH}-${1}-${RELEASE_VERSION}"
fi

if [[ "${VSCODE_ARCH}" == "ia32" ]]; then
   export PLATFORM="x86"
else
   export PLATFORM="${VSCODE_ARCH}"
fi

sed -i "s|@@PRODUCT_UPGRADE_CODE@@|${PRODUCT_UPGRADE_CODE}|g" .\\includes\\vscodium-variables.wxi
sed -i "s|@@PRODUCT_NAME@@|${PRODUCT_NAME}|g" .\\vscodium.xsl

find i18n -name '*.wxl' -exec sed -i "s|@@PRODUCT_NAME@@|${PRODUCT_NAME}|g" {} \;

BuildSetupTranslationTransform() {
	local CULTURE=${1}
	local LANGID=${2}

	LANGIDS="${LANGIDS},${LANGID}"

	echo "Building setup translation for culture \"${CULTURE}\" with LangID \"${LANGID}\"..."

	"${WIX}bin\\light.exe" vscodium.wixobj "Files-${OUTPUT_BASE_FILENAME}.wixobj" -ext WixUIExtension -ext WixUtilExtension -ext WixNetFxExtension -spdb -cc "${TEMP}\\vscodium-cab-cache\\${PLATFORM}" -reusecab -out "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.msi" -loc "i18n\\vscodium.${CULTURE}.wxl" -cultures:"${CULTURE}" -sice:ICE60 -sice:ICE69

	cscript "${PROGRAM_FILES_86}\\Windows Kits\\${WIN_SDK_MAJOR_VERSION}\\bin\\${WIN_SDK_FULL_VERSION}\\${PLATFORM}\\WiLangId.vbs" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.msi" Product "${LANGID}"

	"${PROGRAM_FILES_86}\\Windows Kits\\${WIN_SDK_MAJOR_VERSION}\\bin\\${WIN_SDK_FULL_VERSION}\\x86\\msitran" -g "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.msi" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.msi" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.mst"

	cscript "${PROGRAM_FILES_86}\\Windows Kits\\${WIN_SDK_MAJOR_VERSION}\\bin\\${WIN_SDK_FULL_VERSION}\\${PLATFORM}\\wisubstg.vbs" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.msi" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.mst" "${LANGID}"

	cscript "${PROGRAM_FILES_86}\\Windows Kits\\${WIN_SDK_MAJOR_VERSION}\\bin\\${WIN_SDK_FULL_VERSION}\\${PLATFORM}\\wisubstg.vbs" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.msi"

	rm -f "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.msi"
	rm -f "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.mst"
}

"${WIX}bin\\heat.exe" dir "${BINARY_DIR}" -out "Files-${OUTPUT_BASE_FILENAME}.wxs" -t vscodium.xsl -gg -sfrag -scom -sreg -srd -ke -cg "AppFiles" -var var.ManufacturerName -var var.AppName -var var.AppCodeName -var var.ProductVersion -var var.IconDir -var var.LicenseDir -var var.BinaryDir -dr APPLICATIONFOLDER -platform "${PLATFORM}"
"${WIX}bin\\candle.exe" -arch "${PLATFORM}" vscodium.wxs "Files-${OUTPUT_BASE_FILENAME}.wxs" -ext WixUIExtension -ext WixUtilExtension -ext WixNetFxExtension -dManufacturerName="VSCodium" -dAppCodeName="${PRODUCT_CODE}" -dAppName="${PRODUCT_NAME}" -dProductVersion="${RELEASE_VERSION%-insider}" -dProductId="${PRODUCT_ID}" -dBinaryDir="${BINARY_DIR}" -dIconDir="${ICON_DIR}" -dLicenseDir="${LICENSE_DIR}" -dSetupResourcesDir="${SETUP_RESOURCES_DIR}" -dCulture="${CULTURE}"
"${WIX}bin\\light.exe" vscodium.wixobj "Files-${OUTPUT_BASE_FILENAME}.wixobj" -ext WixUIExtension -ext WixUtilExtension -ext WixNetFxExtension -spdb -cc "${TEMP}\\vscodium-cab-cache\\${PLATFORM}" -out "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.msi" -loc "i18n\\vscodium.${CULTURE}.wxl" -cultures:"${CULTURE}" -sice:ICE60 -sice:ICE69

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

#!/bin/bash


# Patch `index.html` and `index-no-csp.html`
sed -i 's/^(content-security-policy|default-style|content-type)$/^(content-security-policy|default-style|content-type|permission-policy)$/i' src/vs/workbench/contrib/webview/browser/pre/index.html
sed -i 's/^(content-security-policy|default-style|content-type)$/^(content-security-policy|default-style|content-type|permission-policy)$/i' src/vs/workbench/contrib/webview/browser/pre/index-no-csp.html
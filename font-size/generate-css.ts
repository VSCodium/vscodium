#!/usr/bin/env node

import process from 'node:process';
import fse from '@zokugun/fs-extra-plus/async';
import { err, OK, type Result, stringifyError, xtry } from '@zokugun/xtry';
import fg from 'fast-glob';
import postcss, { type Rule } from 'postcss';

const PREFIX_MAIN = '.monaco-workbench .part.sidebar';
const PREFIX_AUX = '.monaco-workbench .part.auxiliarybar';
const DEFAULT_GLOB = '../vscode/**/*.css';
const PX_REGEX = /(-?\d+(\.\d+)?)px\b/g;
const COEFF_PRECISION = 6;

function formatCoefficient(n: number): string {
	const fixed = n.toFixed(COEFF_PRECISION);
	return fixed.replace(/\.?0+$/, '');
}

function replacePx(_match: string, numStr: string): string {
	const pxValue = Number.parseFloat(numStr);
	const coeff = formatCoefficient(pxValue / 13);

	return `calc(var(--vscode-workbench-sidebar-font-size) * ${coeff})`;
}

function transformPxValue(value: string): string {
	return value.replaceAll(PX_REGEX, replacePx);
}

async function processFile(filePath: string): Promise<Result<void, string>> {
	const cssResult = await fse.readFile(filePath, 'utf8');
	if(cssResult.fails) {
		return err(stringifyError(cssResult.error));
	}

	const postcssResult = xtry(() => postcss.parse(cssResult.value, { from: filePath }));
	if(postcssResult.fails) {
		return err(`Failed to parse ${filePath}: ${stringifyError(postcssResult.error)}`);
	}

	const generatedRoot = postcss.root();

	postcssResult.value.walkRules((rule: Rule) => {
		let hasPx = false;
		const declarationsToAdd: Array<{ prop: string; value: string }> = [];

		rule.walkDecls((declaration) => {
			if(PX_REGEX.test(declaration.value)) {
				const newValue = transformPxValue(declaration.value);

				declarationsToAdd.push({ prop: declaration.prop, value: newValue });

				hasPx = true;
			}
		});

		if(hasPx && declarationsToAdd.length > 0) {
			const selectors = (rule.selectors && rule.selectors.length > 0)	? rule.selectors : [rule.selector];
			const mainSelectors = selectors.map((selector) => prefixSelector(selector, PREFIX_MAIN)).join(', ');
			const auxSelectors = selectors.map((selector) => prefixSelector(selector, PREFIX_AUX)).join(', ');
			const newRule = postcss.rule({ selector: `${mainSelectors}, ${auxSelectors}` });

			let length = 0;

			for(const declaration of declarationsToAdd) {
				if(!declaration.prop.startsWith('border')) {
					newRule.append({ ...declaration });
					length += 1;
				}
			}

			if(length > 0) {
				generatedRoot.append(newRule);
			}
		}
	});

	if(generatedRoot.nodes && generatedRoot.nodes.length > 0) {
		const writeResult = await fse.writeFile(filePath, cssResult.value + '\n\n\n' + generatedRoot.toString(), 'utf8');
		if(writeResult.fails) {
			return err(stringifyError(cssResult.error));
		}

		console.log(`Generated: ${filePath}`);
	}
	else {
		console.log(`No px sizes found in: ${filePath}`);
	}

	return OK;
}

async function main(): Promise<void> {
	const pattern = process.argv[2] || DEFAULT_GLOB;
	const entries = await fg(pattern, { dot: true, onlyFiles: true });

	if(entries.length === 0) {
		console.log(`No files matched pattern: ${pattern}`);
		return;
	}

	for(const file of entries) {
		const result = await processFile(file);
		if(result.fails) {
			console.error(`Error processing ${file}:`, result.error);
		}
	}
}

function prefixSelector(selector: string, prefix: string): string {
	const parts = selector.split(' ');
	if(parts[0].startsWith('.monaco-workbench')) {
		if(parts[1] === '.part') {
			parts.splice(0, 2);
		}
		else {
			parts.splice(0, 1);
		}

		parts.unshift(prefix);

		return parts.join(' ');
	}
	else if(parts[0] === '.mac' || parts[0] === '.linux' || parts[0] === '.windows') {
		const prefixParts = prefix.split(' ');

		parts[0] = `${prefixParts.shift()}${parts[0]}`;

		parts.splice(1, 0, ...prefixParts);

		return parts.join(' ');
	}
	else {
		return `${prefix} ${selector}`;
	}
}

await main();

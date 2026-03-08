#!/usr/bin/env node

import path from 'node:path';
import process from 'node:process';
import fse from '@zokugun/fs-extra-plus/async';
import { err, OK, type Result, stringifyError, xtry } from '@zokugun/xtry';
import postcss, { Root, type Rule } from 'postcss';

type Area = {
	name: string;
	defaultSize: number;
	files: string[];
	prefixes: string[];
};

const PX_REGEX = /(-?\d+(\.\d+)?)px\b/g;
const COEFF_PRECISION = 6;
const HEADER = '/*** Generated for Custom Font Size ***/';
const ZEROS = ['margin', 'padding'];

const AREAS: Record<string, Area> = {
	activitybar: {
		name: 'activitybar',
		defaultSize: 16,
		files: ['src/vs/workbench/browser/parts/activitybar/media/activityaction.css'],
		prefixes: ['.monaco-workbench .activitybar'],
	},
	bottompane: {
		name: 'bottompane',
		defaultSize: 13,
		files: ['src/vs/workbench/browser/parts/panel/media/panelpart.css', 'src/vs/base/browser/ui/actionbar/actionbar.css', 'src/vs/workbench/browser/parts/media/paneCompositePart.css'],
		prefixes: ['.monaco-workbench .part.panel'],
	},
	statusbar: {
		name: 'statusbar',
		defaultSize: 12,
		files: ['src/vs/workbench/browser/parts/statusbar/media/statusbarpart.css'],
		prefixes: ['.monaco-workbench .part.statusbar'],
	},
	sidebar: {
		name: 'sidebar',
		defaultSize: 13,
		files: [
			'src/vs/base/browser/ui/actionbar/actionbar.css',
			'src/vs/base/browser/ui/button/button.css',
			'src/vs/base/browser/ui/inputbox/inputBox.css',
			'src/vs/workbench/contrib/extensions/browser/media/extension.css',
			'src/vs/workbench/contrib/extensions/browser/media/extensionActions.css',
			'src/vs/workbench/contrib/search/browser/media/searchview.css',
			'src/vs/workbench/contrib/scm/browser/media/scm.css',
		],
		prefixes: ['.monaco-workbench .part.sidebar', '.monaco-workbench .part.auxiliarybar'],
	},
	tabs: {
		name: 'tabs',
		defaultSize: 13,
		files: [
			'src/vs/workbench/browser/parts/editor/media/editortabscontrol.css',
			'src/vs/workbench/browser/parts/editor/media/editortitlecontrol.css',
			'src/vs/workbench/browser/parts/editor/media/multieditortabscontrol.css'
		],
		prefixes: ['.monaco-workbench .part.editor > .content .editor-group-container > .title.tabs'],
	},
};

function formatCoefficient(n: number): string { // {{{
	const fixed = n.toFixed(COEFF_PRECISION);
	return fixed.replace(/\.?0+$/, '');
} // }}}

function replacePx(area: Area) { // {{{
	return (match: string, numStr: string): string => {
		const pxValue = Number.parseFloat(numStr);

		if(pxValue === 1) {
			return match;
		}

		const coeff = formatCoefficient(pxValue / area.defaultSize);

		return `calc(var(--vscode-workbench-${area.name}-font-size) * ${coeff})`;
	};
} // }}}

function transformPxValue(value: string, area: Area): string { // {{{
	return value.replaceAll(PX_REGEX, replacePx(area));
} // }}}

async function processFile(filePath: string, areas: Area[]): Promise<Result<void, string>> { // {{{
	const readResult = await fse.readFile(filePath, 'utf8');
	if(readResult.fails) {
		return err(stringifyError(readResult.error));
	}

	const content = extractOriginal(readResult.value);

	const postcssResult = xtry(() => postcss.parse(content, { from: filePath }));
	if(postcssResult.fails) {
		return err(`Failed to parse ${filePath}: ${stringifyError(postcssResult.error)}`);
	}

	const generatedRoot = postcss.root();

	for(const area of areas) {
		processFileArea(postcssResult.value, generatedRoot, area)
	}

	if(generatedRoot.nodes && generatedRoot.nodes.length > 0) {
		const writeResult = await fse.writeFile(filePath, content + `\n\n\n${HEADER}\n\n` + generatedRoot.toString(), 'utf8');
		if(writeResult.fails) {
			return err(stringifyError(readResult.error));
		}

		console.log(`Generated: ${filePath}`);
	}
	else {
		console.log(`No px sizes found in: ${filePath}`);
	}

	return OK;
} // }}}

function processFileArea(postcssResult: Root, generatedRoot: Root, area: Area): void { // {{{
	postcssResult.walkRules((rule: Rule) => {
		const declarationsToAdd: Array<{ prop: string; value: string }> = [];

		rule.walkDecls((declaration) => {
			if(PX_REGEX.test(declaration.value)) {
				const newValue = transformPxValue(declaration.value, area);

				declarationsToAdd.push({ prop: declaration.prop, value: newValue });
			}
			else if(declaration.value === 'auto' && (declaration.prop === 'height' || declaration.prop === 'width')) {
				declarationsToAdd.push({ prop: declaration.prop, value: 'auto' });
			}
			else if(declaration.value === '0' && ZEROS.includes(declaration.prop)) {
				declarationsToAdd.push({ prop: declaration.prop, value: '0' });
			}
		});

		if(declarationsToAdd.length > 0) {
			const selectors = (rule.selectors && rule.selectors.length > 0)	? rule.selectors : [rule.selector];
			const prefixeds: string[] = [];

			for(const prefix of area.prefixes) {
				const parts = prefix.split(' ');
				const prefixed = selectors.map((s) => prefixSelector(s, parts)).join(', ');

				prefixeds.push(prefixed);
			}

			const newRule = postcss.rule({ selector: `${prefixeds.join(', ')}` });

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
} // }}}

function extractOriginal(content: string): string { // {{{
	const index = content.indexOf(HEADER);

	if(index === -1) {
		return content;
	}

	return content.slice(0, Math.max(0, index - 3));
} // }}}

function extractStyle(selector: string): string { // {{{
	const match = /^(\.[\w-]+)/.exec(selector);

	return match?.[1] ?? '';
} // }}}

function mergeSelector(selectors: string[], prefixes: string[], index: number): void { // {{{
	if(index >= prefixes.length) {
		return;
	}

	const prefix = prefixes[index];
	const selector = selectors[index];
	const style = extractStyle(prefix);

	if(selector === style) {
		if(prefix.length > style.length) {
			selectors[index] = prefix;
		}

		mergeSelector(selectors, prefixes, index + 1);
	}
	else if(selector.startsWith(style)) {
		mergeSelector(selectors, prefixes, index + 1);
	}
	else if(index === 0) {
		selectors.unshift(...prefixes)
	}
	else {
		selectors.splice(index + 1, 0, ...prefixes.slice(index));
	}
} // }}}

function prefixSelector(selector: string, prefixParts: string[]): string { // {{{
	const parts = selector.split(' ');

	if(parts[0] === '.mac' || parts[0] === '.linux' || parts[0] === '.windows') {
		parts[0] = `${prefixParts[0]}${parts[0]}`;

		parts.splice(1, 0, ...prefixParts.slice(1));
	}
	else {
		mergeSelector(parts, prefixParts, 0);
	}

	return parts.join(' ');
} // }}}

async function main(): Promise<void> { // {{{
	const name = process.argv[2];
	const area = AREAS[name];

	if(area) {
		for(const file of area.files) {
			const result = await processFile(path.join('..', 'vscode', file), [area]);
			if(result.fails) {
				console.error(`Error processing ${file}:`, result.error);
			}
		}
	}
	else if(name === 'all') {
		const files: Record<string, Area[]> = {};

		for(const area of Object.values(AREAS)) {
			for(const file of area.files) {
				if(files[file]) {
					files[file].push(area)
				}
				else {
					files[file] = [area]
				}
			}
		}

		for(const [file, areas] of Object.entries(files)) {
			const result = await processFile(path.join('..', 'vscode', file), areas);
			if(result.fails) {
				console.error(`Error processing ${file}:`, result.error);
			}
		}
	}
	else {
		console.log(`No area found for ${name}`);
		console.log(`\nAvailable areas:\n- ${Object.keys(AREAS).join('\n- ')}`);
		return;
	}
} // }}}

await main();

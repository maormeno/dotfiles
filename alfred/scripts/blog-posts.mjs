#!/usr/bin/env node

/*
 * Returns list of blog posts in Afred’s Script Filter JSON format.
 *
 * Author: Artem Sapegin, sapegin.me
 * License: MIT
 * https://github.com/sapegin/dotfiles
 */

import fs from 'fs';
import path from 'path';
import untildify from 'untildify';
import glob from 'glob';

const FILES = untildify(`~/_/sapegin.me/src/content/blog/*.md`);

const items = glob
	.sync(FILES)
	.map((file) => {
		const contents = fs.readFileSync(file, 'utf8');
		const title = contents.match(/^title: ['"]?(.*?)['"]?$/im);
		const date = contents.match(/^date: (.*?)$/m);
		return {
			title: title ? title[1] : '<***>',
			date: date ? date[1] : path.basename(file),
			file,
		};
	})
	.map((doc) => ({
		title: doc.title,
		subtitle: doc.date,
		uid: doc.file,
		type: 'file',
		valid: true,
		arg: doc.file,
		icon: {
			type: 'fileicon',
			path: doc.file,
		},
	}));

console.log(
	JSON.stringify({
		items,
	})
);

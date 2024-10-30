+++
date = 2023-06-11T07:12:14+01:00
lastmod = 2023-06-11T07:12:14+01:00
title = "Reliable wheelie bins"
tags = ['automation', 'programming', 'SRE']
+++

<!-- https://commons.wikimedia.org/wiki/File:Irish_Panda_wheelie_bin.jpg -->

{{< rawhtml >}}
<img style="float: right; margin-left: 1em" title="Babestress, CC BY-SA 3.0 https://creativecommons.org/licenses/by-sa/3.0"
src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/Irish_Panda_wheelie_bin.jpg/256px-Irish_Panda_wheelie_bin.jpg"
alt="Wheelie bin picture"
/>
{{< /rawhtml >}}

Like most Irish households, we aggregate our household waste into wheelie bins
that are collected every two weeks. Ours are collected on Monday morning, so
they need to be left out on Sunday night - except when Monday is a public
holiday, they're collected on Saturday, and so they need to be left out on
Friday night. This has worked for years, but recently I forgot to put out the
wheelie bins on the Friday night before a public holiday :( I have calendar
reminders to put out the bins on Sunday night, so I decided that I should have
calendar reminders on Friday nights before public holidays, but _only_ before
public holidays so they aren't spammy. There's a [Google calendar of Irish
public
holidays](https://calendar.google.com/calendar/embed?src=en.irish%23holiday%40group.v.calendar.google.com&ctz=Europe%2FDublin),
so I wrote some [Google Apps Script](https://developers.google.com/apps-script/)
to find upcoming public holidays on Mondays and create reminder events on
Fridays. The code wasn't too hard to write, even though it was my first time
writing Typescript or Google Apps Script. It has worked for the past two public
holidays so I'm happy to share it for anyone who might benefit from it:
<https://github.com/tobinjt/wheelie-bin-holiday-warning>

Some implementation notes:

- [ESLint](https://eslint.org/) did take a lot of fiddling to get correctly
  configured, e.g. despite picking Typescript in the setup wizard the generated
  config used the wrong parser, and the error messages from ESLint when there is
  a configuration problem are very unclear for a beginner because they do not
  include filenames or line numbers. I got it working eventually though.
- Unlike most of my code it doesn't have any tests, because testing Typescript
  and Google Apps Script in particular seems to be very poorly supported - you
  need to manually mock every App Script function you call, or use one of the
  many incomplete and frequently abandoned OSS libraries. Also I've never
  written Typescript tests, and there are many testing frameworks to chose from
  rather than a standard framework. I didn't have the time or mental bandwidth
  to figure out Typescript testing.
- I use [CLASP](https://github.com/google/clasp) to develop locally and push to
  Google Apps. It was very simple to set up:

  - `npm install -g @google/clasp`
  - `clasp login`
  - Either `clasp create` if you don't have a project, or `clasp clone` if you
    do.

  Pushing was easy too:

  - `clasp push`
  - `clasp open` - not strictly necessary, opens the uploaded code in your
    browser.

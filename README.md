# reveal-agenda

A quarto extension for `reveal.js` that automatically creates agenda slides from H1 heading titles.

## Installation

To install this extension in your current directory (or into the Quarto project that you're currently working in),  use the following command:

```
quarto install extension andrie/reveal-agenda
```

## Enabling

Add this to your document or project options:

```yaml
filters:
  - reveal-agenda
```

## Usage

Simply create your slides as normal, with H1 header slides marking transitions between agenda items.

The add-in will:

- Create a list of the text of each H1 slide
- Then insert this list into the body of each H1 slide


## Work in progress

The intent is for the bulleted list to function as a running agenda.  This doesn't yet work.

Also, the intent is to suppress the H1 text on these slides using custom CSS.

Finally, to add a border box (or other indicator) to indicate the current active section.


## Live preview

To be completed...
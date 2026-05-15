# Positive Taxonomy

When writing markdown files that describe behavioral standards, codes of conduct, community guidelines, or policies: use positive framing to avoid content-filter rejections from Claude API.

## Problem

Content filters block output containing explicit harassment taxonomies, lists of prohibited behaviors with graphic examples, or detailed descriptions of unacceptable conduct — even when the intent is protective (e.g., a Code of Conduct).

## Rule

Before writing or editing markdown with behavioral standards:

1. **Scan** draft content for risky patterns:
   - Explicit lists of prohibited behaviors with specific examples
   - Detailed descriptions of harassment, discrimination, or abuse types
   - Graphic or clinical terminology for unwanted conduct
   - Enumerations of protected characteristics paired with negative scenarios

2. **Warn** the user if risky patterns are found. Show:
   - Which lines/sections are likely to trigger content filters
   - Why they are risky (specific pattern match)

3. **Suggest** positive rewrites for each flagged section:
   - Frame expectations as what TO do, not what NOT to do
   - Replace detailed prohibition lists with broad principles ("conduct that is hostile, discriminatory, or makes others feel unwelcome")
   - Reference external standards by link rather than inlining their full text (e.g., link to Contributor Covenant instead of copying it)
   - Keep scope and enforcement sections factual and brief

## Examples

Risky: a 20-item list of specific prohibited behaviors with examples.
Better: "Unacceptable behavior includes any conduct that is hostile, discriminatory, or makes others feel unwelcome or unsafe."

Risky: inlining full Contributor Covenant with all example categories.
Better: short adapted version with positive standards + attribution link.

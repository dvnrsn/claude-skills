# Generic scrub applied by scripts/sync.sh to every text file it copies in.
# Safe to publish: no identifiers here.
#
# The project-specific identity map (real user IDs, client names, private repo
# path -> placeholders) lives in _local/scrub.sed, which is gitignored and
# applied first by sync.sh.

s#/Users/[a-zA-Z0-9._-]\{1,\}/#~/#g
s#/home/[a-zA-Z0-9._-]\{1,\}/#~/#g

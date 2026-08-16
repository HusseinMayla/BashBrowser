#!/bin/bash

# HTML Parser: Extracts semantic & interactive elements

# Extract page title
get_title() {
    local html="$1"
    local title=""
    title=$(printf '%s\n' "$html" | grep -oiP '(?<=<title>)(.*?)(?=</title>)' | head -n 1)
    title="${title#"${title%%[![:space:]]*}"}"
    title="${title%"${title##*[![:space:]]}"}"
    printf '%s\n' "${title:-[No Title]}"
}

# Parse HTML into structured tab-separated elements
parse_page() {
    local html="$1"

    perl -0777 -ne '
        # Strip script and style blocks
        s/<script\b[^>]*>.*?<\/script>//gis;
        s/<style\b[^>]*>.*?<\/style>//gis;

        # Match interactive & semantic elements: inputs, headings, buttons, links, labels, paragraphs
        while (m{<(input|br)\b([^>]*)/?>|<(h[1-6]|button|a|label|p)\b([^>]*)>(.*?)</\3>}gis) {
            my $tag = lc($1 || $3);
            my $attrs = $2 || $4 || "";
            my $inner = $5 || "";

            # If paragraph contains inner links, parse them cleanly
            if ($tag eq "p" && $inner =~ m{<a\b}i) {
                while ($inner =~ m{<a\b([^>]*)>(.*?)</a>}gis) {
                    my ($l_attrs, $l_inner) = ($1, $2);
                    my $l_href = "";
                    $l_href = $1 if $l_attrs =~ /\bhref\s*=\s*["\x27]([^"\x27]*)["\x27]/i || $l_attrs =~ /\bhref\s*=\s*([^"\x27\s>]+)/i;
                    $l_inner =~ s/<[^>]+>/ /g;
                    $l_inner =~ s/^\s+|\s+$//g;
                    print "link\thref=$l_href\ttext=$l_inner\n" if $l_inner ne "";
                }
                next;
            }

            my $get_attr = sub {
                my ($name) = @_;
                return $1 if $attrs =~ /\b$name\s*=\s*["\x27]([^"\x27]*)["\x27]/i;
                return $1 if $attrs =~ /\b$name\s*=\s*([^"\x27\s>]+)/i;
                return "";
            };

            # Clean screen reader clutter
            $inner =~ s/<span\s+class="sr-only"[^>]*>.*?<\/span>//gis if $inner =~ /<h[1-6]|<strong|[a-zA-Z]{3,}/i;

            # Clean inner tags and entities
            $inner =~ s/<[^>]+>/ /g;
            $inner =~ s/&times;/×/g;
            $inner =~ s/&amp;/&/g;
            $inner =~ s/&lt;/</g;
            $inner =~ s/&gt;/>/g;
            $inner =~ s/&quot;/"/g;
            $inner =~ s/&#x25C4;/◄/g;
            $inner =~ s/&#x25BA;/►/g;
            $inner =~ s/^\s+|\s+$//g;
            $inner =~ s/\s+/ /g;

            # Skip empty text elements for containers
            if ($tag ne "input" && $tag ne "br") {
                next if $inner eq "Course image" || $inner eq "";
            }

            if ($tag =~ /^h([1-6])$/) {
                print "heading\tlevel=$1\ttext=$inner\n";
            }
            elsif ($tag eq "a") {
                my $href = $get_attr->("href");
                print "link\thref=$href\ttext=$inner\n";
            }
            elsif ($tag eq "button") {
                my $id = $get_attr->("id");
                my $type = $get_attr->("type") || "button";
                $inner = $get_attr->("value") || "Button" if $inner eq "";
                print "button\tid=$id\ttype=$type\ttext=$inner\n";
            }
            elsif ($tag eq "input") {
                my $id = $get_attr->("id");
                my $name = $get_attr->("name");
                my $type = lc($get_attr->("type") || "text");
                my $val = $get_attr->("value") || $get_attr->("placeholder");
                print "input\tid=$id\tname=$name\ttype=$type\tvalue=$val\n";
            }
            elsif ($tag eq "p") {
                print "text\ttext=$inner\n";
            }
            elsif ($tag eq "label") {
                my $for = $get_attr->("for");
                print "label\tfor=$for\ttext=$inner\n";
            }
            elsif ($tag eq "br") {
                print "br\n";
            }
        }
    ' <<< "$html"
}

## This file contains instructions and configurations for the `latexmk` program

## Choose TeX engine for PDF generation
$pdf_mode = 1; # use pdfTeX
# $pdf_mode = 4; # use LuaTeX

### Additional flags for the TeX engine
## --shell-escape: enable external/system commands (e.g. Inkscape)
## --file-line-error: writes out the concrete file line in which the error occurred
## --halt-on-error: stop processing at the first error
## %O and %S will forward Options and the Source file, respectively, given to latexmk.
set_tex_cmds("--shell-escape --file-line-error --halt-on-error %O %S");

# This shows how to use the glossaries package
# (http://www.ctan.org/pkg/glossaries) and the glossaries-extra package
# (http://www.ctan.org/pkg/glossaries-extra) with latexmk.

# N.B. There is also the OBSOLETE glossary package
# (http://www.ctan.org/pkg/glossary), which has some differences.  See item 2.

# 1. If you use the glossaries or the glossaries-extra package, then you can use:

   add_cus_dep( 'acn', 'acr', 0, 'makeglossaries' );
   add_cus_dep( 'glo', 'gls', 0, 'makeglossaries' );
   $clean_ext .= " acr acn alg glo gls glg";

   sub makeglossaries {
        my ($base_name, $path) = fileparse( $_[0] );
        my @args = ( "-q", "-d", $path, $base_name );
        if ($silent) { unshift @args, "-q"; }
        return system "makeglossaries", "-d", $path, $base_name; 
    }

## Change default `biber` call to help catch errors faster/clearer. See
## https://www.semipol.de/posts/2018/06/latex-best-practices-lessons-learned-from-writing-a-phd-thesis/
$biber = "biber --validate-datamodel %O %S";

## Show used CPU time. Looks like: https://tex.stackexchange.com/a/312224/120853
$show_time = 1;

## Extra extensions of files to remove in a clean-up (`latexmk -c`)
$clean_ext = 'synctex.gz synctex.gz(busy)';
## Delete .bbl file in a clean-up if the bibliography file exists
$bibtex_use = 1.5;

## Write all auxiliary files in a separate directory
$aux_dir = '.aux';

## The aux directory structure has to match the source directory structure
## in order to compile the `tex` files without problems, since pdfLaTeX
## does not create the directories on its own.
## https://tex.stackexchange.com/questions/323820/i-cant-write-on-file-foo-aux
## NOTE: the following handles only one level of subdirectories
print `find . -maxdepth 2 -type f -name "*.tex" | # find all tex files up to 2 levels deep
    sed -nE 's|\\./(.*)/.*|\\1|p' | sort -u |     # extract directory names
    xargs -I {} mkdir -pv "$aux_dir"/{}           # create corresponding directories in aux_dir`;

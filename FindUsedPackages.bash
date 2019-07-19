source_files=($(git ls-files '*.Rmd'))
grep -hE '\b(require|library)\([\.a-zA-Z0-9]*\)' "${source_files[@]}" | \
    sed '/^[[:space:]]*#/d' | \
    sed -E 's/.*\(([\.a-zA-Z0-9]*)\).*/\1/' | \
    sort -uf \
    > DEPENDS.txt
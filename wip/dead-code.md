# Detecting dead code in Python

## vulture

## uncalled

<https://github.com/elazarg/uncalled>

## grep

Never underestimate the power of grep! You'd be surprised but it gives the lowest rate of false positives, at least for classes.

First, collect all class names:

```bash
grep \
    --no-filename -oP '(?<=class )([a-zA-Z0-9]+)' \
    ./**/*.py > classes.txt
```

Then count the number of occurrences of each class name in the code:

```bash
cat classes.txt | sort | uniq \
    | xargs -I_ zsh -c 'echo _ $(grep -rF _ ./**/*.py | wc -l)' \
    > counts.txt
```

You can improve the counting by adding `-w` to grep to make it match only the whole word.

And lastly, find the lines where the count is 1 and filter out false positives:

```bash
cat counts.txt | grep -E ' 1$' | grep -vE 'Admin|Test|Config'
```

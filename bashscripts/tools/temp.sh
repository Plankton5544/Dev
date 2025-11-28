#!/bin/bash

SCALE=6
MULT=$((10**SCALE))

to_int() {
    # convert string float to integer representation
    local n="$1"
    local neg=0
    [[ "$n" == -* ]] && neg=1 && n="${n:1}"

    # split integer and fractional parts
    local int=${n%%.*}
    local frac=${n#*.}
    [[ "$frac" == "$n" ]] && frac=""

    # pad fraction to SCALE
    while [[ ${#frac} -lt $SCALE ]]; do
        frac="${frac}0"
    done
    frac=${frac:0:$SCALE}  # truncate extra digits

    local val=$((10#$int * MULT + 10#$frac))
    [[ $neg -eq 1 ]] && val=$(( -val ))
    echo $val
}

to_float() {
    local n=$1
    local neg=0
    [[ $n -lt 0 ]] && neg=1 && n=$(( -n ))

    local int=$(( n / MULT ))
    local frac=$(( n % MULT ))

    # pad fraction with zeros
    local frac_str="$frac"
    while [[ ${#frac_str} -lt $SCALE ]]; do
        frac_str="0$frac_str"
    done

    [[ $neg -eq 1 ]] && echo "-$int.$frac_str" || echo "$int.$frac_str"
}

fp_add() {
    local a_int=$(to_int "$1")
    local b_int=$(to_int "$2")
    local sum=$(( a_int + b_int ))
    echo "$(to_float $sum)"
}

fp_sub() {
    local a_int=$(to_int "$1")
    local b_int=$(to_int "$2")
    local diff=$(( a_int - b_int ))
    echo "$(to_float $diff)"
}

fp_mul() {
    local a_int=$(to_int "$1")
    local b_int=$(to_int "$2")

    # multiply and rescale
    local prod=$(( (a_int * b_int) / MULT ))
    echo "$1*$2="
    echo "$(to_float $prod)"
}

fp_div() {
    local a_int=$(to_int "$1")
    local b_int=$(to_int "$2")

    if [[ $b_int -eq 0 ]]; then
        echo "Division by zero!"
        return
    fi

    # rescale numerator before division to keep precision
    local div=$(( (a_int * MULT) / b_int ))
    echo "$1/$2="
    echo "$(to_float $div)"
}


# Compare two floating point numbers
# Returns -1 if a<b, 0 if a==b, 1 if a>b
fp_compare() {
    local a_int=$(to_int "$1")
    local b_int=$(to_int "$2")

    if [[ $a_int -lt $b_int ]]; then
        echo -1
    elif [[ $a_int -gt $b_int ]]; then
        echo 1
    else
        echo 0
    fi
}

# Absolute value
fp_abs() {
    local n_int=$(to_int "$1")
    [[ $n_int -lt 0 ]] && n_int=$(( -n_int ))
    echo "$(to_float $n_int)"
}


fp_sqrt() {
    local n_int=$(to_int "$1")

    if [[ $n_int -lt 0 ]]; then
        echo "Cannot take sqrt of negative number"
        return
    fi

    # initial guess
    local guess=$n_int
    local prev=0
    local tolerance=1  # integer tolerance for stopping

    while [[ $(( guess - prev )) -gt $tolerance ]] || [[ $(( prev - guess )) -gt $tolerance ]]; do
        prev=$guess
        # Newton-Raphson: guess = (guess + n/guess) / 2
        guess=$(( (guess + (n_int * MULT) / guess) / 2 ))
    done

    echo "sqrt($1)="
    echo "$(to_float $guess)"
}



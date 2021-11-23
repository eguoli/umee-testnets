#!/bin/bash

# ./getmemo.sh N

DIR="umeevaloper"
mkdir -p ./$DIR

for((i=$1;i>0;++i))
do
        while true; do
                BLOCK1="$(umeed q block $i 2>&1)"
                OUTPUT=($BLOCK1)
                if [[ ${OUTPUT[0]} == "Error:"* ]]; then
                        #echo "waiting block.."
                        sleep 2
                else
                        break
                fi
        done
        if [[ $BLOCK1 ]]; then
                TXS=$(echo $BLOCK1 | jq -r ".block .data .txs | length")
                if [[ $TXS ]]; then
                        for((t=0;t<$TXS;++t)); do
                                BLOCK2=$(echo $BLOCK1 | jq -r ".block .data .txs[$t]")
                                if [[ $BLOCK2 != *"null"* ]]; then
                                        TX=$(echo $BLOCK2 | base64 -d | sha256sum | awk '{ print $1 }')
                                        while true; do
                                                MEMO="$(umeed q tx $TX --output json 2>&1 | jq -r '.tx.body.memo')"
                                                OUTPUT=($MEMO)
                                                if [[ ${OUTPUT[0]} == "Error:"* ]]; then
                                                        #echo "waiting tx.."
                                                        sleep 1
                                                else
                                                        echo $i $((t+1)) "/" $TXS $TX $MEMO >> getmemo.log
                                                        if [[ ${OUTPUT[0]} == "umeevaloper"* ]]; then
                                                                echo $TX >> "$DIR/${MEMO}.txt"
                                                        fi
                                                        break
                                                fi
                                        done
                                fi
                        done
                fi
        fi
done

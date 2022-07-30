#!/usr/bin/env bash

# 项目目录
ITEM_PATH=D:/MyProject/demo
# 结果文件
recordFile=${ITEM_PATH}/codeStat-$(date "+%Y%m")".csv"
# 统计时间
CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
# 统计周期(天)
STAT_DURATION_DAY=1

# 统计代码
function statCode() {       
    echo "current record file name: $recordFile"

    rm -f $recordFile
    echo "统计时间, 统计周期, 提交人, 提交次数, 增加行数, 删除行数, 行数差" >>$recordFile

    cd $ITEM_PATH
    git fetch --all
    git pull --all
    # Already up-to-date
    echo -e "stat git code => $(pwd)"
    # 统计一天内每个开发人员提交的次数，增加的行数，减小的行数与相对增加的行数
    git log --all --format='%aN' --since=${STAT_DURATION_DAY}.day.ago | sort -u | while read name; do
        echo -en "$CURRENT_TIME, $STAT_DURATION_DAY, $name"
        git log --all --since=${STAT_DURATION_DAY}.day.ago --author="$name" --pretty=oneline | awk -vsum=0 '{ sum += 1 } END { printf ", %s,", sum }' -
        git log --all --since=${STAT_DURATION_DAY}.day.ago --author="$name" --pretty=tformat: --numstat | awk -vadd=0 -vsubs=0 -vloc=0 '{ add += $1; subs += $2; loc += $1 - $2 } END { printf " %s, %s, %s \n", add, subs, loc }' -
    done >>$recordFile
}

# 启动脚本
statCode

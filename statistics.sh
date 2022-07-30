#!/usr/bin/env bash

# 项目目录
read -p "请输入项目绝对路径：" ITEM_PATH
if [ ! $ITEM_PATH ]; then
    ITEM_PATH=D:/MyProject/demo
fi
# 判断路径是否存在
if [ ! -d $ITEM_PATH ] || [ ! -d $ITEM_PATH/.git ]; then
    echo "项目路径不存在或.git不存在"
    exit 1
fi
cd $ITEM_PATH
echo -e "stat git code => $(pwd)"

# 结果文件路径
recordFile=$(
    cd $(dirname $0)
    pwd
)/codeStat-$(date "+%Y%m%d-%H%M%S")".csv"
# 结果文件表头
echo "统计时间, 统计周期, 统计分支, 提交人, 提交次数, 增加行数, 删除行数, 行数差" >>$recordFile

# 统计时间
CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
# 统计周期(天)
STAT_DURATION_DAY=1

# 拉取最新
git fetch --all
git pull --all

echo "以下为全部远程feature分支："
git branch -r | grep origin/feature | awk -F '/' '{print $2}'

read -p "请输入分支列表（使用“,”分割，默认所有分支）：" branchList

# 统计
function statisics() {
    git log $1 --format='%aN' --since=${STAT_DURATION_DAY}.day.ago | sort -u | while read name; do
        echo -en "$CURRENT_TIME, $STAT_DURATION_DAY, $1, $name"
        git log $1 --since=${STAT_DURATION_DAY}.day.ago --author="$name" --pretty=oneline | awk -vsum=0 '{ sum += 1 } END { printf ", %s,", sum }' -
        git log $1 --since=${STAT_DURATION_DAY}.day.ago --author="$name" --pretty=tformat: --numstat | awk -vadd=0 -vsubs=0 -vloc=0 '{ add += $1; subs += $2; loc += $1 - $2 } END { printf " %s, %s, %s \n", add, subs, loc }' -
    done >>$recordFile
}

if [ $branchList ]; then
    IFS="," # 替换分隔符
    for branch in ${branchList[@]}; do
        statisics ${branch}
    done
else
    statisics "--all"
fi

echo "结果文件路径: $recordFile"

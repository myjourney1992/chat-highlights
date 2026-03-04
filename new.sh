#!/bin/bash
# 从剪贴板创建新笔记
# 用法: ./new.sh

set -e

# 颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}📝 从剪贴板创建新笔记${NC}"
echo ""

# 获取剪贴板内容
CONTENT=$(pbpaste)
if [ -z "$CONTENT" ]; then
    echo -e "${YELLOW}⚠️  剪贴板为空，请先复制内容${NC}"
    exit 1
fi

# 输入标题
echo -e "${GREEN}标题:${NC} "
read -r TITLE

if [ -z "$TITLE" ]; then
    echo -e "${YELLOW}⚠️  标题不能为空${NC}"
    exit 1
fi

# 输入标签（逗号分隔）
echo -e "${GREEN}标签 (逗号分隔，如: ai-coding,tdd):${NC} "
read -r TAGS_INPUT

# 转换标签为数组格式
TAGS="["
first=true
IFS=',' read -ra TAG_ARRAY <<< "$TAGS_INPUT"
for tag in "${TAG_ARRAY[@]}"; do
    tag=$(echo "$tag" | xargs) # 去空格
    if [ -n "$tag" ]; then
        if [ "$first" = true ]; then
            TAGS="$TAGS\"$tag\""
            first=false
        else
            TAGS="$TAGS, \"$tag\""
        fi
    fi
done
TAGS="$TAGS]"

# 选择目录
echo ""
echo -e "${GREEN}选择目录:${NC}"
echo "  1) topics   - 主题笔记"
echo "  2) snippets - 代码片段"
echo "  3) quotes   - 金句/观点"
echo -n "选择 [1-3]: "
read -r DIR_CHOICE

case $DIR_CHOICE in
    1) DIR="topics" ;;
    2) DIR="snippets" ;;
    3) DIR="quotes" ;;
    *) DIR="topics" ;;
esac

# 生成文件名（日期 + 标题 slug）
DATE=$(date +%Y%m%d)
SLUG=$(echo "$TITLE" | iconv -t UTF-8 -f UTF-8 | sed 's/[^a-zA-Z0-9]/-/g' | sed 's/--*/-/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-\|-$//g')
FILENAME="${DIR}/${DATE}-${SLUG}.md"

# 获取当前日期
CURRENT_DATE=$(date +%Y-%m-%d)

# 生成 front matter
cat > "$FILENAME" << EOF
---
date: ${CURRENT_DATE}
source: Chat
tags: ${TAGS}
title: ${TITLE}
---

$(echo "$CONTENT")

EOF

echo ""
echo -e "${GREEN}✅ 笔记已创建: ${FILENAME}${NC}"
echo ""
echo "预览文件内容:"
echo "---"
head -n 10 "$FILENAME"
echo "..."
echo "---"
echo ""

# 询问是否打开编辑
echo -e "是否在编辑器中打开? [y/N]"
read -r OPEN_EDIT
if [ "$OPEN_EDIT" = "y" ] || [ "$OPEN_EDIT" = "Y" ]; then
    code "$FILENAME" 2>/dev/null || vim "$FILENAME" 2>/dev/null || open "$FILENAME"
fi
